#!/usr/bin/env bash
# Deploy backend to Google Cloud Run (asia-south1).
# Prereqs: gcloud auth login, gcloud config set project <PROJECT_ID>
# Usage: GCP_PROJECT_ID=my-project bash deploy.sh
set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:?Error: GCP_PROJECT_ID not set}"
REGION="asia-south1"
SERVICE="seekr-vision-api"
IMAGE="gcr.io/${PROJECT_ID}/${SERVICE}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${REPO_ROOT}"

echo "=== Building and deploying via Cloud Build ==="
gcloud builds submit \
  --config=backend/cloudbuild.yaml \
  --project="${PROJECT_ID}" \
  .

URL=$(gcloud run services describe "${SERVICE}" \
  --region="${REGION}" \
  --project="${PROJECT_ID}" \
  --format="value(status.url)")

echo ""
echo "Deployed: ${URL}"
echo "Test: curl ${URL}/health"
echo ""
echo "Azure OpenAI vision is enabled by backend/cloudbuild.yaml."
echo "The API key is read from Secret Manager, not committed or passed on the command line:"
echo "  gcloud run services update ${SERVICE} --region=${REGION} --project=${PROJECT_ID} \\"
echo "    --set-env-vars=VISION_PROVIDER=azure_openai,AZURE_OPENAI_ENDPOINT=<endpoint>,AZURE_OPENAI_DEPLOYMENT=gpt-5.4-mini,AZURE_OPENAI_API_VERSION=2024-05-01-preview \\"
echo "    --set-secrets=AZURE_OPENAI_API_KEY=seekr-azure-openai-api-key:latest"
