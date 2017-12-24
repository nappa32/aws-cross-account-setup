#!/bin/bash
# set -e
aws_environments=( `jq -r '.accounts.children|keys[]' accounts.json` )
type -f deauth &>/dev/null && deauth
for env in "${aws_environments[@]}"
do

  export APP="${env}CrossAccountRoles"

  echo "Deploying Children Stack for : $env"

  # echo "Changing to $envAdmin role"
  awsid=`jq --arg env "$env" -r ".accounts.children.$env.id" accounts.json`
  # echo "accountid : $awsid "
  awsalias=`jq --arg env "$env" -r ".accounts.children.$env.alias" accounts.json`
  # echo "account alias : $awsalias"
  echo "running stackup ${APP}"
  bundle exec stackup ${APP} up \
  -t child.yaml \
  --tags tags.json \
  --region "us-east-1" --on-failure=DO_NOTHING --with-role arn:aws:iam::${awsid}:role/AdminRole
done
./bootstrap-s3-loginfile.sh > login.html

# -p $CHILDNAME.params.yaml \
# fi
