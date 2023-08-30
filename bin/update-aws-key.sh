# Get key from https://cloudtamer.cms.gov/portal/app-api-key
#!/bin/bash
ACCNAME=${1:-scimpl}
case $ACCNAME in 
	scimpl)
		ACC="SOMEACC1"
		ROLE="SOMEROLE1"
		;;
	scprod)
		ACC="SOMEACC1"
		ROLE="SOMEROLE1"
		;;
	*)
		echo "bad account id"
		exit 1
esac
pushd ~/ctkey
apikey=$(cat ~/.cloudtamer/apikey) 
./ctkey-osx savecreds --url=https://cloudtamer.cms.gov --app-api-key=$apikey --account=${ACC} --iam-role=$ROLE
if [ $? -eq 0 ]; then 
	echo "existing key works"
else 
	echo "New Cloudtamer API Key required"
	python -mwebbrowser https://cloudtamer.cms.gov/portal/app-api-key
	read -p "API Key:" apikey
	echo $apikey > ~/.cloudtamer/apikey
	./ctkey-osx savecreds --url=https://cloudtamer.cms.gov --app-api-key=$apikey --account=${ACC} --iam-role=$ROLE
fi
popd
export AWS_PROFILE="${ACC}_${ROLE}"
