PROJECT_NUMBER="89279074870"
POOL_ID="my-pool"
PROVIDER_ID="my-provider"

STS_TOKEN=$(curl -0 -X POST https://sts.googleapis.com/v1/token \
    -H 'Content-Type: text/json; charset=utf-8' \
    -d @- <<EOF | jq -r .access_token
    {
        "audience"           : "//iam.googleapis.com/projects/268323096258/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID",
        "grantType"          : "urn:ietf:params:oauth:grant-type:token-exchange",
        "requestedTokenType" : "urn:ietf:params:oauth:token-type:access_token",
        "scope"              : "https://www.googleapis.com/auth/cloud-platform",
        "subjectTokenType"   : "$SUBJECT_TOKEN_TYPE",
        "subjectToken"       : "$SUBJECT_TOKEN"
    }
EOF)
echo $STS_TOKEN
