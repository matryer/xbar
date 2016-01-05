#!/bin/bash
USER="username"
PASS="pass"
BASE_URL="my-jenkins.com"
JOBNAME="jobname"

RESULT=`curl -silent http://${USER}:${PASS}@${BASE_URL}/job/${JOBNAME}/lastBuild/api/json?pretty=true | grep "result" | awk '{print $3}'`

if [[ $RESULT == *"SUCCESS"* ]]
then
  echo '🍏'
else
  echo '🍎'
fi
