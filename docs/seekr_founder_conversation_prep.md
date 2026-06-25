# 🎯 SEEKR ROUND 2 — FOUNDER CONVERSATION + LIVE DEMO PREP

**When:** Mon Jun 29 · 4:00–5:00 PM HKT = 1:30–2:30 PM IST
**Room:** **Turzo Bose (CEO)** + **Reshika P V (CTO)** — both technical founders
**Format:** Judgment-based conversation (qualifications · contribution · team fit) **+ a confirmed live coding round** ("have your laptop ready")
**Companion docs:** `seekr_round2_coding_prep.md` (v2, syntax + coding), `seekr_round2_mock_and_practice_system.md` (mock + architecture + AI/ML). **This doc = the founder conversation + the live demo.**

---

## 0 — HOW TO WALK IN

The room is the two people who *built* this company. Turzo started Seekr from a personal place — self-driving-car perception miniaturised into a wearable, sparked by his own visually impaired grandfather during COVID. Reshika built the vision models. They are not running a checkbox interview; they're deciding **"do we want Smit on our small team, can he own the mobile side, and do we trust his judgment?"**

Three things they're scoring (Lamia said it plainly): **qualifications, contribution, fit** — plus a **live coding round** because they want to see you think and build in real time. So bring two modes:
1. **Senior peer in conversation** — calm, specific, opinionated-but-humble, mission-aligned.
2. **Builder at the keyboard** — clarify → plan aloud → code → test (the 5-step loop from v2 Part 1).

**Tone:** You're not begging for a job; you're exploring whether this is the right place to do your best work. That posture reads as senior. Be warm, direct, low-ego, metric-led.

---

## 1 — YOUR 30-SECOND INTRO (founder-tuned)

> "I'm a Flutter + Python developer, three years in, and I lead mobile end to end. My main role has been sole tech lead on AI Wellness Connect — a HIPAA-aware healthcare app live in four US clinics, where I shipped 35 App Store releases in seven months. I also consult as a tech lead for GenZDealZ, India's AI student marketplace — 10K+ users, and I built its multi-agent assistant on a fine-tuned GPT-5.4 Mini. That AI Wellness engagement is wrapping up at the end of June, so I'm looking for one focused place to go deep — and Seekr stood out because it's assistive tech that genuinely changes lives, with the kind of real-time, accessibility-first mobile challenges I'm best at."

That last clause does triple duty: signals availability, signals mission-fit, and pivots to why *them*.

---

## 2 — COMMITMENT & AVAILABILITY (the question that decides it) ✅ CORRECTED

This was the biggest risk in earlier prep — now it's a **strength**, because the honest facts are clean. Memorize this and say it without a flicker of hesitation.

**The facts you'll state:**
- GenZDealZ is a **consulting engagement** — not full-time. *(If you described it as "Tech Lead" in Round 1, say "I consult as a tech lead there" so the two never contradict.)*
- The **AI Wellness engagement is winding down at the end of June.**
- You're **fully available from July 1st**, including weekends, and you work hard.
- **No conflict of interest** — healthcare, a student marketplace, and assistive tech don't overlap.

**Q: "You have other roles — how do we know Seekr gets your full focus?"**
> "Fair question, and the timing actually lines up cleanly. My AI Wellness engagement wraps up at the end of June, and GenZDealZ is a consulting arrangement, not a full-time job. So from July 1st I'm fully available to commit to Seekr as my primary focus — including weekends when something needs to ship. There's no competitive overlap between the three either. I'm looking to go deep on one product, and I'd want that to be Seekr."

**Q: "Can you work Hong Kong hours from India?"**
> "Easily — HKT is only two and a half hours ahead of IST, so our working days overlap almost entirely. I'll be online for your core hours and standups. For context, my US client is 10+ hours offset and I've made that work async for months, so a 2.5-hour gap is comfortable."

**Q: "Why is AI Wellness ending — anything we should know?"**
> "The project is winding down on the business side — nothing to do with the engineering, which is live and shipping. It's actually why the timing works for me to commit fully here."

**Do NOT:** downplay it, hide the consulting role, or over-promise impossible hours. The honest version is already strong.

---

## 3 — "HOW CAN YOU CONTRIBUTE?" (Lamia named this — have it crisp)

Lead with the **highest-leverage, most specific** items. These are mapped to gaps you found in their actual apps — frame them as opportunities, **not criticism of the founders' work**.

1. **Improve companion-app reliability and Android experience.** "Your user base in India and China skews heavily Android, so I'd focus early on Android reliability, device connectivity, app size, and release quality across both stores."
2. **Run an accessibility audit + declare it.** "Both apps currently declare no accessibility features on the App Store, so VIP users searching with accessibility filters can't find you. I'd audit every screen with TalkBack/VoiceOver in week one and declare the features — a credibility and discoverability win for an app built *for* this community."
3. **The 1 Mbps device pipeline.** "At ~1 Mbps the real lever is sending inference *results* from the edge, not raw frames — bytes, not images. I'd help design that so latency-critical alerts stay instant." *(Full reasoning: mock-and-practice doc Section 3.7.)*
4. **Firebase Analytics for the ML feedback loop.** "I'd instrument mode usage, inference latency, and TTS-replay events — that data feeds straight back into Reshika's model improvement cycle."
5. **Release velocity + CI/CD + flavors.** "I'd set up dev/qa/staging/prod flavors and a CI pipeline so releases go from occasional to predictable and safe — I shipped 35 in seven months solo with that discipline."
6. **App-size reduction.** "The app is large on disk, likely bundled ML assets — deferring those to first-launch download removes an install barrier for elderly users on older phones."
7. **Code review + documentation culture.** "On a small team a second set of eyes per PR is the highest-ROI quality habit — I bring test and handover discipline (1,341 tests on the CRM)."

**Delivery tip:** name 2–3 out loud, then say "happy to go deeper on any of these." Don't machine-gun all seven.

---

## 4 — MISSION FIT (this matters a lot with Turzo)

Turzo built Seekr for a personal reason. Show you understand *why it exists*, not just *what it does*.

- **Know the origin (don't recite it robotically, weave it in):** the idea came from wanting to give independence to the visually impaired — designed *for and with* that community. (Lamia uses the phrase "designed for and with"; echo it naturally.)
- **Your bridge line:** "I've spent the last year building for clinic patients where a bug has real consequences. That raises your engineering standards in a way a typical app doesn't. Seekr is the same — a missed obstacle alert isn't a cosmetic bug, it's someone's safety. I want to build where that weight exists."
- **Show product-level care, not just code:** reference the real user who asked for **dark mode / smart-invert** (from the App Store review) — "your users are telling you what they need; I'd treat that feedback as the roadmap."
- **The glasses vision:** "Moving from a clip-on to glasses raises the bar on power, heat, and edge-model efficiency, and shifts the app toward setup, OTA firmware updates, and a caregiver layer. That's exactly the app-side ownership I'd want as the hardware evolves." *(Don't claim inside knowledge — frame as reasoning.)*

---

## 5 — ARCHITECTURE YOU'D FOLLOW (and your demo embodies it)

When they ask "how would you structure our app" (likely — they care about architecture), give this, then note you'd adapt to their existing codebase:

**Clean Architecture + GetX (my stack):**
```
Presentation   Screens + GetX controllers (reactive state, DI)
Domain         UseCases (PairDevice, StartMode, DescribeScene), Entities, Repo interfaces
Data           Repository impls + data sources:
                 • DeviceDataSource  (WiFi/EventChannel — the wearable)
                 • CloudDataSource   (Firebase / REST)
                 • LocalCache        (Hive, offline-first)
Services        AudioQueue (priority TTS), ConnectivityService, TtsService, FirmwareUpdater
Flavors         dev / qa / staging / prod  (separate Firebase projects + API URLs)
```

**The one decision to emphasize:** "I hide device communication behind a `DeviceDataSource` interface. So when you go from the clip-on to glasses, only that layer changes — the rest of the app doesn't care whether frames arrive over WiFi today or a new transport tomorrow. It's also what makes the whole thing unit-testable, because I can mock the device."

**This is exactly what the demo I built demonstrates** — so you can say "I actually prototyped this; let me show you" (Section 8).

---

## 6 — JD DECODE: WHAT THEY *REALLY* WANT (ultrathink)

The JD looks generic. Read the subtext — this is what gets you the offer:

| JD line | Surface ask | What they actually want |
|---|---|---|
| "Android applications… high-quality, efficient, scalable" + Flutter | Android dev | **Anchor the mobile function** so the founders can focus on hardware + ML. Android reliability, app size, and release quality are likely high-leverage areas. |
| "Identifying and resolving… performance bottlenecks" | Bug fixing | Real latency/battery/bandwidth problems (1 Mbps stream, real-time audio). They want someone who's wrestled production performance — you have. |
| "Conducting regular code reviews… code quality" | Process | They're scaling past founder-only code; they want **senior discipline** and someone juniors can learn from. |
| "Providing technical guidance to other team members" | Teamwork | **Lead/mentor signal.** You're a Tech Lead — say it. They may want their first senior mobile hire to set standards. |
| "Collaborating with Business and AI teams" | Soft skill | The app dev is the **bridge between Reshika's ML and the product**. You must speak both — and you do (you've shipped production ML). |
| "Integrating databases, Firebase Analytics" + title "Database Management" | Firebase | **Firestore depth matters** — analytics that feed the ML loop, secure per-user data. Your AIW Firebase work maps directly. |
| "TestFlight, App Store, Google Store" | Publishing | They want someone who owns **both pipelines** end to end. |
| "Updated with current trends… learn and adapt" | Buzzword | Small startup, fast pivots (clip-on → glasses). They want someone who **ramps on the unknown fast** — your ZEGOCLOUD-in-5-days story proves it. |

**Out-of-the-box reads to voice if it fits:**
- "It looks like you need someone to own mobile end to end so you two can stay focused on the device and the models — that's the role I'd want."
- "Android reliability, device connectivity, and app-size reduction feel like immediate high-leverage areas I'd inspect first."

---

## 7 — THE LIVE DEMO (your differentiator) 🚀

I built you a **running, accessibility-first Flutter prototype** that simulates the Seekr companion app. It's in the `seekr_companion_demo/` folder with its own README. Read that README for exact run steps and the full walkthrough script. Key points here:

**What it shows (every one maps to their JD + product):**
- **GetX state management + Clean Architecture** (your stack, their JD).
- **Device-comms behind an interface** — a simulated WiFi data stream (your "future-proof for glasses" point, live).
- **The 4 modes** (text recognition, scene detection, depth/obstacle, supermarket).
- **Priority audio queue** — safety alerts interrupt descriptions (the real "one earpiece, many announcements" problem).
- **Obstacle alerter with cooldown** — alerts under 2m, then stays quiet 3s (anti-spam).
- **Real accessibility** — Semantics labels, live regions, `SemanticsService.announce`, large text, **dark mode** (the exact thing a real user requested in their reviews).
- **Flavors** (dev/qa/staging/prod) wired in.
- **Actual TTS** via `flutter_tts` (speaks out loud in Chrome) + a visible "now speaking" log so it demos even with no audio.

**How to use it in the room (don't hijack — ask first):**
> "I actually built a small prototype over the weekend to show how I'd approach the companion app's architecture and accessibility — it simulates the device with a mock data stream, so it's my own illustration of approach, not a copy of your product. Would it help if I shared my screen and walked through it for a few minutes?"

Keep it to **3–4 minutes**. Walk the **architecture → accessibility → the audio-priority problem**, then stop and invite questions. The walkthrough script is in the demo README.

**⚠️ Run it on your machine TODAY** (Chrome: `flutter run -d chrome`). A demo that fails live is worse than none. Have a **screen-recording backup** in case the room's screen-share or your network glitches.

---

## 8 — PERSONALIZED FOUNDER Q&A (your answers, your voice)

Answer out loud; keep each tight. Metrics over adjectives.

**Intro / fit**
1. **"Tell us about yourself."** → Section 1 intro.
2. **"Why Seekr?"** → mission + stack fit; "build where a bug has real consequences."
3. **"Why are you leaving your current work?"** → "AI Wellness engagement is winding down; I want one focused place to go deep."
4. **"What kind of role do you want?"** → "Own the mobile function end to end, work closely with the AI side, grow as the product scales to glasses."

**Technical / architecture**
5. **"Walk us through something you've built."** → GenZGPT or AI Wellness (architecture scripts: mock-and-practice doc Section 2).
6. **"How would you architect our app?"** → Section 5 + offer the demo.
7. **"How does your GenZGPT system work?"** → discovery agent → embed → vector DB semantic search → GPT-5.4 Mini brain + fallback → LangGraph routes purchase/gift-card/recharge/subscription agents. (Money actions: LLM suggests, rule decides.)
8. **"Fine-tuning vs RAG — why both?"** → "Fine-tune changes *behavior/voice*; RAG adds *live knowledge*. GenZGPT uses fine-tuned GPT-5.4 Mini for how it reasons + RAG for the current deal catalogue."
9. **"How do you handle real-time data from a device?"** → EventChannel stream → controller → priority audio queue; throttle descriptions, interrupt for safety. (It's in the demo.)

**Product / judgment**
10. **"What would you improve about our app?"** → Section 3, framed as opportunities; lead with Android reliability + accessibility declaration. Be tactful.
11. **"What's hard about building for blind users?"** → "Everything is audio-first and safety-critical; the companion app needs flawless screen-reader semantics, and the failure mode of a missed alert is physical, not cosmetic."
12. **"How do you prioritize with limited time?"** → "Highest user-safety and highest-leverage first. For Seekr: reliability of the device connection and the audio pipeline before cosmetic features."

**Behavioral**
13. **"A hard bug / time you failed?"** → ZEGOCLOUD WebRTC in 5 days: isolate the unknown before it touches prod. (v2 Part 11.)
14. **"Disagreement with a founder/stakeholder?"** → the HIPAA auto-send pushback: show the rule, propose the fast *safe* path. (v2 Part 11.)
15. **"How do you keep code quality high solo?"** → tests + handover docs + (here) a team review habit I'd welcome.
16. **"Where in 3–5 years?"** → deeper technical ownership, leading mobile as Seekr scales.

**Curveballs**
17. **"You haven't built BLE/hardware apps — gap?"** → "I own the app layer the JD describes; I interface with the device over WiFi/API like any data source. I integrated ZEGOCLOUD and HeyGen real-time streams — same connection-state problem. I'd ask for the device protocol doc day one."
18. **"We're early-stage, funding's uncertain — OK with risk?"** → "Yes — startup pace is where I do my best work and where ownership is highest. The CES award and HKSTP backing tell me the foundation is real."
19. **"Have you used our app?"** → only a yes if true — **download both before Monday.** Then: "Yes — I went through onboarding and noted opportunities around Android reliability, app-size, accessibility declarations, and latency."
20. **"What's your salary expectation?"** → Section 11 / cross-ref. Range, not floor.
21. **"Can you start immediately?"** → "Fully available from July 1st."

---

## 9 — QUESTIONS YOU ASK (split by founder)

**For Turzo (CEO — vision/product):**
- "Where do you see Seekr in two years — deeper on the wearable, or is the glasses direction the main bet?"
- "What's the biggest thing holding the product back right now — hardware, models, or the app experience?"
- "What does success for this role look like in the first 90 days?"

**For Reshika (CTO — technical):**
- "What state management and architecture is the current app on, so I know what I'd step into?"
- "Does the device send the app raw inference labels or embeddings the app post-processes?"
- "Biggest pain at the app↔model boundary — latency, output phrasing, or mode-switching?"
- "Are you A/B testing model versions in production? I could wire Remote Config to flip versions without an app release."

**Either:**
- "How do you keep technical debt down shipping fast on a small team?"
- "Are Android reliability, device connectivity, or app-size reduction already on the roadmap?"

---

## 10 — CODING ROUND GAME PLAN (it's confirmed)

Laptop ready = a live problem. Don't predict the topic (they said you can't). Instead:
- **Run the 5-step loop** every time: clarify → plan aloud → code while narrating → test + edge cases → trade-off. (v2 Part 1.) **Silence is the only real failure.**
- **Be self-sufficient** — assume no AI unless they offer it; have your IDE warm, a runnable Flutter project open, DartPad in a tab. (v2 Part 1.5.)
- **Most likely:** live Flutter/Dart (build/fix a widget), a real-world scenario, or light Python/data. Your strongest practiced answers: the **ObstacleAlerter** (mock-and-practice Section 1), the **WiFi multi-network** answer (v2 Part 5), the **GetX** drills (mock-and-practice Section 4.1).
- If you blank on syntax: say it, write the logic as comments, fill the skeleton, run it, read the error. (v2 Part 1.5.)
- **Your demo can double as coding-round fuel** — you already know that codebase cold, so if they say "show us some code," you have clean, real code to walk and extend live.

---

## 11 — WHAT WE MIGHT HAVE MISSED (the senior-engineer sweep)

- **Salary:** if asked, give a **range, not a floor** — USD **3,000–3,500/mo**, equity as a separate ask; offer a 3-month trial at ~$2,500 → review if they push. Never below $2,000. Don't raise it first. *(June 17 addendum A8.)*
- **Equity:** HKSTP-incubated, CES-winning, Forbes 30U30 — there's likely an ESOP pool. Ask: "Given I'd be a core technical owner this early, is there an equity component?"
- **Contract structure:** cross-border remote usually means a **contractor agreement**, not employment. Be open to it; ask how they structure international hires and payment (request **USD** for forex consistency).
- **Work authorization:** none needed — you're India-based remote with India PR, which their JD explicitly wants. A non-issue; mention only if asked.
- **English / communication:** the JD flags it; just be articulate and concise. You're fine.
- **Demo backup:** record a 2-minute screen capture of the demo running, in case live share/network fails.
- **Don't trash their product:** every "improvement" is framed as an opportunity, said with respect for what two founders built from nothing.
- **Anti-claims (never inflate):** GPT-5.4 Mini (not 5/5.5), 3+ years, **Tech Lead** (not CTO/Founder), 4 US clinics, 35 releases/7 months, 10K+ users, 200+ gift cards, no unshipped products claimed.
- **Reconcile the GenZDealZ label:** "consult as a tech lead" covers both "consultant" (this round) and "Tech Lead" (if said in Round 1).
- **End the call well:** "This was a great conversation — I'm genuinely excited about the mission and I think I'm a strong fit for the mobile ownership you need. What are the next steps?" Don't accept/negotiate on the spot if an offer appears — express enthusiasm, ask for it in writing.

---

## 12 — FINAL PLAN + DAY-OF

**Today (Wed) / Thu:**
- [ ] **Run the demo on your machine** (`cd seekr_companion_demo && flutter pub get && flutter run -d chrome`). Fix any setup issue now, not Monday.
- [ ] Record a 2-min backup screen capture of it running.
- [ ] Download + try **both** Seekr apps.
- [ ] Lock your **commitment answer** (Section 2) and **GPT-5.4 Mini** consistency.

**Fri / Sat:**
- [ ] Rehearse Section 8 Q&A out loud; rehearse the demo walkthrough (README script) to under 4 minutes.
- [ ] One timed coding rep (reply "mock me" and I'll run it).
- [ ] Re-read the architecture scripts (mock-and-practice Section 2) + AI/ML (Section 3).

**Sun:**
- [ ] Light review only. Re-read this doc Sections 1–5 + v2 Part 16 cheat sheet. Rest.

**Mon 1:00 PM IST (30 min before):**
- [ ] Demo running in Chrome, ready to share. Backup recording open.
- [ ] IDE warm, blank Dart/Python files, DartPad tab.
- [ ] Both Seekr apps installed.
- [ ] Notifications off, quiet room, water, paper + pen.
- [ ] Re-read Section 2 (commitment) + Section 3 (contribution) one last time.

---

### THE 5 THINGS TO REMEMBER IN THE ROOM
1. **They're founders deciding on a teammate** — be a calm senior peer, mission-aligned, low-ego.
2. **Commitment answer is clean** — consultant + AIW winding down + free July 1, weekends. Say it without hesitation.
3. **Lead contribution with specifics** — Android reliability, accessibility, the 1 Mbps edge-result pipeline.
4. **Offer the demo, don't hijack** — 3–4 min, ask first, architecture → accessibility → audio-priority.
5. **Coding round = think aloud.** Clarify, plan, narrate, test. Silence is the only failure.

*You ended Round 1 strong, the timing of your availability is genuinely clean, and you built something real to show. Walk in as the senior who already belongs on their team. — Good luck Monday, Smit.*
