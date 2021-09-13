#!/bin/bash

mfaAuth() {
    echo "Please input MFA code."
    read -r input
    mfaToken=$(aws sts get-session-token --serial-number "$1" --token-code "$input" --profile $2)
    keyId=$(echo "$mfaToken" | jq -r '.Credentials.AccessKeyId')
    secretKey=$(echo "$mfaToken" | jq -r '.Credentials.SecretAccessKey')
    sessionToken=$(echo "$mfaToken" | jq -r '.Credentials.SessionToken')
    # export AWS_ACCESS_KEY_ID=$keyId
    # export AWS_SECRET_ACCESS_KEY=$secretKey
    # export AWS_SESSION_TOKEN=$sessionToken
    echo "set $2-mfa profile change"
    export AWS_PROFILE=$2-mfa
    aws configure set profile.$2-mfa.aws_access_key_id $keyId
    aws configure set profile.$2-mfa.aws_secret_access_key $secretKey
    aws configure set profile.$2-mfa.aws_session_token $sessionToken
    expiration=$(echo "$mfaToken" | jq -r '.Credentials.Expiration')
    echo "expiration : $expiration"
}

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

echo "Select aws profiles"
select cmd in techad quit; do

    if [ "$cmd" = "quit" ]; then
        echo "not setting profile exit"
        break
    elif [ "$cmd" = "techad" ]; then
        echo "set $cmd profile"
        export AWS_PROFILE=$cmd
        mfaDeviceSerial=arn:aws:iam::854911469310:mfa/ryo2tanaka
        mfaAuth $mfaDeviceSerial $cmd
        break
    fi
    echo
done
