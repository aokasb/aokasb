#!/bin/bash
CONFIGJSON=${1:-Eligibility.json}
OVERRIDEDICT=${2:-'{}'}
python jsonOverride.py $CONFIGJSON $OVERRIDEDICT > tmp.json

echo "aws codebuild start-build \
--project-name qppsf-impl-codebuild-manualruns \
--profile 075503252202_ct-ado-qppscoring-application-admin \
--environment-variables-override file://./tmp.json \
--source-version feature/udsredshift/QPPSE-895_publish_codebuild"
