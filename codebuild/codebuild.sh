#!/bin/bash
CONFIGJSON=${1:-Eligibility.json}
SOURCEVERSION=${2:-develop}
OVERRIDEDICT=${3:-'{}'}
python jsonOverride.py $CONFIGJSON $OVERRIDEDICT > tmp.json

command="aws codebuild start-build \
--project-name qppsf-impl-codebuild-manualruns \
--profile 075503252202_ct-ado-qppscoring-application-admin \
--environment-variables-override file://./tmp.json \
--source-version $SOURCEVERSION"

echo $command
$command 1> codebuild.out 2> codebuild.log
echo "command executed , codebuild out and log are created" 
