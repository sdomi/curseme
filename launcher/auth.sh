#!/bin/bash
# Authenticate with Mojang's authserver
_AUTH_BASE_URL="https://authserver.mojang.com"

function escape_json() {
	sed 's/["\\]/\\&/g;s/\t/\\t/g' <<< "$1"
}

# login(username, password)
function login() {	
	local mail=$(escape_json "$1")	
	local password=$(escape_json "$2")

	local json='
	{
		"agent": {
			"name": "Minecraft",
			"version": 1
		},
		"username": "'"$mail"'",
		"password": "'"$password"'",
		"requestUser": true
	}'

	curl -s \
		-H "Content-Type: application/json" \
		--data-raw "$json" \
		$_AUTH_BASE_URL/authenticate > auth.json
}

function refresh() {
	local accessToken=$(jq -r '.accessToken' < auth.json)
	local clientToken=$(jq -r '.clientToken' < auth.json)
	
	local json='
	{
		"accessToken": "'"$accessToken"'",
		"clientToken": "'"$clientToken"'",
		"requestUser": true
	}'

	curl -s \
		-H "Content-Type: application/json" \
		--data-raw "$json" \
		$_AUTH_BASE_URL/refresh > auth.json
}

function validate() {
	local accessToken=$(jq -r '.accessToken' < auth.json)
	local clientToken=$(jq -r '.clientToken' < auth.json)
	
	local json='
	{
		"accessToken": "'"$accessToken"'",
		"clientToken": "'"$clientToken"'",
		"requestUser": true
	}'

	local meow=$(curl -i -s \
		-H "Content-Type: application/json" \
		--data-raw "$json" \
		$_AUTH_BASE_URL/validate)
	if [[ "$meow" == *"204"* ]]; then
		return 0
	else
		return 1
	fi
}
