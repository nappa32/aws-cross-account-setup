#!/bin/bash
# set -e
echo "Refreshing ~/.aws/auth.aws"
rm -f ~/.aws/auth.aws
cp auth.aws ~/.aws/auth.aws

echo "Refreshing account information"
rm -f ~/.aws/accounts.json
cp accounts.json ~/.aws/accounts.json
