#!/bin/bash
# Requires: node, curl
#
#
# Simple script that fetches list of open pull requests from GitHub
# Author: Jasmin Begic
#

export PATH='/usr/local/bin:/usr/bin:$PATH'

# API base path
GITHUB_REPO_API="https://api.github.com/repos"

# User with permission to the repository
GITHUB_USER=""

# GitHub API access token (can be generated via github website)
GITHUB_ACCESS_TOKEN=""

# Name of the repository to fetch pull requests for
GITHUB_REPO=""

# Owner of the repository
GITHUB_REPO_OWNER=""

# JavaScript used to parse result JSON and extract titile/url/submitter of pull request
JS='if(prJson=JSON.parse(process.argv[1]),prJson.length>0)for(console.log("♣︎ " +prJson.length+" PRs "),console.log("---"),i=0;i<prJson.length;i++)console.log("▸ "+prJson[i].title+" ("+prJson[i].user.login+") | href="+prJson[i].html_url);"";'

# Fetch and parse open pull request from GitHub
node -pe "$JS" "$(curl -s -u $GITHUB_USER:$GITHUB_ACCESS_TOKEN $GITHUB_REPO_API/$GITHUB_REPO_OWNER/$GITHUB_REPO/pulls)"

