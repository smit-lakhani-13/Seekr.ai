# CLAUDE.md — Project Context for Claude Code

> Claude Code reads this file automatically. It is the standing context for this repo. Read it fully before doing anything. The separate kickoff prompt (`claude_code_kickoff_prompt.md`) contains the phased task list and build gates.

---

## 1. Who I am (the developer)

Smit Lakhani — Flutter + Python full-stack / tech-lead, ~3+ years, Mumbai (IST), remote. Stack: **Flutter → GetX** (primary), **Python → FastAPI** (primary), `uv` over global pip. AI/ML: Azure OpenAI fine-tuning, RAG, vector search, CNN, TensorFlow Lite. I have working access to **Azure (incl. Azure OpenAI), Google Cloud / GCP App Service** for backend deployment — so the backend is fully in scope, not just frontend.

**Anti-claims (never fabricate, never inflate in code comments, docs, or commits):** I'm a Tech Lead (not CTO/Founder); 3+ years (not 10+); GenZGPT runs on **GPT-5.4 Mini** (never "GPT-5" or "5.5"); don't invent metrics, users, or shipped products.

## 2. What this repo is

This is a **prototype companion app for an assistive-vision wearable**, built for an interview with **Seekr / Vidi Labs** (Hong Kong). Seekr makes a small clip-on camera wearable that helps **blind / low-vision / elderly** users by describing the world through audio. The company is moving toward **AI smart glasses** next.

The repo currently contains:
- `lib/` — an **accessibility-first Flutter demo** (GetX + clean architecture) that **simulates** the wearable with a mock data stream. Files: `core/` (flavors, theme), `domain/models.dart`, `data/device_service.dart` (SIMULATED device), `services/` (TTS behind an interface, a race-free priority `audio_queue.dart`), `controllers/seekr_controller.dart` (orchestration), `views/home_view.dart` (accessible UI). It runs on Chrome today.
- `docs/` — interview prep + architecture write-ups. **Read these** for the full product, JD, and architecture reasoning. Key ones: `seekr_founder_conversation_prep.md`, `seekr_round2_mock_and_practice_system.md` (Section 2 architecture, Section 3 AI/ML + the 1 Mbps pipeline), `seekr_round2_coding_prep.md`, `seekr_interview_prep_june17.md`.

## 3. The product, precisely

- **Wearable device:** small camera + WiFi + battery. It broadcasts its **own local WiFi** (no internet by design) and streams **compressed image frames to the phone at ~1 Mbps**. Audio goes out to a Bluetooth earpiece.
- **App modes:** Text Recognition (read signs/menus/labels), Scene Detection (describe surroundings), Depth & Obstacle (warn of obstacles), Supermarket (aisles/products). Multilingual TTS.
- **Constraint that drives everything:** the device must stay **small, cheap, and long-battery**, so it can't carry a big GPU/CPU/RAM. Heavy compute must live elsewhere.

## 4. THE ARCHITECTURE DECISION (this is the "solution they want") ⭐

Do **NOT** put all vision compute on the wearable (kills battery/size) and do **NOT** stream every frame to the cloud (kills latency, privacy, cost, offline). The correct, production-grade design is a **three-tier hybrid**, which is what the strongest competitor (Envision) does; OrCam is pure on-device, Be My AI / Seeing AI are pure cloud — hybrid beats both for this use case.

```
TIER 0 — WEARABLE (dumb + cheap)
  Camera + WiFi + battery. Streams compressed frames (~1 Mbps) to the phone.
  Optional: ultra-light proximity/obstacle hint if the MCU allows.

TIER 1 — PHONE, ON-DEVICE (TFLite / ML Kit)         ← fast, private, offline, free
  Latency-critical + frequent + privacy-sensitive tasks:
  obstacle/depth, quick scene gist, basic OCR, barcode/product scan.
  Runs on the phone's NPU/GPU. NO network. NO per-call cost. NO data leaves device.

TIER 2 — CLOUD (FastAPI on GCP App Service / Azure)  ← powerful, on-demand only
  Heavy, user-TRIGGERED, non-time-critical tasks:
  rich scene description, complex/multi-column OCR, VQA ("what colour is this?"),
  product/landmark recognition, translation.
  Backend calls Azure Computer Vision / Google Cloud Vision / Azure OpenAI GPT-4o-vision.
  Send ONE downscaled+compressed frame ON TRIGGER (never a continuous stream).
```

**Routing rule (the hybrid decision):** task type + connectivity + explicit user trigger decide the tier. Safety/continuous → Tier 1 (never cloud-dependent). Heavy + user asked + online → Tier 2. Always degrade gracefully (speak "no connection" rather than fail silently — the user can't see a spinner).

**Why this is foolproof:** device stays small/long-battery (compute offloaded to phone+cloud); safety latency preserved (critical work never waits on network); privacy preserved (everyday detection stays on-device; cloud only on explicit trigger, single frame, with consent, no retention, optional face-blur); cost controlled (no continuous cloud streaming); offline-resilient (core works with no internet).

## 5. The networking piece (multi-network — get this exactly right)

The phone is on the **device's local WiFi (no internet)** to receive frames, while it needs **internet over cellular** for Tier-2 cloud calls — **simultaneously**. Android does NOT reliably auto-switch (the "Android 12 auto-switches" claim is false; OEM-specific and flaky). Use the **multi-network binding API** via a `MethodChannel` to native Kotlin:

```kotlin
val cm = getSystemService(ConnectivityManager::class.java)
val request = NetworkRequest.Builder()
    .addTransportType(NetworkCapabilities.TRANSPORT_CELLULAR)
    .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    .build()
cm.requestNetwork(request, object : ConnectivityManager.NetworkCallback() {
    override fun onAvailable(network: Network) {
        cm.bindProcessToNetwork(network)   // route app internet over cellular
    }
    override fun onLost(network: Network) { /* notify Dart */ }
})
```
Detect failures by `SocketException`/timeout (an HTTP 4xx/5xx means the network worked). Retry once on the bound network; on repeated failure, exponential backoff + a TTS message. `connectivity_plus` can *detect* state but the binding must be native.

## 6. Coding standards

- **Flutter:** GetX for state + DI + routing. Clean architecture (presentation / domain / data). Keep device comms and TTS **behind interfaces** (already done) so the real device/cloud swaps in without touching the rest. Flavors: dev/qa/staging/prod. Const-correctness, dispose everything, guard `setState`/context across async gaps.
- **FastAPI:** async endpoints, Pydantic models for every payload, dependency injection, explicit HTTP error handling, `uv` for env. Never log image bytes or PII. Secrets via env vars, never hard-coded.
- **Privacy/security:** images are sensitive. Tier-2 calls: single frame on trigger, transmit over TLS, no server-side retention by default, document data handling. Consider on-device face-blur before any upload.
- **Tests:** unit-test pure domain + the audio queue + the routing logic; widget-test the accessible UI (`find.bySemanticsLabel`); a code-flow walkthrough for the networking. Lint clean (`flutter analyze`, `dart format`).

## 7. CRITICAL GOTCHAS (read before building)

1. **There is no `android/` (or `ios/`, `web/`) folder yet** — `lib/` + `pubspec.yaml` only. `flutter build apk` **will fail** until platforms are scaffolded. Run `flutter create --platforms=android,ios,web .` first (it preserves existing `lib/` and `pubspec.yaml`, only adding missing platform folders). Then `flutter pub get`, then build.
2. The demo currently streams a **distance double**, not images. Adding real-time **image** capture/transmission is new work (Phase 2+). Without the real wearable, use the **phone camera as a stand-in "device camera"** behind the same `DeviceImageSource` interface, so the real device drops in later.
3. No real cloud keys are committed. Build the Tier-2 backend fully, but gate live calls behind env vars; provide a mock/echo mode so the pipeline runs end-to-end without keys, with clear `TODO(human): set AZURE_/GCP_/OPENAI_ keys`.
4. The real multi-network behaviour can only be fully verified **on a physical Android device with a SIM + a separate WiFi-without-internet**. On emulator/desktop, build it correctly and unit-test the logic; flag what needs on-device verification.

## 8. Working agreement

- Before each phase: a few lines on what you understood + the plan. Then implement fully.
- You may add/edit/refactor/rename/delete freely to make it correct and clean — just report it after. Only stop for genuinely ambiguous or irreversible decisions.
- If I'm wrong, **push back** with reasoning — I'd rather be corrected.
- Web-search when uncertain or when APIs may have changed (Flutter, Android `ConnectivityManager`, Azure/GCP vision SDKs, `flutter_tts`, `camera`). Don't rely on stale memory.
- Respect build gates: do not start a later phase until the earlier gate passes. After each phase: test it, then a short summary of changes + assumptions + what I must verify manually.
