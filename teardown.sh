#!/usr/bin/env bash

export PROJECT_ID=$(gcloud config get-value project)

# TODO(developer): Update this value to your GitHub repository.
export REPO="garrettwong/auth" # e.g. "google/chrome"

gcloud iam service-accounts remove-iam-policy-binding "workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--project="${PROJECT_ID}" \
--role="roles/iam.workloadIdentityUser" \
--member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"

gcloud iam workload-identity-pools providers delete-oidc "github-provider" \
--project="${PROJECT_ID}" \
--location="global" \
--workload-identity-pool="github-pool" \
--display-name="Demo provider" \
--attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
--issuer-uri="https://token.actions.githubusercontent.com"

gcloud iam workload-identity-pools delete "github-pool" \
--project="${PROJECT_ID}" \
--location="global" --quiet

gsutil iam ch -d "serviceAccount:workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com:objectAdmin" \
gs://$PROJECT_ID-terraform-state

gcloud projects remove-iam-policy-binding $PROJECT_ID \
--member "serviceAccount:workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/storage.objectAdmin" --condition=None --quiet

# gsutil rm -rf gs://$PROJECT_ID-terraform-state

gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
--member "serviceAccount:workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/compute.storageAdmin" --condition=None --quiet

gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
--member "serviceAccount:workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/secretmanager.secretAccessor" --condition=None --quiet

gcloud secrets versions destroy 1 --secret "my-secret" --quiet
rm hello.txt
gcloud secrets delete "my-secret"

gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
--member "serviceAccount:workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
--role "roles/storage.objectAdmin" --condition=None --quiet

gcloud iam service-accounts create "workload-identity-sa" \
--project "${PROJECT_ID}"

