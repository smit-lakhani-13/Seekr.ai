#!/usr/bin/env bash
# Deploy backend to Google Cloud Run (asia-east1).
# Prereqs: docker, gcloud auth login, gcloud config set project <PROJECT_ID>
# Usage: GCP_PROJECT_ID=my-project bash deploy.sh
set -euo pipefail

PROJECT_ID="${GCP_PROJECT_ID:?Error: GCP_PROJECT_ID not set}"
REGION="asia-east1"
SERVICE="seekr-backend"
IMAGE="gcr.io/${PROJECT_ID}/${SERVICE}"

cd "$(dirname "$0")"

echo "=== Building image ==="
docker build -t "${IMAGE}" .

echo "=== Pushing to Container Registry ==="
docker push "${IMAGE}"

echo "=== Deploying to Cloud Run ==="
gcloud run deploy "${SERVICE}" \
  --image="${IMAGE}" \
  --region="${REGION}" \
  --platform=managed \
  --allow-unauthenticated \
  --set-env-vars="VISION_PROVIDER=mock" \
  --project="${PROJECT_ID}"

URL=$(gcloud run services describe "${SERVICE}" \
  --region="${REGION}" \
  --project="${PROJECT_ID}" \
  --format="value(status.url)")

echo ""
echo "Deployed: ${URL}"
echo "Test: curl ${URL}/health"
echo ""
echo "To enable Azure OpenAI vision (after setting keys in env):"
echo "  gcloud run services update ${SERVICE} --region=${REGION} --project=${PROJECT_ID} \\"
echo "    --set-env-vars=VISION_PROVIDER=azure_openai,AZURE_OPENAI_ENDPOINT=<endpoint>,AZURE_OPENAI_API_KEY=<key>,AZURE_OPENAI_DEPLOYMENT=gpt-5.4-mini,AZURE_OPENAI_API_VERSION=2024-05-01-preview"
