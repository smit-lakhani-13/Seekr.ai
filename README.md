# Seekr Companion — Demo Prototype

An **accessibility-first Flutter + FastAPI prototype** for a companion app to an assistive wearable (the kind Seekr builds for low-vision and elderly users). It is my own illustration of approach — not a reproduction of Seekr's product or IP.

Built to demonstrate: **Flutter + GetX, clean architecture, three-tier hybrid AI pipeline, ML Kit on-device inference, FastAPI backend, flavor system, real-time data handling, priority audio engine, and rigorous accessibility.**

---

## Architecture: Three-Tier Hybrid

```
TIER 0 — WEARABLE (dumb + cheap)
  Camera + WiFi + battery. Streams compressed frames to phone.
  In this demo: phone camera acts as the stand-in device.

TIER 1 — PHONE, ON-DEVICE (ML Kit, offline, instant, free)
  Latency-critical and continuous tasks:
  ├── Obstacle/depth detection  → always runs here (never network-dependent)
  ├── OCR / text recognition    → ML Kit text recognizer (local-first)
  └── Barcode / product scan    → ML Kit barcode scanner (local-first)

TIER 2 — CLOUD (FastAPI on GCP/Azure, on explicit trigger only)
  Heavy, user-triggered tasks:
  ├── Rich scene description    → GPT-5.4 Mini vision deployment via Azure OpenAI
  ├── Complex OCR fallback      → when ML Kit returns nothing
  └── Product enrichment        → when barcode scan returns nothing
  One compressed JPEG (<150 KB) sent per trigger. Never a continuous stream.
```

**Routing rule:** `(task type, connectivity, explicit user trigger)` decides the tier.
- Safety/continuous → Tier 1 always (never waits on network)
- OCR/barcode → Tier 1 first; Tier 2 only if local returns nothing AND user triggered AND online
- Scene description → Tier 2 when user triggered + online; Tier 1 fallback offline
- No trigger → never uploads to cloud

**Why this beats pure on-device or pure cloud:**
- Device stays small/long-battery (heavy compute on phone + cloud)
- Safety latency preserved (obstacle detection never waits on network)
- Privacy preserved (everyday detection stays on-device; cloud only on trigger, single frame, no retention)
- Offline-resilient (core modes work with no internet)

---

## Run the Flutter App

Requires Flutter ≥ 3.3.0 with Dart ≥ 3.0.

```bash
flutter pub get
flutter run -d chrome               # web (TTS via browser speech engine)
flutter run                          # pick Android/iOS device
flutter build apk --debug            # debug APK → build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --release \
  --target=lib/main_prod.dart \
  --dart-define=BACKEND_URL=https://seekr-vision-api-agk63t25ja-el.a.run.app
```

**Flavors** (separate entry points, real backend URL via dart-define):
```bash
# dev (default, hits localhost backend)
flutter run --target=lib/main_dev.dart

# production (point at deployed backend)
flutter build apk --release \
  --target=lib/main_prod.dart \
  --dart-define=BACKEND_URL=https://seekr-vision-api-agk63t25ja-el.a.run.app
```

Default `BACKEND_URL` is `http://10.0.2.2:8000` (Android emulator → localhost).

Current deployed backend:

```bash
curl https://seekr-vision-api-agk63t25ja-el.a.run.app/health
```

---

## Run the Backend

Requires Python ≥ 3.12 and [`uv`](https://docs.astral.sh/uv/).

```bash
cd backend
uv sync                                      # install deps
uv run uvicorn app.main:app --reload         # starts on http://localhost:8000

# health check
curl http://localhost:8000/health
# → {"status":"ok"}

# smoke test with mock provider (no keys needed)
curl -X POST http://localhost:8000/describe \
  -F "image=@/path/to/any.jpg" \
  -F "task=scene"
# → {"text":"[Mock] Scene: ...","provider":"mock"}
```

**Set real cloud keys to use your Azure OpenAI vision deployment:**
```bash
export VISION_PROVIDER=azure_openai
export AZURE_OPENAI_ENDPOINT=https://YOUR_RESOURCE.openai.azure.com
export AZURE_OPENAI_API_KEY=<your-key>
export AZURE_OPENAI_DEPLOYMENT=gpt-5.4-mini
export AZURE_OPENAI_API_VERSION=2024-05-01-preview
uv run uvicorn app.main:app --reload
```

**Run backend tests:**
```bash
cd backend
uv run pytest -v
```

## Deploy Backend

The production backend is deployed to Google Cloud Run in project `intrepid-stock-393909`,
region `asia-south1`, service `seekr-vision-api`.

```bash
GCP_PROJECT_ID=intrepid-stock-393909 bash backend/deploy.sh
```

Deployment uses `backend/cloudbuild.yaml`. The Azure OpenAI API key is mounted from
Secret Manager secret `seekr-azure-openai-api-key`; do not put the key in GitHub,
README files, or shell history.

CI/CD is configured in `.github/workflows/deploy-backend.yml`: every push to `main`
that changes `backend/**` or the workflow rebuilds the container, deploys Cloud Run,
reapplies public mobile access, and smoke-tests `/health`.

---

## Run All Tests

```bash
flutter test                    # unit + widget tests
flutter analyze                 # lint clean
dart format --set-exit-if-changed .
```

---

## Architecture Map

```
lib/
  main.dart                   bootstrap(Flavor) DI + runApp
  main_dev.dart               → bootstrap(Flavor.dev)
  main_qa.dart                → bootstrap(Flavor.qa)
  main_staging.dart           → bootstrap(Flavor.staging)
  main_prod.dart              → bootstrap(Flavor.prod)
  core/
    app_config.dart           Flavor enum + per-flavor URLs + BACKEND_URL (dart-define)
    theme.dart                high-contrast light + dark themes
  domain/
    models.dart               SeekrMode, AudioPriority, Utterance, DeviceConnectionState
  data/
    device_service.dart       simulated wearable stream (real device swaps here)
    device_image_source.dart  DeviceImageSource interface
    phone_camera_source.dart  PhoneCameraSource (stands in for real wearable camera)
  services/
    tts_service.dart          TtsService interface + flutter_tts impl + NoopTtsService
    audio_queue.dart          race-free priority queue: safety interrupts, normal queues
    connectivity_service.dart ConnectivityService + retry/backoff + NoopConnectivityService
    local_vision_service.dart ML Kit OCR + labeling + barcode + NoopLocalVisionService
    cloud_vision_service.dart HTTP multipart → FastAPI backend + NoopCloudVisionService
    vision_router.dart        Tier1/Tier2 routing by task × connectivity × trigger
  controllers/
    seekr_controller.dart     GetX controller: capture → route → audio queue → TTS
  views/
    home_view.dart            accessible UI (Semantics, live regions, mode grid, log)

backend/
  app/
    main.py                   FastAPI: GET /health, POST /describe
    models.py                 Pydantic v2: DescribeResponse
    providers/
      __init__.py             VisionProvider ABC + get_provider() factory
      mock_provider.py        mock (default, no keys needed)
      azure_openai_provider.py  GPT-5.4 Mini vision deployment via Azure OpenAI
  tests/
    test_describe.py          9 pytest-asyncio tests (keyless mock + provider error hardening)

android/app/src/main/kotlin/.../MainActivity.kt
                              seekr/network MethodChannel:
                              WifiNetworkSpecifier (device AP, app-scoped, no default route change)
                              + cellular Network requested/monitored for cloud readiness
```

---

## Needs Physical-Device / Real-Key Verification

These cannot be automated — flag them as manual-only during demo:

| What | Why |
|------|-----|
| Dual-network (device WiFi + cellular simultaneously) | Needs physical Android with SIM + separate no-internet WiFi. `WifiNetworkSpecifier` is Android 10+. |
| Azure OpenAI vision end-to-end | Live backend is deployed and smoke-tested; re-test after rotating keys or changing deployment. |
| ML Kit OCR / barcode on real frames | Emulator camera returns nothing useful; needs physical device + real text/barcodes. |
| TTS on Android | Behavior varies by OEM TTS engine; verify on target device. |
| iOS build | Needs Xcode + provisioning profile. |
| iOS multi-network | No `WifiNetworkSpecifier` equivalent on iOS — Android-only feature. |

---

## Key Engineering Decisions

**Multi-network (Android):** `bindProcessToNetwork(cellular)` breaks the device WiFi socket — it binds the whole process. Correct: `WifiNetworkSpecifier` (Android 10+, app-scoped, doesn't change default route) so cellular stays default for internet; request/monitor a cellular `Network` for cloud readiness. If a future real-device transport needs raw sockets, bind those sockets per network rather than binding the whole process.

**Snapshot-on-trigger not continuous stream:** Matches Google Lookout, Envision, Be My AI. Continuous cloud streaming = prohibitive cost + latency + privacy risk. Tier-1 obstacle uses camera stream locally at low frame rate.

**Audio queue with priority:** One earpiece, multiple speakers. Safety interrupt pre-empts queued descriptions; 3-second obstacle cooldown prevents spam; single drain loop prevents overlap.
