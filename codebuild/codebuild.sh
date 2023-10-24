#!/bin/bash
# Objectives: Duplicate the AWS Codebuild / start codebuild from template with change in Environment variable

# Default values
CONFIGJSON=""
SOURCEVERSION=develop
OVERRIDEDICT='{}'
REFERENCE="NONE"
PROJECT="project"
USER=$AWS_PROFILE
REGION=${AWS_DEFAULT_REGION:-"us-east-1"}

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
    -u|--user)
      USER="$2"
      shift
      shift
      ;;
    -g|--geo)
      REGION="$2"
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
        -u <AWS Profile> Defaults to \$AWS_PROFILE
        -g <Region Geography> Defaults to \$AWS_DEFAULT_REGION or us-east-1
        Dependency: jsonOverride.py
        - Executes standard build when no configuration is specified
        - only existing parameters can be overriden new parameters cannot be added
        "
      exit 1
      ;;

  esac
done

if [ "$REFERENCE" != "NONE" ];then
        echo "Downloading environment variables for reference"
        aws codebuild batch-get-builds --ids $PROJECT:$REFERENCE --output json --region $REGION | jq '.builds[].environment.environmentVariables' > ref.json
        CONFIGJSON="ref.json"
fi

if [ "$CONFIGJSON" != "" ];then
        echo "applying override - result in tmp.json)"
        SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
        python $SCRIPT_DIR/jsonOverride.py $CONFIGJSON $OVERRIDEDICT 1> tmp.json
else
        echo "No config provided only triggering the run"
        echo '[]' > tmp.json
fi

command="aws codebuild start-build \
--project-name $PROJECT \
--profile $USER \
--environment-variables-override file://./tmp.json \
--source-version $SOURCEVERSION \
--region $REGION"

echo "Running $command"
$command 1> codebuild.out 2> codebuild.log
RESULT=$?
if [ $RESULT -eq 0 ];then
        echo "SUCCEEDED"
        echo "Logs in codebuild.log and codebuild.out"
	buildid=$(cat codebuild.out | jq '.build.id')
	echo "Run following for status =>"
	echo "aws codebuild batch-get-builds --ids ${buildid}  --region $REGION | jq '.builds[0].buildStatus'"
else
        echo "FAILED"
        echo "Logs in codebuild.log and codebuild.out"
        exit 1
fi
