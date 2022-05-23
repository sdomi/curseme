#!/bin/bash
function get_client_id() {
	# sorry polymc, I don't wanna agree to Azure/MS TOS
	curl https://raw.githubusercontent.com/PolyMC/PolyMC/develop/CMakeLists.txt | grep Launcher_MSA_CLIENT_ID | awk '{print $2}' | sed 's/"//g'	> client_id 
}

function login() {
	res="$(curl "https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode?client_id=$(cat client_id)&scope=XboxLive.signin%20offline_access")"
	jq '.message' <<< "$res"
	echo "Press <return> after authenticating"
	read
	echo "Fetching token..."
	curl -s \
		https://login.microsoftonline.com/consumers/oauth2/v2.0/token \
		--data 'grant_type=urn:ietf:params:oauth:grant-type:device_code&client_id='"$(cat client_id)"'&device_code='"$(jq -r '.device_code' <<< "$res")" > ms_auth_blob

	json='{
	    "Properties": {
	        "AuthMethod": "RPS",
	        "SiteName": "user.auth.xboxlive.com",
	        "RpsTicket": "d='"$(jq -r '.access_token' < ms_auth_blob)"'"
	    },
	    "RelyingParty": "http://auth.xboxlive.com",
	    "TokenType": "JWT"
    }'
    
	echo "Talking with XBL..."

	curl -s \
		https://user.auth.xboxlive.com/user/authenticate \
		-H "Content-Type: application/json" \
		--data-raw "$json" > xbl_auth_blob

	xbl_token=$(jq -r '.Token' < xbl_auth_blob)
	xbl_xui=$(jq -r '.DisplayClaims.xui[0].uhs' < xbl_auth_blob)

	echo "Talking with XSTS..."

	json='
	{
		"Properties": {
		    "SandboxId": "RETAIL",
		    "UserTokens": [
		        "'"$xbl_token"'"
		    ]
		},
		"RelyingParty": "rp://api.minecraftservices.com/",
		"TokenType": "JWT"
	}'

	curl -s \
		https://xsts.auth.xboxlive.com/xsts/authorize \
		-H "Content-Type: application/json" \
		--data-raw "$json" > xsts_auth_blob

	xsts_token=$(jq -r '.Token' < xsts_auth_blob)

	echo "Talking with minecraftservices..."

	json='{"identityToken": "XBL3.0 x='"$xbl_xui"';'"$xsts_token"'"}'

	curl -s \
		https://api.minecraftservices.com/authentication/login_with_xbox \
		-H "Content-Type: application/json" \
		--data-raw "$json" > auth.json
		
	
}
