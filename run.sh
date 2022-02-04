#!/bin/sh

set -e -x

PROJECT_NUMBER="89279074870"
POOL_ID="my-pool"
PROVIDER_ID="my-provider"

SUBJECT_TOKEN_TYPE="urn:ietf:params:oauth:token-type:jwt"
SUBJECT_TOKEN="Ajbkldfsnalkfdas98021j3nklkf0ds98aifnh01ni1"


STS_TOKEN=$(curl -0 -X POST https://sts.googleapis.com/v1/token \
    -H 'Content-Type: text/json; charset=utf-8' \
    -d @sample.json)

echo $STS_TOKEN


ACCESS_TOKEN=$(curl -0 -X POST https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/my-service-account@devops-6a23:generateAccessToken \
              -H "Content-Type: text/json; charset=utf-8" \
              -H "Authorization: Bearer $STS_TOKEN" \
              -d @- <<EOF | jq -r .accessToken
              {
                  "scope": [ "https://www.googleapis.com/auth/cloud-platform" ]
              }
          EOF)
          echo $ACCESS_TOKEN