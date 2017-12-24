#!/bin/bash
# set -e
type -f deauth &>/dev/null && deauth
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_YELLOW=$ESC_SEQ"33;01m"

echo -e "$COL_RED ======= BE CAREFUL ======== $COL_RESET"
echo "1. create an iam user on a new aws account with passwords. eg: _admin"
echo "2. give admin level access by adding AdministratorAccess managed policy to the account"

unset env
read -p "Enter environment Name (in LOWERCASE) eg: legacy : "  env
export env=$env

unset AWS_ACCESS_KEY_ID
read -s -p "Enter AWS_ACCESS_KEY_ID " AWS_ACCESS_KEY_ID
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
echo " "

unset AWS_SECRET_ACCESS_KEY
read -s -p "Enter AWS_SECRET_ACCESS_KEY " AWS_SECRET_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
echo " "

export AWS_DEFAULT_REGION=us-east-1

export APP="${env}CrossAccountRoles"
bundle exec stackup ${APP} up \
  -t child.yaml \
  --region us-east-1 --tags tags.json --on-failure=DO_NOTHING

echo -e "$COL_RED ======= DELETE ADMIN ACCOUNT ======== $COL_RESET"
echo "the temp admin account is not needed anymore. It is a security risk !! "
