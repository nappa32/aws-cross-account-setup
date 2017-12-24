#!/bin/bash
# set -e
type -f deauth &>/dev/null && deauth
function capitalize() { word="${1}" ruby -e "print ENV['word'].capitalize" ;  };
  # export APP="CrossAccountRolesCFN-DO-NOT-DELETE"
    aws_environments=( `jq -r '.accounts.children|keys[]' accounts.json` )
    # aws_environments=( staging production development )


    for env in "${aws_environments[@]}"
    do

      export APP="${env}IamGroups"

      echo "Deploying Groups for : $env"

      awsid=`jq --arg env "$env" -r ".accounts.children.$env.id" accounts.json`
      # echo "accountid : $awsid "
      awsalias=`jq --arg env "$env" -r ".accounts.children.$env.alias" accounts.json`
      Awsalias=$(capitalize awsalias)
      # echo "account alias : $awsalias"
      echo "running stackup ${APP}"
      bundle exec stackup ${APP} up \
        -t parent.yaml \
        -o ChildAccountId=${awsid} \
        -o ChildAccountAlias=${Awsalias} \
        -o ChildAccountAliasNonCapitalised=${awsalias} \
        -o Env=$env --tags tags.json \
        --region "us-east-1" --on-failure=DO_NOTHING

      bundle exec stackup ${APP} outputs --region=us-east-1
    done
    ./bootstrap-s3-loginfile.sh > login.html
    bucket=$(jq -r '.s3.bucket' accounts.json)
    filename=$(jq -r '.s3.filename' accounts.json)
    aws --region=us-east-1 s3 cp login.html s3://$bucket/$filename  --acl public-read
    echo "check : https://s3.amazonaws.com/${bucket}/${filename}"

    # -p $CHILDNAME.params.yaml \
# fi
