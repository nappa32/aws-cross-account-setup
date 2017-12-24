#!/bin/bash
# set -e

## set colours for envs and roles that AWS allows
function capitalize() { word="${1}" ruby -e "print ENV['word'].capitalize" ;  };
red=F2B0A9
orange=FBBF93
yellow=FAD791
green=B7CA9D
blue=99BCE3
black=""

echo "<html><head></head><body><h1>Step1: Click to <a href='https://company-iam.signin.aws.amazon.com/console'>Login</a></h1><h1>Step 2: Choose Environment & Role</h1>"
if test -f accounts.json
then
  aws_environments=( `jq -r '.accounts.children|keys[]' accounts.json` )
  rolenames=( `jq -r '.roles[]' accounts.json` )
  for env in "${aws_environments[@]}"
  do
    # setup env colours
    case ${env} in
      legacy)
        colour=${orange}
      ;;
      production)
        colour=${green}
      ;;
      staging)
        colour=${blue}
      ;;
      development)
        colour=${yellow}
      ;;
    esac
    awsid=`jq --arg env "$env" -r ".accounts.children.$env.id" accounts.json`
    awsalias=`jq --arg env "$env" -r ".accounts.children.$env.alias" accounts.json`
    Env=$(capitalize ${env})
    echo "<h2>${Env} Roles</h2>"
    echo "<ul>"
    for role in "${rolenames[@]}"
    do
      item="<li><a href='https://signin.aws.amazon.com/switchrole?account=${awsalias}&roleName=${role}&displayName="
      #capitalize admin roles
      if [[ $role == *AdminRole* ]]
      then
        DisplayRoleName="$(echo "$env%20$role" | tr '[:lower:]' '[:upper:]')" ## ALL Caps for ADMIN accounts
      else
        DisplayRoleName="${env}"
      fi
      item+=$(echo $DisplayRoleName|sed 's/Role//gI') # remove the Role part in the name
      item+="&color=$colour'>${role}</a></li>"
      echo "${item}"
    done
    echo "</ul>"
  done

else
  echo "Ensure accounts.json file is there"
  exit 1
fi

echo "</body></html>"
