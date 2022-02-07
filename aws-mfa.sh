#!/bin/zsh

mfaAuth() {
    echo "Please input MFA code"
    read -r input

    echo "setting $1 profile using mfa ..."
    mfaDeviceSerial=$(aws configure --profile $cmd get mfa_serial)
    mfaToken=$(aws sts get-session-token --serial-number "$mfaDeviceSerial" --token-code "$input" --profile $1)
    aws configure set profile.$1-mfa.aws_access_key_id $(echo "$mfaToken" | jq -r '.Credentials.AccessKeyId')
    aws configure set profile.$1-mfa.aws_secret_access_key $(echo "$mfaToken" | jq -r '.Credentials.SecretAccessKey')
    aws configure set profile.$1-mfa.aws_session_token $(echo "$mfaToken" | jq -r '.Credentials.SessionToken')
    echo "expiration : $(echo "$mfaToken" | jq -r '.Credentials.Expiration')"
    echo "completed."
}

echo "Select aws profile"
profiles=$(aws configure list-profiles | grep -v -e mfa -e amplify)

select cmd in $profiles; do
    echo "set $cmd profile"
    mfaAuth $cmd
    break
done
