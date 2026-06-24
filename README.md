# Seekr Companion — Demo Prototype

An **accessibility-first Flutter prototype** that simulates a companion app for an assistive wearable (the kind Seekr builds for low-vision and elderly users). It is **my own illustration of approach** — it simulates the device with a mock data stream — **not a reproduction of Seekr's product or IP**.

Built to demonstrate, in a few minutes, the exact skills the role asks for: **Flutter + GetX, clean architecture, Flutter flavors, real-time data handling, an audio-priority engine, and rigorous accessibility.**

---

## ▶️ Run it (Chrome — easiest for a live screen-share)

You need Flutter installed (`flutter --version`; this was written against Flutter 3.x / Dart 3.x).

```bash
cd seekr_companion_demo
flutter pub get
flutter run -d chrome
```

That's it — no emulator or device needed. TTS speaks through the browser's speech engine in Chrome. You can also run on Android/iOS/macOS/Windows (`flutter run` and pick a device).

> **Test this BEFORE the interview.** If `flutter pub get` or the build fails on your machine, fix it now, not live. (If `flutter_tts` ever fails to initialise on your platform, open `lib/main.dart` and change `FlutterTtsService()` to `NoopTtsService()` — the app still runs and the on-screen "now speaking" log still demonstrates the full flow, just without audio.)

### Using it
1. Tap **Connect** → simulated pairing → distance readings start streaming.
2. Tap **Depth & Obstacle** → when the simulated distance drops under 2 m you get a **spoken safety alert**, then a 3-second cooldown (no spam).
3. Tap **Scene Detection / Text Recognition / Supermarket** → periodic spoken **descriptions**. If an obstacle alert fires while a description is speaking, the **alert interrupts** it (priority audio).
4. Tap the **app-bar icon** to toggle **dark mode**.

---

## 🎤 4-minute walkthrough script (what to say while sharing your screen)

**Ask first:** *"I built a small prototype to show how I'd approach the companion app — it simulates the device with a mock stream, so it's my own illustration, not a copy of yours. Mind if I share my screen for a few minutes?"*

1. **Architecture (60s).** "It's clean architecture on GetX — my production stack. Presentation is the views plus a GetX controller; domain has the models; data has the sources. The key decision: the device is a `DeviceService` behind an interface. Right now it's a simulated WiFi stream, but in production that's a real socket or an EventChannel — and crucially, **when you move from the clip-on to glasses, only that one class changes**. Everything else, including tests, stays put."
2. **Real-time + the audio problem (90s).** "Distance readings stream in here. The interesting engineering problem for an assistive device is that you have one earpiece but multiple things wanting to speak at once. So I built a priority audio queue: safety alerts — like an obstacle — jump the line and interrupt the current description; normal descriptions queue behind. Watch: I'll switch to obstacle mode… there's the alert, and notice it won't repeat for three seconds — a cooldown so it never spams someone who can't see the screen." *(Demonstrate live.)*
3. **Accessibility (60s).** "Because the user can't see the screen, every control has a Semantics label, the status cards are live regions, and mode changes fire a screen-reader announcement. Large text and high contrast are defaults, and dark mode is here because a real user in your App Store reviews asked for it — light backgrounds hurt some low-vision users." *(Toggle dark mode.)*
4. **Stop and hand back (10s).** "That's the gist — happy to dig into any layer, or extend it live if you'd like."

Then **stop talking** and let them drive. Don't over-run.

---

## 🧱 Architecture map

```
lib/
  main.dart                     entry + DI (Get.put) + GetMaterialApp + themes
  core/
    app_config.dart             Flavor enum (dev/qa/staging/prod) + per-flavor config
    theme.dart                  high-contrast, large-text light + dark themes
  domain/
    models.dart                 SeekrMode, AudioPriority, Utterance, DeviceConnectionState
  data/
    device_service.dart         SIMULATED wearable — swap for real WiFi/EventChannel later
  services/
    tts_service.dart            TtsService interface + flutter_tts impl + noop fallback
    audio_queue.dart            race-free priority queue: safety interrupts, normal queues
  controllers/
    seekr_controller.dart       GetX controller: stream -> mode logic -> audio queue -> TTS
  views/
    home_view.dart              accessible UI (Semantics, live regions, announcements)
```

**Talking points this code earns you:**
- *State management:* GetX reactive observables (`.obs`, `Obx`) + DI (`Get.put`/`Get.find`).
- *Flavors:* `AppConfig` shows dev/qa/staging/prod separation (the JD asks for this).
- *Decoupling:* device + TTS both behind interfaces → mockable, swappable, future-proof.
- *Concurrency:* the audio queue uses a single drain loop so audio can't overlap or reorder (a real race condition, handled).
- *Accessibility:* Semantics, `liveRegion`, `SemanticsService.announce`, large text, dark mode.
- *Offline-first thinking:* core modes are driven by the device, not the network (mention you'd add a Hive cache for cloud data).
