#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Install jq if not already installed
if ! command -v jq &> /dev/null; then
apt-get update && apt-get install -y jq
fi

NUGET_ENV="nuget.json"
NUGET_SOURCE="http://ehanlin-nuget-695959454.ap-northeast-1.elb.amazonaws.com/v3/index.json"
NUGET_NAME="ehanlin-nuget"

# Export environment variables from nuget.json
while IFS="=" read -r key value; do
    export "$key=$value"
done < <(jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" "$NUGET_ENV")

# Configure and push to NuGet source
dotnet nuget add source "$NUGET_SOURCE" -n "$NUGET_NAME" -u "$NUGET_USERNAME" -p "$NUGET_PASSWORD" --store-password-in-clear-text --valid-authentication-types basic
for nupkg_file in ./nuget/*.nupkg; do
    dotnet nuget push "$nupkg_file" -s "$NUGET_NAME" -k "$NUGET_API_KEY"
done