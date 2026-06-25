# 🎯 SEEKR ROUND 2 — FULL MOCK INTERVIEW + PRACTICE SYSTEM (WORKBOOK)

**Companion to:** `seekr_round2_coding_prep.md` (v2). That doc = reference (syntax, behavioral, two-jobs, salary, cheat sheet). **This doc = practice**: a full simulated interview, architecture scripts, deep AI/ML, coding sets with solutions, and timed plans.

**Interview:** Mon Jun 29 · 4:00–5:00 PM HKT = 1:30–2:30 PM IST · with Reshika (likely + Lamia)

> **Note on your repos:** I tried to read your GitHub (reloop, ai_wellness, ai_wellness_automation, GCP-App-Service, genzdealz-nextjs). They're **private** and there's no authenticated GitHub link in this tool environment, so I couldn't open the code. The architecture write-ups below are reconstructed from everything you've told me across our sessions — **verify the exact details against your real code before you present them**, especially version numbers, service names, and metrics.

---

## 📑 CONTENTS
- **Section 1** — The full 60-minute simulated mock interview (weak vs strong answers)
- **Section 2** — Architecture master (GenZGPT, AI Wellness, CRM, Seekr app, generic Flutter)
- **Section 3** — AI/ML deep dive for Reshika (embeddings, vector DB, semantic search, RAG, fine-tuning, data flow, 1 Mbps pipeline) + 20 Q&A
- **Section 4** — Coding practice sets with full solutions (GetX · native Android · FastAPI · Python AI/ML · DSA)
- **Section 5** — 6-hour & 12-hour practice timetables
- **Section 6** — 50+ rapid-fire Q&A bank

---
---

# SECTION 1 — THE FULL 60-MINUTE SIMULATED MOCK INTERVIEW

Run this end-to-end with a timer. For each question: read it, answer **out loud** before reading the model answer, then compare. The "weak answer" shows the trap; the "strong answer" is your target.

### ⏱️ Segment 1 — Warm-up & reconnect (0:00–0:05)

**Q1.1 — "Good to see you again, Smit. Since our last call, anything new you've built or thought about regarding what we discussed?"**

- ❌ *Weak:* "Not really, just been waiting for this round." (Passive, no initiative.)
- ✅ *Strong:* "Yeah — after our last conversation I went back and actually used both your apps end to end. I noted opportunities around Android reliability, device connectivity, app-size, and accessibility declarations, so I sketched out how I'd approach those. I also revisited that WiFi-to-cellular problem we discussed and dug into the exact Android multi-network API for it — happy to go deeper if useful." (Initiative, specificity, follow-through.)

**Q1.2 — "Tell me briefly about your current setup — what are you working on day to day?"**
- ✅ *Strong:* Keep it to 30 seconds — sole tech lead at AI Wellness (HIPAA-aware Flutter health app, 4 US clinics, 35 App Store releases in 7 months), tech lead at GenZDealZ (AI student marketplace, 10K+ users, GPT-5.4 Mini agent system). Then pivot: "But I'm looking to move into a single full-time focus, which is part of why Seekr interests me." *(This pre-loads the two-jobs answer — see v2 Part 12.)*

---

### ⏱️ Segment 2 — Architecture deep-dive (0:05–0:15)

This is confirmed territory — Reshika wants architecture. Use the framework in Section 2.1.

**Q2.1 — "Walk me through the architecture of your GenZGPT system. How does a user query actually flow through it?"**

- ❌ *Weak:* "I use GPT and LangGraph and it answers questions about deals." (Too shallow — no flow, no components, no reasoning.)
- ✅ *Strong:* Give the layered flow (full script in Section 2.2). Hit: entry (FastAPI) → discovery agent → embed query → semantic search over vector DB → GPT-5.4 Mini as reasoning brain with fallback algorithms → LangGraph routes to specialized agents (purchase/gift-card/recharge/shared-subscription) → response. Name the data flow and *why* each piece exists. End with a trade-off: "I chose a graph over one mega-prompt for deterministic routing, isolated testable nodes, and a money-decision guard so an LLM never directly triggers a payment."

**Q2.2 — "Why fine-tune a model at all? Why not just use GPT with a good prompt?"**
- ✅ *Strong:* "Different tools for different problems. Fine-tuning changes *behavior* — consistent tone, format, our domain's phrasing — and lets me shrink prompts so latency and token cost drop. RAG via the vector DB adds *knowledge* — the live deal catalogue that changes daily. I use both: fine-tuned GPT-5.4 Mini for how it talks and reasons about deals, RAG for what deals currently exist. Fine-tuning alone would go stale; RAG alone would be inconsistent in voice." *(This is the exact framing she'll respect — see Section 3.5.)*

**Q2.3 — "How is your Flutter app structured? Walk me through the layers."**
- ✅ *Strong:* Section 2.6 — presentation (GetX controllers + views) → domain (use cases, entities, repository interfaces) → data (repository impls, Firebase/REST/local sources). "I keep the data source behind a repository interface so the UI doesn't care whether data comes from Firestore or cache, and so it's mockable in tests."

---

### ⏱️ Segment 3 — Live coding (0:15–0:35) 🔴

They share a screen or ask you to. **Run the 5-step loop from v2 Part 1** (clarify → plan → narrate → test → reflect). Likely one of:

**Q3.1 — "Here's a stream of distance readings from the device, several per second (a `double`, metres). Alert the user when something's close, but don't spam them. Write it."**

This is the mock problem from our chat. Model solution (Dart):
```dart
class ObstacleAlerter {
  final double threshold;        // metres
  final Duration cooldown;       // min gap between alerts
  DateTime? _lastAlert;
  ObstacleAlerter({this.threshold = 2.0, this.cooldown = const Duration(seconds: 3)});

  /// Returns the phrase to speak, or null if no alert now.
  String? onReading(double distanceMetres, {DateTime? now}) {
    now ??= DateTime.now();
    if (distanceMetres >= threshold) return null;           // far enough → silent
    if (_lastAlert != null && now.difference(_lastAlert!) < cooldown) {
      return null;                                          // still cooling down
    }
    _lastAlert = now;
    return 'Obstacle ${distanceMetres.toStringAsFixed(1)} metres ahead';
  }
}
```
*Clarify first:* units? threshold value? cooldown length? negative/zero/garbage readings? *Edge cases:* readings exactly at threshold (use `>=` so 2.0 doesn't alert), rapid sub-threshold burst (cooldown suppresses), first-ever reading (no `_lastAlert` yet), out-of-order timestamps (you'd guard if real). *Reflect:* "O(1) per reading, O(1) memory. If I wanted to alert only on *approaching* obstacles I'd track the previous distance and require it to be decreasing."

**Q3.2 — Python variant (if they say "use Python"):**
```python
import time
class ObstacleAlerter:
    def __init__(self, threshold=2.0, cooldown=3.0):
        self.threshold = threshold
        self.cooldown = cooldown
        self._last = None
    def on_reading(self, distance, now=None):
        now = now if now is not None else time.time()
        if distance >= self.threshold:
            return None
        if self._last is not None and now - self._last < self.cooldown:
            return None
        self._last = now
        return f"Obstacle {distance:.1f} metres ahead"
```

**Q3.3 — Backup live tasks they might give instead** (all solved in Section 4):
- Build a counter / toggle / debounced search in Flutter (Sec 4.1).
- Parse a JSON API response and render a list (Sec 4.3 / v2 Part 4 Q7).
- A small DSA: two-sum, valid parentheses, group anagrams (Sec 4.5).

---

### ⏱️ Segment 4 — AI/ML deep-dive (0:35–0:45)

**Q4.1 — "Explain semantic search to me like I need to build it. How does it actually find the right deal?"**
- ✅ *Strong:* Section 3.3 — embed every deal into a vector once (offline), store in a vector DB. At query time, embed the user's text into the same space, find nearest vectors by cosine similarity (ANN index like HNSW for speed), return top-k. "Unlike keyword search, 'cheap phone top-up' matches a deal titled 'mobile recharge discount' because they're close in embedding space even with zero shared words."

**Q4.2 — "What's a vector database doing that a normal database can't?"**
- ✅ *Strong:* Section 3.2 — "A normal DB matches exact values or text. A vector DB indexes high-dimensional embeddings and answers 'nearest neighbours by similarity' fast, using approximate indexes like HNSW or IVF instead of scanning every row. That's what makes meaning-based retrieval feasible at scale."

**Q4.3 — "How do you stop the model from hallucinating a deal that doesn't exist?"**
- ✅ *Strong:* "Two guards. RAG grounds answers in retrieved real catalogue data — the model answers *from* what semantic search returned, not from memory. And a confidence threshold: if the top similarity score is too low, I fall back to a deterministic search or ask a clarifying question rather than letting it invent. I never let the LLM be the source of truth for facts."

**Q4.4 — "Your device sends images over WiFi at about 1 Mbps. How would you design that pipeline?"** (See Section 3.7 — this is a likely Reshika question and a chance to shine.)

---

### ⏱️ Segment 5 — Real-world scenario (0:45–0:50)

**Q5.1 — the WiFi/cellular problem (corrected answer in v2 Part 5 Q1 — multi-network binding API).**
**Q5.2 — "Two audio alerts fire at once — what happens?"** (Priority queue, v2 Part 5 Q2.)
**Q5.3 — "The device keeps disconnecting. What do you do?"** (Backoff state machine, v2 Part 5 Q3.)

---

### ⏱️ Segment 6 — Behavioral & commitment (0:50–0:55)

**Q6.1 — "You already have two roles. How do we know Seekr gets your full attention?"** 🔴 The make-or-break question. Full strategy in **v2 Part 12** — decide your real answer before Monday. Short version: "I'm transitioning to a single full-time focus; Seekr would be my primary commitment. No competitive overlap between healthcare, a marketplace, and assistive tech. And HKT is only 2.5 hours ahead, so real overlap isn't an issue."

**Q6.2 — "Why Seekr?"** (v2 Part 11 — mission + stack fit.)
**Q6.3 — "What's a weakness?"** (v2 Part 11 — solo dev → wants team review culture.)

---

### ⏱️ Segment 7 — Your questions (0:55–1:00)

Ask 3–4 from v2 Part 13. Strongest closers:
- "What state management + architecture is the current codebase on, so I know what I'd step into?"
- "Biggest pain at the app↔model boundary — latency, output phrasing, mode-switching?"
- "Does the device send raw inference labels or embeddings the app post-processes?"
- "Are Android reliability, device connectivity, or app-size reduction on the roadmap? Those feel like early wins I could own."

**Close:** "Thanks — this was a great conversation. I'm genuinely excited about the mission and I think my mobile + AI background is a strong fit. What are the next steps?"

---
---

# SECTION 2 — ARCHITECTURE MASTER

## 2.1 — How to explain ANY architecture in an interview (the framework)

Five sentences, in this order. Works for any system:
1. **Purpose** — what problem it solves, in one line.
2. **Shape** — the high-level layers/components (client → API → services → data).
3. **Flow** — trace one real request end to end.
4. **Key decision** — one notable trade-off and *why* you chose it.
5. **Hardening** — how it handles failure / scale / security.

Practice each system below until you can give it in ~60–90 seconds.

## 2.2 — GenZGPT backend architecture (the big one)

**Purpose:** Conversational AI over India's student-marketplace catalogue — answer deal/gift-card/recharge/subscription queries and drive actions.

**Shape (layers):**
```
[Flutter / Next.js client]
        │  HTTPS (REST/JSON)
        ▼
[FastAPI gateway]  ── auth, rate limiting, request validation (Pydantic)
        │
        ▼
[Orchestration layer — LangGraph]
   ┌─ Discovery agent  ── embeds query → semantic search (vector DB)
   ├─ Purchase agent
   ├─ Gift-card agent
   ├─ Recharge agent
   └─ Shared-subscription agent
        │                         │
        ▼                         ▼
[GPT-5.4 Mini (Azure OpenAI,   [Vector DB]  ←─ embeddings of deal catalogue
   fine-tuned) + fallback algos]      ▲
        │                              │ (offline) embedding pipeline re-indexes
        ▼                              │          when catalogue changes
[Business APIs / DB]  ── deals, payments ($100K+/mo), users (10K+)
   (GCP App Service hosting the backend)
```

**Flow (one query):** User asks "cheap recharge for Jio" → FastAPI validates + authenticates → discovery agent embeds the text and runs semantic search over the vector DB → top-k relevant deals returned → GPT-5.4 Mini (fine-tuned for our voice/format) reasons over the retrieved deals → if the intent is "recharge", LangGraph routes to the recharge agent which composes the action → response (and any action) returned as JSON.

**Key decision:** "Multi-agent graph over a single mega-prompt. As flows multiplied, one giant prompt got unreliable and impossible to test. A graph gives deterministic routing, isolated testable nodes, and a guard layer so an LLM *suggests* but a deterministic rule *decides* anything touching money."

**Hardening:** Fine-tune for behavior + RAG for facts (no stale knowledge, consistent voice); confidence threshold → deterministic fallback to avoid hallucinated deals; Pydantic schemas validate every payload; payment actions gated behind rule checks, never raw LLM output.

*(Verify against your `GCP-App-Service` repo: exact vector DB used, embedding model, how re-indexing is triggered, and the fallback algorithm specifics.)*

## 2.3 — AI Wellness Connect app architecture

**Purpose:** HIPAA-aware healthcare super app for 4 US clinics — AI avatar chat, telehealth video, therapy marketplace, payments.

**Shape:** Modular Flutter app (13 feature modules) on **GetX** (state + DI + routing) → repository layer → data sources: **FastAPI** backends (the AI/business logic), **Firebase** (Auth, Firestore, Analytics), third-party SDKs (ZEGOCLOUD video, HeyGen AI avatar, Stripe). Flavors: dev/qa/staging/prod with separate Firebase projects.

**Flow (book a therapy session):** UI → `BookingController` (GetX) → `BookingRepository` → FastAPI endpoint → confirm → Firestore write → Stripe checkout → analytics event logged.

**Key decision:** "Modular per-feature structure with a `Bindings` class per module, so each feature's controllers are lazy-loaded and disposed on route exit — keeps memory tight in a 13-module app."

**Hardening (HIPAA):** No PHI in logs ever — redaction layer; encrypted at rest (iOS Keychain / Android Keystore + AES-256); Firestore security rules segregate clinic + patient data; human approval on any outbound patient comms.

## 2.4 — AI Wellness Automation CRM architecture

**Purpose:** Personalized outreach to 10K+ healthcare leads — AI drafts, humans approve.

**Shape:** Pipeline — lead source → enrichment → Claude drafts message → **5 fail-CLOSED safety belts** → human approval queue → send. Backend FastAPI + Firebase/Firestore + scheduled tasks.

**The 5 belts (know these cold):** (1) 17-phrase financing-language validator blocks non-compliant drafts; (2) suppression-list check fails CLOSED if the list can't load; (3) daily send cap fails CLOSED if Firebase is unreachable; (4) Pydantic schema validators on every LLM output so malformed JSON can't reach the send path; (5) 3-channel allowlist duplicated at Firebase + Firestore + backend — all three must agree before any send. `ENABLE_AUTO_SEND=false` hardcoded in prod. 1,341 integration tests.

**Key decision / Hardening:** "Everything fails CLOSED. If any dependency is unavailable, the system *stops sending* rather than risk a non-compliant message. In healthcare, a silent halt is always safer than a wrong send."

## 2.5 — Seekr companion app — proposed Clean Architecture + the 1 Mbps image pipeline

If they ask "how would you architect our app," propose this:
```
Presentation:  Screens + GetX controllers (or match your existing BLoC/Riverpod)
Domain:        UseCases (PairDevice, StartMode, DescribeScene), Entities, Repo interfaces
Data:          DeviceDataSource (WiFi/EventChannel), CloudDataSource (Firebase/REST),
               LocalCache (Hive)
Services:      AudioQueue (priority TTS), ConnectivityService, TtsService, FirmwareUpdater
Flavors:       dev / qa / staging / prod
```
*Say:* "I'd hide device comms behind a `DeviceDataSource` interface, so when you move from the clip-on to glasses, only that layer changes — the rest of the app doesn't care whether frames arrive over WiFi or a new transport." (Shows you're thinking about their roadmap.)

The 1 Mbps image pipeline is its own discussion — **Section 3.7**.

## 2.6 — Generic Flutter app architecture (the JD asks for "app architecture")

Be ready to whiteboard this clean-architecture diagram and defend layer boundaries, dependency direction (presentation → domain ← data; domain depends on nothing), and where state management sits (presentation only). Mention testability: domain use cases are pure Dart, unit-testable without Flutter; repositories are mocked at the interface.

---
---

# SECTION 3 — AI/ML DEEP DIVE FOR RESHIKA

She's a computer-vision/ML engineer and is **keen on the vector DB, semantic search, and how data flows**. This is your highest-leverage section. Master the concepts; you don't need to out-research her, you need to converse precisely.

## 3.1 — Embeddings (the foundation)
An embedding is a fixed-length vector (e.g., 1,536 dims) that represents the *meaning* of text (or an image) as a point in space, where semantically similar things sit close together. You produce them with an embedding model (e.g., `text-embedding-3-small` on Azure OpenAI). "King − Man + Woman ≈ Queen" is the classic intuition: meaning becomes geometry.

## 3.2 — Vector databases
**What:** a store optimized for "find the nearest vectors to this one." **Why not a normal DB:** SQL matches exact values; a vector DB answers similarity at scale without scanning every row. **How:** an **ANN (approximate nearest neighbour)** index:
- **HNSW** (Hierarchical Navigable Small World) — graph-based, fast, high recall, most common default.
- **IVF** (Inverted File Index) — clusters vectors, searches nearest clusters; good for huge datasets.
- **Flat** — brute-force exact search; fine for small sets, slow at scale.

**Similarity metrics:** cosine (angle — most common for text), dot product, Euclidean (L2). **Tools:** Pinecone, Weaviate, Qdrant, Milvus, pgvector (Postgres extension), Azure AI Search (vector mode), FAISS (in-process library). *(Confirm which one your GenZGPT backend actually uses.)*

## 3.3 — Semantic search end-to-end
```
OFFLINE (indexing):
  for each deal:  text → embedding model → vector → store in vector DB (with deal id as metadata)
ONLINE (query):
  user text → same embedding model → query vector
            → vector DB ANN search (cosine) → top-k deal ids + scores
            → fetch full deals by id → return / feed to LLM
```
Key point to make: **the query and the documents must be embedded by the same model into the same space**, or distances are meaningless.

## 3.4 — RAG (Retrieval-Augmented Generation) pipeline
```
1. CHUNK     long docs → overlapping chunks (~200–500 tokens, ~10–20% overlap)
2. EMBED     each chunk → vector
3. STORE     vectors + metadata in vector DB        (steps 1–3 are offline/ingest)
4. RETRIEVE  query → embed → top-k similar chunks    (online)
5. AUGMENT   stuff retrieved chunks into the prompt as context
6. GENERATE  LLM answers FROM that context, with a citation/grounding
```
Why RAG: the model answers from *current, retrieved* facts instead of its frozen training data — fixes hallucination and staleness. For GenZGPT, the "documents" are deals; retrieval keeps answers tied to the live catalogue.

## 3.5 — Fine-tuning vs RAG vs prompt engineering (the decision Reshika will probe)
| Technique | Fixes | Use when |
|---|---|---|
| **Prompt engineering** | Quick behavior nudges | First thing to try; cheap; few edge cases |
| **RAG** | *Knowledge* — wrong/stale facts | Answers must reflect changing data (deals, policies) |
| **Fine-tuning** | *Behavior* — tone, format, consistency, prompt length | Model must reliably follow a style/format; prompts got fragile/expensive |

**The line that lands:** *"Wrong facts → RAG. Unreliable behavior → fine-tuning. Most production systems use both."* GenZGPT = fine-tuned GPT-5.4 Mini (voice/format/reasoning) **+** RAG (live deals).

**Azure OpenAI fine-tuning process (accurate as of 2025/26):**
1. Prepare **train + validation** data as **JSONL**, conversational format (system/user/assistant messages per line), UTF-8 + BOM, <512 MB/file. A few hundred high-quality examples minimum; more is better.
2. Select base model (e.g., GPT-4o-mini / 4.1 family — verify your exact deployment).
3. Upload files (`files.create(purpose="fine-tune")`).
4. Create the fine-tuning job (`fine_tuning.jobs.create(...)`), runs **async**; uses **LoRA** under the hood; hyperparameters = epochs, batch size, learning-rate multiplier.
5. Check status → **deploy** the resulting model (incurs an **hourly hosting cost**; idle deployments auto-delete after ~15 days).
6. Use via Chat Completions with the fine-tuned model id. Iterate using the validation metrics.

*Say:* "If the model misbehaves after tuning, the answer is almost always in the training data — I audit examples first before touching hyperparameters."

## 3.6 — "Data flowing through the channels" (three things she might mean — be ready for all)

**(a) GenZGPT data flow** — covered in 2.2/3.3: query → embed → vector DB → retrieved deals → LLM → response. Emphasize it's grounded retrieval, not free generation.

**(b) Flutter platform channels (Dart ↔ native)** — how Flutter talks to native Android/iOS:
- **MethodChannel** — request/response (call native once, get a value). E.g., "get battery level," "bind to cellular."
- **EventChannel** — a *stream* from native to Dart. **This is how the device's continuous distance/sensor readings would flow into the app.**
- **BasicMessageChannel** — bidirectional arbitrary messages.
Code in Section 4.2.

**(c) Device → phone data channel** — the WiFi link carrying frames/results; bandwidth-bound at ~1 Mbps → Section 3.7.

## 3.7 — The 1 Mbps WiFi image pipeline (likely Reshika question — own it) 🎯

**The constraint:** ~1 Mbps ≈ 125 KB/s from device to phone.

**Do the math out loud (this impresses):**
- 640×480 JPEG (moderate quality) ≈ 50–100 KB → only ~1–2 frames/sec. Too choppy.
- 320×240 JPEG (well-compressed) ≈ 15–25 KB → ~5–8 fps. Workable for scene description.
- Grayscale halves payload again when the CV task doesn't need color.

**Strategies to fit the budget:**
1. **Downscale resolution** to the minimum the model needs.
2. **Tune JPEG quality** aggressively; consider WebP.
3. **Adaptive frame rate** — only send a frame when the scene changes (on-device frame differencing / motion detection), not a constant stream.
4. **Region-of-interest cropping** — send only the relevant patch (e.g., the text block for OCR).
5. **Keyframe + delta** encoding for video-like streams.
6. **The better architecture — push inference to the edge:** run detection ON the device and transmit only the *result* (labels, depth value, OCR text) — bytes, not images. Then 1 Mbps is plenty. This aligns with Seekr's edge-AI thesis.

**The senior framing:** "At 1 Mbps the real question is *what* you send, not *how fast*. For latency-critical safety (obstacle/depth) I'd run inference on the device and send tiny result payloads. For heavier on-demand tasks like reading a menu, I'd send a single cropped, compressed frame when the user triggers it. A constant raw video stream is the wrong design at this bandwidth."

**Transport note:** UDP for drop-tolerant frame streaming (low latency), TCP/WebSocket for reliable control + critical alerts; for safety-critical alerts you might add a lightweight app-level ACK even over UDP.

## 3.8 — Computer vision quick reference (from v2 Part 10, condensed)
- **CNN** = conv (feature filters) → pooling (downsample) → ReLU → classify.
- **Object detection** real-time → single-shot **YOLO/SSD** (fast) vs two-stage R-CNN (accurate, slow). Wearable → YOLO/SSD + quantization.
- **OCR** = preprocess (grayscale/threshold/deskew) → detect text regions → recognize (CNN+RNN/CTC or transformer). On-device: ML Kit / Tesseract.
- **Edge optimization** = quantization (FP32→INT8, ~4× smaller), pruning, distillation; TFLite / TFLite Micro.
- **Precision vs recall for a safety device:** bias toward **recall** — a missed obstacle (false negative) is dangerous; a false alarm (low precision) is just annoying. Lower the confidence threshold to catch more, accept some false positives. **Say this — it shows ML + product + safety judgment.**

## 3.9 — 20 AI/ML Q&A at Reshika's level

1. **Embedding?** Fixed-length vector capturing meaning; similar items are close in space.
2. **Why cosine not Euclidean for text?** Cosine measures angle (direction/meaning), insensitive to vector magnitude/length differences common in text embeddings.
3. **What is ANN and why approximate?** Exact nearest-neighbour is O(n) per query; ANN (HNSW/IVF) trades a tiny recall loss for massive speed at scale.
4. **HNSW in one line?** A multi-layer navigable graph you greedily traverse to nearest neighbours — fast, high recall.
5. **Chunking strategy for RAG?** ~200–500 tokens with ~10–20% overlap so context isn't cut mid-thought; tune to your docs.
6. **Top-k tradeoff?** Too small → miss context; too large → noise + token cost + latency. Tune empirically.
7. **How do you evaluate a RAG system?** Retrieval (recall@k, MRR) + generation (faithfulness/groundedness, answer relevance); human spot-checks.
8. **Fine-tune vs RAG?** Behavior vs knowledge. Often both.
9. **JSONL fine-tune format?** One JSON object per line; chat format with system/user/assistant messages.
10. **How many examples to fine-tune?** Hundreds minimum, thousands ideal; quality > quantity.
11. **LoRA?** Low-Rank Adaptation — trains small adapter matrices instead of all weights; cheaper, faster, what Azure uses.
12. **Stop hallucinations?** Ground with RAG; confidence threshold → fallback/clarify; never let the LLM be the fact source.
13. **CNN vs transformer for vision?** CNNs strong + efficient on-device; vision transformers can beat them with enough data/compute but are heavier — on a wearable, CNN + quantization wins.
14. **Quantization cost?** ~4× smaller/faster, small accuracy drop; essential for embedded ICs.
15. **Precision vs recall for obstacle detection?** Favor recall — missing a real obstacle is the dangerous failure.
16. **Why edge AI for Seekr?** Latency (can't wait on a round trip), offline, privacy (image never leaves device).
17. **Semantic vs keyword search?** Semantic matches meaning via embeddings; keyword matches tokens. Semantic finds "mobile top-up" for "recharge."
18. **Embedding model must match?** Yes — query and docs embedded by the same model into the same space.
19. **Cold-start re-indexing?** When catalogue changes, re-embed changed items and upsert into the vector DB; don't rebuild everything.
20. **Where does GPT-5.4 Mini sit in your stack?** Reasoning brain after retrieval — it composes the answer from the deals semantic search returned, with fallback algorithms for low-confidence cases.

---
---

# SECTION 4 — CODING PRACTICE SETS (with full solutions)

Type every solution by hand. Don't read it until you've attempted it.

## 4.1 — Flutter + GetX state management (your primary stack)

**4.1.1 — Reactive list with loading/error states in a GetX controller.**
```dart
class DealController extends GetxController {
  final DealRepository _repo;
  DealController(this._repo);

  final deals = <Deal>[].obs;
  final isLoading = false.obs;
  final error = RxnString();          // nullable reactive string

  @override
  void onInit() { super.onInit(); fetchDeals(); }

  Future<void> fetchDeals() async {
    try {
      isLoading.value = true;
      error.value = null;
      deals.value = await _repo.getDeals();
    } catch (e) {
      error.value = 'Failed to load deals';
    } finally {
      isLoading.value = false;
    }
  }
}

// View:
class DealView extends StatelessWidget {
  const DealView({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.put(DealController(Get.find()));
    return Obx(() {
      if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (c.error.value != null) return Center(child: Text(c.error.value!));
      if (c.deals.isEmpty) return const Center(child: Text('No deals'));
      return ListView.builder(
        itemCount: c.deals.length,
        itemBuilder: (_, i) => ListTile(title: Text(c.deals[i].title)),
      );
    });
  }
}
```
*Talk to:* `.obs` makes observables; `Obx` rebuilds only what it reads; `Get.put` registers for DI; `RxnString` handles nullable reactive state; dispose is automatic with GetX.

**4.1.2 — Dependency injection with Bindings.**
```dart
class DealBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DealRepository>(() => DealRepositoryImpl(Get.find()));
    Get.lazyPut<DealController>(() => DealController(Get.find()));
  }
}
// Route: GetPage(name: '/deals', page: () => const DealView(), binding: DealBinding());
```

**4.1.3 — Debounced reactive search with GetX + worker.**
```dart
class SearchController extends GetxController {
  final query = ''.obs;
  final results = <String>[].obs;
  @override
  void onInit() {
    super.onInit();
    debounce(query, (_) => _search(query.value),
        time: const Duration(milliseconds: 400));   // GetX built-in debounce worker
  }
  Future<void> _search(String q) async { /* call API, set results */ }
}
```
*Nice flex:* "GetX has `debounce`, `ever`, `once`, `interval` workers — I don't need a manual Timer for this."

**4.1.4 — Pass data between screens with GetX routing.**
```dart
Get.toNamed('/detail', arguments: {'id': 5});
// On detail:
final args = Get.arguments as Map;
final id = args['id'] as int;
final result = await Get.toNamed('/picker');   // await a returned value
Get.back(result: 'chosen');                      // return it
```

**4.1.5 — Global state shared across screens (a cart/session).**
```dart
class SessionController extends GetxController {
  final user = Rxn<User>();
  bool get isLoggedIn => user.value != null;
  void login(User u) => user.value = u;
  void logout() => user.value = null;
}
// Register once at app start: Get.put(SessionController(), permanent: true);
// Read anywhere: Get.find<SessionController>().isLoggedIn;
```

## 4.2 — Native Android / platform channels

**4.2.1 — MethodChannel: read battery from native (request/response).**
```dart
// Dart
class DeviceApi {
  static const _ch = MethodChannel('seekr/device');
  Future<int> batteryLevel() async =>
      await _ch.invokeMethod<int>('getBatteryLevel') ?? -1;
}
```
```kotlin
// Android (MainActivity.kt)
class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(engine: FlutterEngine) {
    super.configureFlutterEngine(engine)
    MethodChannel(engine.dartExecutor.binaryMessenger, "seekr/device")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getBatteryLevel" -> {
            val bm = getSystemService(BATTERY_SERVICE) as BatteryManager
            result.success(bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY))
          }
          else -> result.notImplemented()
        }
      }
  }
}
```

**4.2.2 — EventChannel: stream device distance readings into Dart (the real Seekr pattern).**
```dart
// Dart
class DeviceStream {
  static const _ev = EventChannel('seekr/distance_stream');
  Stream<double> distances() =>
      _ev.receiveBroadcastStream().map((e) => (e as num).toDouble());
}
// Use with the ObstacleAlerter from Section 1:
final alerter = ObstacleAlerter();
DeviceStream().distances().listen((d) {
  final phrase = alerter.onReading(d);
  if (phrase != null) tts.speak(phrase);
});
```
```kotlin
// Android — emit readings
EventChannel(messenger, "seekr/distance_stream").setStreamHandler(
  object : EventChannel.StreamHandler {
    override fun onListen(args: Any?, sink: EventChannel.EventSink) {
      // on each sensor reading: sink.success(distanceMetres)
    }
    override fun onCancel(args: Any?) { /* stop sensor */ }
  })
```

**4.2.3 — Multi-network route selection (the corrected WiFi answer, native side).** See v2 Part 5 Q1 — `WifiNetworkSpecifier` for local-only device AP + `requestNetwork(TRANSPORT_CELLULAR + NET_CAPABILITY_INTERNET)` for cellular; avoid process-wide `bindProcessToNetwork()` as the default.

## 4.3 — FastAPI / app services (your backend stack)

**4.3.1 — Endpoint with validation + error handling.**
```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class Query(BaseModel):
    text: str
    user_id: str

class Deal(BaseModel):
    id: str
    title: str
    price: float

@app.post("/search", response_model=list[Deal])
async def search(q: Query):
    if not q.text.strip():
        raise HTTPException(status_code=400, detail="Query cannot be empty")
    return await semantic_search(q.text)     # returns list[Deal]
```

**4.3.2 — Call the fine-tuned Azure OpenAI model.**
```python
from openai import AzureOpenAI
client = AzureOpenAI(
    api_key=KEY, azure_endpoint=ENDPOINT, api_version="2024-10-01-preview")

def ask_genzgpt(user_q: str, context: str) -> str:
    resp = client.chat.completions.create(
        model="genzgpt-ft-v1",                 # your deployed fine-tuned model
        messages=[
            {"role": "system", "content": "You are GenZGPT. Answer only from the provided deals."},
            {"role": "system", "content": f"Deals:\n{context}"},   # RAG context
            {"role": "user", "content": user_q},
        ],
        temperature=0.3,
    )
    return resp.choices[0].message.content
```

**4.3.3 — Minimal semantic-search endpoint (embed → search → ground → generate).**
```python
@app.post("/ask")
async def ask(q: Query):
    qvec = await embed(q.text)                       # query embedding
    hits = vector_db.search(qvec, top_k=5)           # ANN search
    context = "\n".join(f"{h.title} — ${h.price}" for h in hits)
    answer = ask_genzgpt(q.text, context)            # RAG generation
    return {"answer": answer, "sources": [h.id for h in hits]}
```

**4.3.4 — Dependency injection + async DB (FastAPI idiom).**
```python
from fastapi import Depends

async def get_db():
    db = await connect()
    try:
        yield db
    finally:
        await db.close()

@app.get("/deals/{deal_id}", response_model=Deal)
async def get_deal(deal_id: str, db = Depends(get_db)):
    deal = await db.fetch_deal(deal_id)
    if deal is None:
        raise HTTPException(404, "Deal not found")
    return deal
```

## 4.4 — Python AI/ML coding set

**4.4.1 — Cosine similarity (from scratch + numpy).**
```python
import math
def cosine(a, b):
    dot = sum(x*y for x, y in zip(a, b))
    na, nb = math.sqrt(sum(x*x for x in a)), math.sqrt(sum(y*y for y in b))
    return 0.0 if na == 0 or nb == 0 else dot / (na * nb)

# numpy (faster, what you'd actually use):
import numpy as np
def cosine_np(a, b):
    a, b = np.array(a), np.array(b)
    return float(a @ b / (np.linalg.norm(a) * np.linalg.norm(b) + 1e-9))
```

**4.4.2 — Top-k nearest by cosine (mini vector search).**
```python
import numpy as np
def top_k(query, docs, k=5):
    q = np.array(query)
    M = np.array(docs)                                  # (n, d)
    sims = M @ q / (np.linalg.norm(M, axis=1) * np.linalg.norm(q) + 1e-9)
    idx = np.argsort(sims)[::-1][:k]                    # highest first
    return [(int(i), float(sims[i])) for i in idx]
```

**4.4.3 — Confidence-gated retrieval (your hallucination guard).**
```python
def retrieve_or_fallback(query, docs, k=3, min_sim=0.75):
    hits = top_k(query, docs, k)
    strong = [h for h in hits if h[1] >= min_sim]
    if not strong:
        return {"action": "clarify", "msg": "Could you tell me which deal type you mean?"}
    return {"action": "answer", "hits": strong}
```

**4.4.4 — Sliding-window rate limiter (your CRM send-cap logic).**
```python
from collections import deque
import time
class RateLimiter:
    def __init__(self, max_calls, window):
        self.max_calls, self.window, self.calls = max_calls, window, deque()
    def allow(self):
        now = time.time()
        while self.calls and self.calls[0] <= now - self.window:
            self.calls.popleft()
        if len(self.calls) < self.max_calls:
            self.calls.append(now); return True
        return False
```

**4.4.5 — Moving average for sensor smoothing.**
```python
from collections import deque
def moving_average(readings, k):
    if k <= 0 or not readings: return []
    out, win, total = [], deque(), 0.0
    for r in readings:
        win.append(r); total += r
        if len(win) > k: total -= win.popleft()
        if len(win) == k: out.append(total / k)
    return out
```

## 4.5 — DSA set (easy–medium, Dart + Python)

**4.5.1 Two Sum**, **4.5.2 Valid Parentheses**, **4.5.3 Group Anagrams**, **4.5.4 Binary Search**, **4.5.5 Reverse Linked List** — all in **v2 Part 7**. Below are 3 more common ones:

**4.5.6 — Kadane's max subarray sum.**
```python
def max_subarray(nums):
    best = cur = nums[0]
    for n in nums[1:]:
        cur = max(n, cur + n)
        best = max(best, cur)
    return best
```

**4.5.7 — Merge intervals.**
```python
def merge(intervals):
    intervals.sort(key=lambda x: x[0])
    out = [list(intervals[0])]
    for s, e in intervals[1:]:
        if s <= out[-1][1]:
            out[-1][1] = max(out[-1][1], e)
        else:
            out.append([s, e])
    return out
```

**4.5.8 — BFS level order (deque).**
```python
from collections import deque
def bfs_levels(root):
    if not root: return []
    out, q = [], deque([root])
    while q:
        level = []
        for _ in range(len(q)):
            node = q.popleft()
            level.append(node.val)
            if node.left: q.append(node.left)
            if node.right: q.append(node.right)
        out.append(level)
    return out
```

---
---

# SECTION 5 — PRACTICE TIMETABLES

## 🕐 6-HOUR INTENSIVE (one focused day)

| Block | Time | Focus |
|---|---|---|
| 1 | 45 min | v2 Parts 2–3 syntax reload — type every block by hand in DartPad / Python |
| 2 | 60 min | Section 4.1 (GetX) + 4.2 (platform channels) — type all, run what you can |
| 3 | 45 min | Section 4.3 (FastAPI) + 4.4 (Python AI/ML) — type all |
| 4 | 45 min | Section 4.5 + v2 Part 7 (DSA) — solve aloud, then check |
| 5 | 60 min | Section 3 (AI/ML) — read twice; say 3.5, 3.7, and the precision/recall point out loud |
| 6 | 45 min | Section 2 (architecture) — rehearse GenZGPT + Flutter app scripts until smooth |
| 7 | 30 min | Section 1 — run the full mock, timed, out loud |

## 🕛 12-HOUR DEEP (split over 2 days — recommended: Thu + Sat)

**Day 1 (6h) — Build the muscle:**
- 90 min — syntax reload + 20 DSA problems aloud (v2 Part 7 + 4.5).
- 120 min — Flutter/GetX (4.1) + native channels (4.2): build each from scratch twice.
- 90 min — FastAPI (4.3) + Python AI/ML (4.4): build from scratch.
- 60 min — the ObstacleAlerter mock (Sec 1 Q3.1) + 2 unseen LeetCode-easy, recorded, talking aloud.

**Day 2 (6h) — Tell the story:**
- 90 min — Section 3 AI/ML end to end; teach it to an empty room (or rubber duck).
- 90 min — Section 2 architecture; whiteboard GenZGPT + Flutter layers from memory.
- 60 min — v2 Part 11 behavioral + Part 12 two-jobs answer, out loud until natural.
- 60 min — full timed mock (Section 1), record yourself, note every freeze.
- 60 min — review weak spots; finalize Part 16 cheat sheet; download + try both Seekr apps.

---
---

# SECTION 6 — RAPID-FIRE Q&A BANK (50+)

**Flutter / Dart**
1. setState vs GetX? Local ephemeral vs app-wide reactive + DI.
2. `final` vs `const`? Runtime once vs compile-time constant.
3. Stateless vs Stateful? No internal state vs persists via State object.
4. Keys — why? Preserve element identity across rebuilds (lists).
5. Hot reload vs restart? Reload keeps state; restart resets.
6. FutureBuilder vs StreamBuilder? One value vs many over time.
7. `Obx` vs `GetBuilder`? Reactive auto vs manual `update()`.
8. Prevent rebuilds? `const`, scoped `Obx`, lift state correctly.
9. mounted check — why? Avoid setState after dispose post-await.
10. AAB vs APK? Bundle (Play assembles per-device) vs full package.
11. Build modes? Debug / Profile / Release.
12. pubspec.yaml? Deps, assets, versioning, flavors config.
13. Mixins? Reuse across classes (no multiple inheritance).
14. Isolates? True parallelism; heavy work off the UI thread.
15. async* / yield? Define a Stream.

**Architecture / engineering**
16. Clean Architecture layers? Presentation / Domain / Data.
17. Repository pattern? Abstracts data source from UI.
18. Dependency direction? Domain depends on nothing; others point inward.
19. Why flavors? One codebase, isolated envs (dev/qa/staging/prod).
20. Debounce vs throttle? Wait-til-stop vs at-most-once-per-interval.
21. Offline-first? Core works without network; cloud syncs later.
22. Optimistic UI? Update UI before server confirms; roll back on fail.
23. Idempotency? Same request twice = same effect (GET/PUT/DELETE).

**AI / ML** (full answers in Section 3.9)
24. Embedding? 25. Vector DB vs SQL? 26. HNSW? 27. Cosine vs Euclidean? 28. RAG stages? 29. Chunking? 30. Fine-tune vs RAG? 31. JSONL format? 32. LoRA? 33. Hallucination guards? 34. Edge vs cloud AI? 35. Quantization? 36. Precision vs recall (safety)? 37. CNN layers? 38. YOLO vs R-CNN? 39. OCR pipeline? 40. Semantic vs keyword search?

**Backend / FastAPI**
41. Why FastAPI? Async, Pydantic validation, auto docs, speed.
42. Pydantic? Schema validation + serialization.
43. Dependency injection in FastAPI? `Depends()`.
44. Sync vs async endpoint? Async for IO-bound (DB, API calls).
45. Status codes? 200/201/400/401/403/404/500.

**Git / process**
46. Merge vs rebase? Merge commit vs linear replay.
47. Resolve conflict? Edit markers, add, continue.
48. Conventional commits? feat/fix/chore/refactor.
49. Agile ceremonies? Standup, planning, retro, demo.
50. Code review focus? Correctness, error paths, tests, semantics, no debug cruft.

**Seekr-specific**
51. 1 Mbps image pipeline? Send results not raw frames; compress + adaptive rate (Sec 3.7).
52. Accessibility must-haves? Semantics labels, 56dp targets, contrast, dark mode, audio-first.
53. Audio collision? Priority queue, safety interrupts (v2 Part 5 Q2).
54. WiFi→cellular? Multi-network binding API (v2 Part 5 Q1).
55. Two-jobs answer? Transitioning to single full-time focus (v2 Part 12).

---

*This workbook + the v2 reference doc together cover everything realistic for Monday. Pick the 6h or 12h plan, type every line of code by hand, say every architecture script out loud, and decide your two-jobs answer tonight. You've got the substance — now drill it into reflex. Good luck, Smit.*

— **Want live reps?** Reply "mock me" and I'll run you through unseen problems one at a time, score each like Reshika, and show the gold-standard answer after each attempt.
