# Configuring Github Actions WORKFLOWS

Navigate to [Github Secrets](https://github.com/garrettwong/auth/settings/secrets/actions)

Create SECRETS in Github REPO for:

1. PROJECT_NUMBER
- Get the value by running `gcloud projects list --filter="projectId=${PROJECT_ID}" --format="value(projectNumber)"`
2. POOL_ID
- Get the value from your `setup.sh` commands.  Default: `my-pool`
3. PROVIDER_ID
- Get the value from your `setup.sh` commands.  Default: `my-provider`
4. SERVICE_ACCOUNT
- Default: workload-identity-sa@[YOUR_PROJECT_ID_HERE].iam.gserviceaccount.com