#!/usr/bin/env bash

PROJECT_ID="gwc-wif"

PROJECT_NUMBER=$(gcloud projects list --filter="projectId=${PROJECT_ID}" --format="value(projectNumber)")
POOL_ID="my-pool"

SUBJECT="my-subject"

PROVIDER_ID="my-provider"

SERVICE_ACCOUNT_EMAIL="my-service-account@gwc-wif.iam.gserviceaccount.com"

PRINCIPAL="principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/subject/${SUBJECT}"

echo $PRINCIPAL

gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_EMAIL \
    --role=roles/iam.workloadIdentityUser \
    --member="$PRINCIPAL" \
    --project $PROJECT_ID


TOKEN_FILEPATH="oidc"
SOURCE_TYPE="json"
FIELD_NAME="token"

gcloud iam workload-identity-pools create-cred-config \
    projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID \
    --service-account=$SERVICE_ACCOUNT_EMAIL \
    --output-file=FILEPATH.json \
    --credential-source-file=$TOKEN_FILEPATH \
    --credential-source-type=$SOURCE_TYPE \
    --credential-source-field-name=$FIELD_NAME


SUBJECT_TOKEN_TYPE="urn:ietf:params:oauth:token-type:jwt"
SUBJECT_TOKEN=token
SUBJECT_TOKEN="eyJhbGciOiJSUzI1NiIsImtpZCI6ImQ2M2RiZTczYWFkODhjODU0ZGUwZDhkNmMwMTRjMzZkYzI1YzQyOTIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIzMjU1NTk0MDU1OS5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImF1ZCI6IjMyNTU1OTQwNTU5LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTA4MzkwNzk0MzE3MTg2MjMyODIxIiwiaGQiOiJnd29uZ2Nsb3VkLmNvbSIsImVtYWlsIjoiZ2FycmV0dHdvbmdAZ3dvbmdjbG91ZC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6Imdpc1JNTTI5MzVmNldMcDFUS2hIMkEiLCJpYXQiOjE2NDczMjMxNzUsImV4cCI6MTY0NzMyNjc3NX0.VsNyqO8SErs5Vmpk9Garm486bxi-mI8Bc4iYZois2hmqmbZT5k26N-nDNiOOqq4LNRenbNKa-fqJJS1TQC5w0caCe3iwQh6gpKNdr--i3YD8kk1CaynvXEinS1AtXWkvMTpJ_VuiJ_4Rg1Nr1r1xRscndkBgL3EZdfcyK1gHAUW_PoIvl3QEcQrO37KFBG2GZLNyWTOzLZm_KsRq00ZCmVjlAcMQY9Begm-mATlSV44NrSonS6Md-TrpbqZ-EJV-18IVRD3UA-8Ab_sttN9xCQM9TbAsyCtcykouDh2Eezg6krhEBLIHXF2ua7GFaIVXOyJ1kHd_0mpbvEiEIW6p-w"
curl -0 -X POST https://sts.googleapis.com/v1/token \
    -H 'Content-Type: text/json; charset=utf-8' \
    -d @- <<EOF | jq -r .access_token
    {
        "audience"           : "//iam.googleapis.com/projects/1092380939282/locations/global/workloadIdentityPools/my-pool/providers/my-provider",
        "grantType"          : "urn:ietf:params:oauth:grant-type:token-exchange",
        "requestedTokenType" : "urn:ietf:params:oauth:token-type:access_token",
        "scope"              : "https://www.googleapis.com/auth/cloud-platform",
        "subjectTokenType"   : "$SUBJECT_TOKEN_TYPE",
        "subjectToken"       : "$SUBJECT_TOKEN"
    }
EOF