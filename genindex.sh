#!/bin/bash

# script to buid list with 30 latest successul CircleCI runs
# requirments: curl, jq

set -e

PROJECT="smartmontools/smartmontools"
cat header.html > index.html.tmp

# get 30 latest master builds
NUMS="$(
  curl --fail --silent \
    'https://circleci.com/api/v1.1/project/github/'${PROJECT}'/tree/master?filter=successful' \
    | jq -r '.[].build_num'
  )"

for num in $NUMS; do
  if [ ! -s "${num}-artefacts.json" ]
  then
      # caching artifact data locally
      curl --silent --fail \
        "https://circleci.com/api/v1.1/project/github/${PROJECT}/${num}/artifacts" \
        > "${num}-artefacts.json"
  fi
  # extract artifacts data
  echo "<h2>Build <a href='https://circleci.com/gh/${PROJECT}/${num}'>#${num}</a></h2>" >> index.html.tmp
  jq -r '.[]|"<li><a href=\"" + .url + "\">" + .path +  "</a></li>"' "${num}-artefacts.json" >> index.html.tmp
done

cat footer.html >> index.html.tmp

mv index.html.tmp index.html
