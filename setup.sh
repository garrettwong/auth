#!/usr/bin/env bash

export PROJECT_ID=$(gcloud config get-value project)

gcloud services enable iam.googleapis.com sts.googleapis.com iamcredentials.googleapis.com \
--project $PROJECT_ID

gcloud iam service-accounts create "workload-identity-sa" \
--project "${PROJECT_ID}"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member "serviceAccount:workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/storage.admin" --condition=None --quiet

# secrets manager and disk create
gcloud services enable secretmanager.googleapis.com \
--project $PROJECT_ID
gcloud secrets create "my-secret" --replication-policy="automatic"
echo "github-actions-disk" >> hello.txt
gcloud compute disks create github-actions-disk --zone us-west1-a
gcloud secrets versions add "my-secret" --data-file="hello.txt"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member "serviceAccount:workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/secretmanager.secretAccessor" --condition=None --quiet

gcloud services enable compute.googleapis.com \
--project $PROJECT_ID
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member "serviceAccount:workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/compute.storageAdmin" --condition=None --quiet

gsutil mb -p $PROJECT_ID gs://$PROJECT_ID-terraform-state
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member "serviceAccount:workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/storage.admin" --condition=None --quiet
gsutil iam ch "serviceAccount:workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com:objectAdmin" \
    gs://$PROJECT_ID-terraform-state


gcloud iam workload-identity-pools create "github-pool" \
--project="${PROJECT_ID}" \
--location="global" \
--display-name="Demo pool"

gcloud iam workload-identity-pools describe "github-pool" \
--project="${PROJECT_ID}" \
--location="global" \
--format="value(name)"

export WORKLOAD_IDENTITY_POOL_ID=$(gcloud iam workload-identity-pools describe "github-pool" \
    --project="${PROJECT_ID}" \
    --location="global" \
--format="value(name)")

function setup_github() {
    gcloud iam workload-identity-pools providers create-oidc "github-provider" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --workload-identity-pool="github-pool" \
    --display-name="Demo provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
    --issuer-uri="https://token.actions.githubusercontent.com"
    
    # TODO(developer): Update this value to your GitHub repository.
    export REPO="garrettwong/auth" # e.g. "google/chrome"
    
    gcloud iam service-accounts add-iam-policy-binding "workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
    --project="${PROJECT_ID}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"
    
    gcloud iam workload-identity-pools providers describe "github-provider" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --workload-identity-pool="github-pool" \
    --format="value(name)"
    
    PROJECT_NUMBER=$(gcloud projects list --filter="projectId=${PROJECT_ID}" --format="value(projectNumber)")
    
    echo "PROJECT_NUMBER: ${PROJECT_NUMBER}"
}


function setup_gcp() {
    gcloud iam workload-identity-pools providers create-oidc "domain-ext" \
    --project="${PROJECT_ID}" \
    --location="global" \
    --workload-identity-pool="github-pool" \
    --display-name="Provider for GCP Identities" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor" \
    --issuer-uri="https://accounts.google.com"
}

setup_github
