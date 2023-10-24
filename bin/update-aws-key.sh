# Get key from https://cloudtamer.cms.gov/portal/app-api-key
#!/bin/bash
# NEEDS ~/ctkey to have ctkey-osx executable
# NEEDS ~/.cloudtamer/config to have account and role associated
# Populates ~/.cloudtamer/apikey if not present
# USE source to execute this file so that your environment will get the right role etc
ACC=""
ACCNAME=${1:-acc_abbr}
parser="import configparser,sys;config = configparser.ConfigParser();config.read(sys.argv[1]);c=sys.argv[2];print(config[c]['account'],config[c]['role'])"
read -r ACC ROLE <<< $(python -c "$parser" ~/.cloudtamer/config $ACCNAME)
if [ "$ACC" = "" ];then
  echo "Bad account name check or create the ~/.cloudtamer/config for entries of account and role"
  exit 1
fi
pushd ~/ctkey
apikey=$(cat ~/.cloudtamer/apikey) 
./ctkey-osx savecreds --url=https://cloudtamer.cms.gov --app-api-key=$apikey --account=${ACC} --iam-role=$ROLE
if [ $? -eq 0 ]; then
	echo "existing key works"
else 
	echo "New Cloudtamer API Key required"
	python -mwebbrowser https://cloudtamer.cms.gov/portal/app-api-key
	echo "Copy API Key here:"
	read apikey
	echo $apikey > ~/.cloudtamer/apikey
	./ctkey-osx savecreds --url=https://cloudtamer.cms.gov --app-api-key=$apikey --account=${ACC} --iam-role=$ROLE
fi
popd
export AWS_PROFILE="${ACC}_${ROLE}"
