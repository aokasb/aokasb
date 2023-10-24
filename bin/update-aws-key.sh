#!/bin/bash
# Get key from https://cloudtamer.cms.gov/portal/app-api-key
# NEEDS ~/ctkey to have ctkey-osx executable https://confluence.cms.gov/download/attachments/382210110/ctkey.zip?api=v2
# NEEDS ~/.cloudtamer/config to have account and role associated
# Populates ~/.cloudtamer/apikey if not present
# USE source to execute this file so that your environment will get the right role etc
ACC=""
ACCNAME=${1:-acc_abbr}
parser="import configparser,sys;config = configparser.ConfigParser();config.read(sys.argv[1]);c=sys.argv[2];print(config[c]['account'],config[c]['role'])"
read -r ACC ROLE <<< $(python -c "$parser" ~/.cloudtamer/config $ACCNAME)
if [ "$ACC" = "" ];then
  echo "Bad account name check or create the ~/.cloudtamer/config for entries of account and role"
  echo "it should be of the format \n[account_abbreviation]\naccount=<account_number>\nrole=<role>"
  return 1
fi
apikey=$(cat ~/.cloudtamer/apikey)
function ctkey() {
   ~/ctkey/ctkey-osx savecreds --url=https://cloudtamer.cms.gov --app-api-key=$1 --account=${ACC} --iam-role=${ROLE}
}
ctkey $apikey
if [ $? -eq 0 ]; then
	echo "existing Cloudtamer API key works"
else 
	echo "New Cloudtamer API Key required"
	python -mwebbrowser https://cloudtamer.cms.gov/portal/app-api-key
	echo "Copy API Key here:"
	read apikey
	echo $apikey > ~/.cloudtamer/apikey
  ctkey $apikey
fi
export AWS_PROFILE="${ACC}_${ROLE}"