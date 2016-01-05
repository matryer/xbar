#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Chris Tomkins-Tinch
# github.com/tomkinsc

# Dependencies:
#   travispy (pip install travispy)
#
#   a github auth key (https://github.com/settings/tokens/new)
#     with the following permissions:
#       * repo (for private repos)
#       * public_repo
#
#   names of repositories you have access to
#   (those appearing in your profile)
#   Due to a travis API limitation, information about 
#   public repos is not available unless you are
#   a member. 
#   See: https://github.com/travis-ci/travis-api/issues/195

import random
from travispy import TravisPy

GITHUB_AUTH_KEY = "MY_AUTH_TOKEN"

# note that if no branches are specified only information for the master branch is included
repos_to_check = [
    {"name":'account/repo-name', "branches":["master", "some-feature"]},
]

# ======================================

SYMBOLS = {"green": u"✔︎", "red": u"✘", "yellow": u"❂"}

try:
    t = TravisPy.github_auth(GITHUB_AUTH_KEY)
except:
    print("Auth Error")
    print("---")
    raise

def update_statuses(repos):
    output = []

    output.append(u"{} All OK | color=green".format(SYMBOLS["green"]))
    for repo in repos:
        status = {}
        if "branches" in repo and len(repo["branches"]):
            branch_list = repo["branches"]
        else:
            branch_list = ["master"]

        for branch_name in branch_list:
            try:
                branch = t.branch(branch_name, repo["name"])
            except:
                print("Error")
                print("---")
                raise


            output_msg = u"{symbol} {repo_name} ({branch_name}) {status}".format(symbol=SYMBOLS[branch.color],
                                                                                 repo_name=repo["name"],
                                                                                 branch_name=branch_name,
                                                                                 status=branch.state)

            if branch.color == "red":
                output[0] = output_msg

            href = "https://travis-ci.org/{}/builds/{}".format(repo["name"], int(branch.job_ids[0]) - 1)
            output.append(output_msg + " | href={href} color={color}".format(href=href, color=branch.color))

    print(output[0].encode("utf-8"))
    print("---")
    for msg in output[1:]:
        print(msg.encode("utf-8"))


if __name__ == "__main__":
    update_statuses(repos_to_check)
