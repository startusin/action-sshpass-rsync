#!/bin/bash
set -e

echo "#################################################"
echo "> Starting ${GITHUB_WORKFLOW}:${GITHUB_ACTION}"

# Available env
# echo "INPUT_HOST: ${INPUT_HOST}"
# echo "INPUT_PORT: ${INPUT_PORT}"
# echo "INPUT_USER: ${INPUT_USER}"
# echo "INPUT_PASS: ${INPUT_PASS}"
# echo "INPUT_KEY: ${INPUT_KEY}"
# echo "INPUT_LOCAL: ${INPUT_LOCAL}"
# echo "INPUT_REMOTE: ${INPUT_REMOTE}"
# echo "INPUT_RUN_BEFORE: ${INPUT_RUNBEFORE}"
# echo "INPUT_RUN_AFTER: ${INPUT_RUNAFTER}"

RUNBEFORE="${INPUT_RUNBEFORE/$'\n'/' && '}"
RUNAFTER="${INPUT_RUNAFTER/$'\n'/' && '}"

echo "> Exporting Password"
export SSHPASS=$PASS

[[ -z "${INPUT_RUNBEFORE}" ]] && {
  echo "> Executing commands before deployment"
  sshpass -e ssh -o StrictHostKeyChecking=no -p $INPUT_PORT $INPUT_USER@$INPUT_HOST "$RUNBEFORE"
}

echo "> Deploying now"
sshpass -p $INPUT_PASS rsync -avhz -e "ssh -p $INPUT_PORT" $GITHUB_WORKSPACE/$INPUT_LOCAL $INPUT_USER@$INPUT_HOST:$INPUT_REMOTE --exclude-from='rsync-exclude.txt'

[[ -z "${INPUT_RUNAFTER}" ]] && {
  echo "> Executing commands after deployment"
  sshpass -e ssh -o StrictHostKeyChecking=no -p $INPUT_PORT $INPUT_USER@$INPUT_HOST "$RUNAFTER"
}

echo "#################################################"
echo "Completed ${GITHUB_WORKFLOW}:${GITHUB_ACTION}"
