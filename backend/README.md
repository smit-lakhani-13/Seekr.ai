# Seekr Vision API — Tier-2 backend

FastAPI backend that receives a single camera frame from the Flutter app and returns a spoken-style description.

## Run locally (mock mode — no keys needed)

```bash
cd backend
uv run uvicorn app.main:app --reload
```

## Test

```bash
uv run pytest tests/ -v
```

Current gate: `9 passed`.

## Call the endpoint

```bash
curl -X POST http://localhost:8000/describe \
  -F "image=@/path/to/frame.jpg" \
  -F "task=scene"
```

Tasks: `scene` | `ocr` | `vqa` | `product`. For `vqa`, also pass `-F "question=What colour is the door?"`.

## Environment variables

| Var | Default | Purpose |
|-----|---------|---------|
| `VISION_PROVIDER` | `mock` | `mock` or `azure_openai` |
| `AZURE_OPENAI_ENDPOINT` | — | TODO(human): set to your Azure resource URL |
| `AZURE_OPENAI_API_KEY` | — | TODO(human): set to your Azure API key. `AZURE_OPENAI_KEY` is also accepted for compatibility. |
| `AZURE_OPENAI_DEPLOYMENT` | `gpt-5.4-mini` | Deployment name |
| `AZURE_OPENAI_API_VERSION` | `2024-05-01-preview` | API version |

## Deploy

Live Cloud Run URL:

```bash
https://seekr-vision-api-agk63t25ja-el.a.run.app
```

Manual deploy:

```bash
GCP_PROJECT_ID=intrepid-stock-393909 bash backend/deploy.sh
```

CI/CD:

- `.github/workflows/deploy-backend.yml` deploys automatically on pushes to `main`
  that touch `backend/**`.
- Google auth uses Workload Identity Federation, not a committed service account key.
- Runtime Azure key is mounted from Secret Manager secret
  `seekr-azure-openai-api-key`.
- Provider mode is `azure_openai` with `AZURE_OPENAI_DEPLOYMENT=gpt-5.4-mini`.

## Security notes

- Image bytes are never logged server-side.
- Tier-2 is triggered only on explicit user action (single frame, not continuous stream).
- All cloud calls go over TLS.
- No server-side image retention by default.
