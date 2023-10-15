#!/bin/sh

set -e -x

PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects list --filter="projectId=${PROJECT_ID}" --format="value(projectNumber)")
POOL_ID="github-pool"
PROVIDER_ID="github-provider"

SUBJECT_TOKEN_TYPE="urn:ietf:params:oauth:token-type:jwt"
SUBJECT_TOKEN="Ajbkldfsnalkfdas98021j3nklkf0ds98aifnh01ni1"

# requires sample.json
STS_TOKEN=$(curl -0 -X POST https://sts.googleapis.com/v1/token \
    -H 'Content-Type: text/json; charset=utf-8' \
    -d @FILEPATH.json)

echo $STS_TOKEN


ACCESS_TOKEN=$(curl -0 -X POST https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/workload-identity-sa@${PROJECT_ID}:generateAccessToken \
              -H "Content-Type: text/json; charset=utf-8" \
              -H "Authorization: Bearer $STS_TOKEN" \
              -d @- <<EOF | jq -r .accessToken
              {
                  "scope": [ "https://www.googleapis.com/auth/cloud-platform" ]
              }
          EOF)
          echo $ACCESS_TOKEN