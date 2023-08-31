#!/bin/bash
# Objectives: Duplicate the AWS Codebuild / start codebuild from template with change in Environment variable

# Default values
CONFIGJSON=""
SOURCEVERSION=develop
OVERRIDEDICT='{}'
REFERENCE="NONE"
PROJECT="project"

while [[ $# -gt 0 ]]; do
  case $1 in
    -c|--config)
      CONFIGJSON="$2"
      shift
      shift
      ;;
    -s|--source)
      SOURCEVERSION="$2"
      shift
      shift
      ;;
    -o|--override)
      OVERRIDEDICT="$2"
      shift
      shift
      ;;
    -r|--reference)
      REFERENCE="$2"
      shift
      shift
      ;;
    -p|--project)
      PROJECT="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option $1"
      echo "Usage: bash codebuild.sh
        -c <environment-variables-json> OR -r <reference-project-run-hash>
        -o '{\"<override_key\":\"override_value\"}'
        -p <codebuild-project> Default: manualruns
        -s <source-version> Default: develop
        Dependency: jsonOverride.py
        Dependency: Needs $AWS_PROFILE to be set
        - Executes standard build when no configuration is specified
        - only existing parameters can be overriden new parameters cannot be added
        "
      exit 1
      ;;

  esac
done

if [ "$REFERENCE" != "NONE" ];then
        echo "Downloading environment variables for reference"
        aws codebuild batch-get-builds --ids $PROJECT:$REFERENCE --output json | jq '.builds[].environment.environmentVariables' > ref.json
        CONFIGJSON="ref.json"
fi

if [ "$CONFIGJSON" != "" ];then
        echo "applying override - result in tmp.json)"
        python jsonOverride.py $CONFIGJSON $OVERRIDEDICT 1> tmp.json
else
        echo "No config provided only triggering the run"
        echo '[]' > tmp.json
fi

command="aws codebuild start-build \
--project-name $PROJECT \
--profile $AWS_PROFILE \
--environment-variables-override file://./tmp.json \
--source-version $SOURCEVERSION \
--region us-east-1"

echo $command
$command 1> codebuild.out 2> codebuild.log
RESULT=$?
if [ $RESULT -eq 0 ];then
        echo "command SUCCEEDED, codebuild out and log are created"
else
        echo "command FAILED see output and logs"

fi
