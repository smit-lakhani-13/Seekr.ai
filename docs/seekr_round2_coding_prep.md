# 🚀 SEEKR ROUND 2 — CODING ROUND MASTER PREP (v2 — FOOLPROOF EDITION)

**When:** Monday, June 29 · 4:00–5:00 PM HKT = **1:30–2:30 PM IST**
**With:** Reshika (likely + Lamia)
**Format:** Live, on-the-spot. Topic undisclosed. "How developers think on their feet."
**Link:** https://meet.google.com/gpb-cqme-cbj

> **How to use this doc:** Parts 0–1 are the mindset (read first, read last). Parts 2–7 are coding you must be able to *type from memory*. Parts 8–10 are talking points. Parts 11–14 are the human side (why you, the two-jobs question, salary). Part 15 is your day-by-day plan. Part 16 is a one-page glance sheet for 10 minutes before the call.

---

## 📌 TABLE OF CONTENTS

0. What this round actually is + strategy
1. The thinking-aloud framework (the meta-skill)
1.5 **Coding WITHOUT AI — the self-sufficiency playbook (NEW)**
2. Dart syntax reload
3. Python syntax reload
4. Live Flutter coding drills (expanded)
5. Real-world scenario drills (WiFi answer CORRECTED)
6. Python / data / AI drills (expanded)
7. DSA easy–medium primer (expanded)
8. JD topic deep-dives
9. Your products — likely follow-ups (GPT-5.4 Mini LOCKED)
10. Reach Reshika's level — ML / Edge AI / CV (expanded)
11. **Behavioral + "why you" + curveball questions (NEW)**
12. **The two-jobs / commitment question — critical (NEW)**
13. Questions YOU ask them
14. Salary — what to say
15. 5-day plan + day-of checklist
16. **One-page glance cheat sheet (NEW)**

---

## PART 0 — WHAT THIS ROUND ACTUALLY IS

Decode what Lamia told you, word for word:

> "The topic is undisclosed so that we can understand how developers think on their feet. You don't have to prepare anything in advance."
> "All instructions will be given to you on the spot."

This is not a riddle and not a trap. It tells you exactly what they're scoring:

1. **Can you break down an unfamiliar problem out loud?** They want to watch your reasoning, not your memory.
2. **Do you ask the right clarifying questions before coding?** Jumping straight to code is a red flag. Clarifying first is a green flag.
3. **Can you write working code without freezing?** This is where two years of vibe-coding hurts — you need syntax in muscle memory so you're not fighting the keyboard while they watch.
4. **Do you test and handle edge cases?** Or do you declare "done" and miss the empty-input case?

**The honest truth about prep:** You cannot cram an undisclosed problem. What you CAN do: (a) get core syntax fluent so you don't stall, (b) rehearse the thinking-aloud script until it's automatic, (c) drill the realistic problem types so nothing feels alien. That's this doc.

**What they'll most likely throw at you (ranked):**

| Likelihood | Type | Where to prep |
|---|---|---|
| ★★★★★ | Live Flutter/Dart — build a small widget/feature, fix a bug | Part 4 |
| ★★★★☆ | Real-world scenario / decomposition (like the WiFi problem) | Part 5 |
| ★★★☆☆ | Python / data / JSON manipulation (Reshika's lean) | Part 6 |
| ★★★☆☆ | Debug / code review of provided code | Part 4 Q5, Part 8 |
| ★★☆☆☆ | Easy–medium DSA (arrays, strings, hashmaps) | Part 7 |
| ★★☆☆☆ | System-design-lite ("architect the companion app") | Part 5, Part 10 |

Hardcore LeetCode (hard DP, graphs) is **unlikely** for a Flutter role at a 10-person startup. Don't waste prep there.

---

## PART 1 — THE THINKING-ALOUD FRAMEWORK (THE META-SKILL THAT WINS THIS)

When they give you the problem, do NOT start typing. Run this loop out loud. This single habit *is* what "thinking on your feet" means to them.

### The 5 steps — memorize this order

**1. Restate + Clarify (30–60 sec).** Repeat the problem in your own words, then ask:
- Input format + constraints ("Always valid? Can it be empty/null? How large?")
- Output format
- Edge cases ("Empty list? Duplicates? Negative numbers?")
- Priority ("Optimize for speed or readability?")

*Script:* "So you want X that takes Y and returns Z. Before I code — can the input be empty? Any size limit? Optimize for speed or clarity?"

**2. Plan out loud (1–2 min).** Name the data structure and algorithm BEFORE coding.

*Script:* "My plan: use a hash map for O(1) lookups, one pass over the list — O(n) time, O(n) space. Sound reasonable before I write it?"

This lets them course-correct you early, which they WANT to do — it's a collaboration signal.

**3. Code while narrating.** Talk as you type. "Setting up a map for seen values… looping… for each item I check if its complement is already there…" If you blank on syntax: say it. "I'll sketch the loop and fix exact syntax in a sec" — then keep moving. **Silence is the enemy.**

**4. Test with examples.** Walk through your code with a concrete input, out loud, like a debugger. Then name edge cases: "Trace with [2,7,11], target 9… and empty input — loop doesn't run, returns empty, good."

**5. Reflect (10 sec).** "This is O(n). If memory were tight I'd sort first + two pointers — O(n log n) time, O(1) space. Trade-off depends on constraints." Naming trade-offs = senior behaviour.

### When you get stuck (you will — that's fine)

- Say what you're stuck on. Narrate the fork in the road.
- **Brute-force first.** "Let me get *a* working solution, even O(n²), then optimize." Working-slow beats broken-clever.
- Solve a smaller version, then generalize.
- Ask for a hint: "Am I on the right track with the hash-map approach?" Asking ≠ failing. It's collaboration. **They already like you.**

**The mindset:** Round 1 already convinced them you're good. This round confirms you can build. Treat Reshika as a pairing partner, not an examiner.

---

## PART 1.5 — CODING WITHOUT AI: THE SELF-SUFFICIENCY PLAYBOOK 🔴

Lamia dodged the "can I use AI/internet?" question **twice**. Plan for the hardest case: **you code unaided, on a shared screen, while they watch.** If they allow tools, treat it as a bonus. Here's how to be self-sufficient.

### The core problem with vibe-coding
For two years you've described intent and let AI produce syntax. In this room, that crutch may be gone. The fix isn't to memorize everything — it's to **rebuild the 20% of syntax that covers 80% of live coding**, and to have a *reconstruction method* for the rest.

### The "reconstruct from memory" method (use when you blank)
You rarely need to recall syntax perfectly — you need to recall the *shape*, then refine:
1. **Write the logic in plain pseudocode first** as comments. `// loop over list; for each, check map; if found return pair`.
2. **Fill in the language skeleton** you DO remember (loops, if, function signature).
3. **Refine syntax token by token**, narrating. If you write `for item in list` (Python) in a Dart file, catch it: "in Dart that's `for (final item in list)`."
4. **Run it** (DartPad / `python3 scratch.py`) and **read the error** — errors are your unaided autocomplete. A `NoSuchMethodError` or `type 'X' is not a subtype` tells you exactly what to fix.

### What you MUST have in muscle memory (drill these until automatic)
- Function signature + return, in both Dart and Python
- A `for` loop and a `while` loop, both languages
- Make + read a list, map/dict, set, both languages
- `if / else`, ternary, null-check
- A class with a constructor + one method, both languages
- `map` / `where` / `filter` / list-comprehension
- A `StatefulWidget` skeleton + `setState`
- `async` / `await` + a `try/catch`

If you can type those 8 things cold, you can survive any unaided problem by composing them. Parts 2–3 are exactly these.

### Legit aids you CAN have open (not cheating)
Even in an unaided coding round, these are normally fine — they're your environment, not answer-generation:
- **Your IDE's own autocomplete / IntelliSense** (built into VS Code / Android Studio).
- **Language docs in a tab** (api.dart.dev, docs.python.org) — *if* they say internet is OK. Ask: "Mind if I keep the Dart API docs open for method signatures?" Asking shows honesty.
- **Your own personal notes / this cheat sheet** (Part 16) — having your own syntax notes is normal engineering, not AI.
- **DartPad** open for instant execution.

Do NOT silently paste from ChatGPT on a shared screen unless they explicitly invite it — getting caught reading AI output verbatim while claiming to reason is the one thing that fails you instantly.

### If they DO allow AI — use it like a senior, not a junior
- Prompt precisely: state the constraint, the language, the edge cases.
- **Read every line before running.** Narrate: "It suggested X — I'm checking the null case it missed."
- Verify against an example. Never ship AI output you can't explain.
- The skill they're watching becomes *judgment + verification*, not generation.

---

## PART 2 — DART SYNTAX RELOAD (type every block by hand in DartPad)

### Variables & null safety
```dart
var name = 'Smit';          // inferred String
final age = 25;             // set once, runtime
const pi = 3.14;            // compile-time constant
int? maybe;                 // nullable

String r = maybe ?? 'default';   // null-coalescing
int? len = maybe?.length;        // safe call
maybe ??= 'set if null';
String forced = maybe!;          // assert non-null (throws if null)
```

### Functions
```dart
int add(int a, int b) => a + b;                 // arrow
int mul(int a, int b) { return a * b; }         // block

void greet({required String name, int age = 0}) // named params (Flutter style)
    => print('$name $age');
greet(name: 'Smit', age: 25);

String tag(String s, [String p = '#']) => '$p$s'; // optional positional
```

### Collections
```dart
List<int> nums = [1, 2, 3];
nums.add(4);
nums.where((n) => n > 2).toList();      // [3,4]
nums.map((n) => n * 2).toList();        // [2,4,6,8]
nums.fold(0, (s, n) => s + n);          // 10
nums.firstWhere((n) => n > 2, orElse: () => -1);
nums.sort((a, b) => b.compareTo(a));    // descending
nums.reduce((a, b) => a + b);           // 10 (non-empty only)

Map<String, int> m = {'a': 1};
m['b'] = 2;
m.containsKey('a');
m.forEach((k, v) => print('$k=$v'));
int v = m['a'] ?? 0;

Set<int> s = {1, 2, 2, 3};              // {1,2,3}

var combined = [0, ...nums];            // spread
var ui = [ if (age > 18) 'adult', for (var n in nums) 'item$n' ]; // collection-if/for
```

### Classes
```dart
class User {
  final String name;
  int age;
  User(this.name, this.age);                          // constructor
  User.guest() : name = 'Guest', age = 0;             // named constructor
  factory User.fromJson(Map<String, dynamic> j) =>    // factory
      User(j['name'], (j['age'] as num).toInt());
  String describe() => '$name ($age)';
  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}
```

### Async — Future & Stream
```dart
Future<String> fetchName() async {
  await Future.delayed(const Duration(seconds: 1));
  return 'Smit';
}

void main() async {
  try {
    final name = await fetchName();
    print(name);
  } catch (e) {
    print('error: $e');
  }
}

Stream<int> countTo(int n) async* {       // many values over time
  for (var i = 1; i <= n; i++) {
    await Future.delayed(const Duration(milliseconds: 200));
    yield i;
  }
}
// consume: await for (final v in countTo(3)) print(v);
```

### Cascade & null-aware spread
```dart
final buf = StringBuffer()..write('a')..write('b')..write('c');
final list2 = [...?maybeNullableList];   // spread only if not null
```

### Things interviewers love to ask about Dart
- **`final` vs `const`:** `const` is compile-time (baked in), `final` is runtime (set once). A `const` list is deeply immutable.
- **`==` vs `identical()`:** `==` is value equality (override `==` + `hashCode`), `identical` is same instance.
- **Mixins:** `class A with B, C` — reuse methods across unrelated classes (Dart has no multiple inheritance; mixins fill that gap).
- **`late`:** non-null variable initialized after declaration (e.g., in `initState`). Throws if used before assignment.

---

## PART 3 — PYTHON SYNTAX RELOAD

### Basics
```python
name = "Smit"
age: int = 25          # optional hint
x = None               # null

s = "hello"
s.upper(); s.split(); s[::-1]; s.replace("l", "L")
f"{name} is {age}"     # f-string
```

### Collections
```python
nums = [1, 2, 3]
nums.append(4)
[n for n in nums if n > 2]       # [3,4]  filter
[n * 2 for n in nums]            # [2,4,6,8]
sum(nums); max(nums); min(nums)
sorted(nums, reverse=True)
nums[::-1]; nums[1:3]            # reverse; slice

d = {"a": 1}
d["b"] = 2
d.get("a", 0)                    # safe default
{k: v for k, v in d.items() if v > 1}   # dict comprehension
for k, v in d.items(): ...

st = {1, 2, 2, 3}                # set -> {1,2,3}
set(nums)                        # dedupe

t = (3, 4); x, y = t             # tuple unpack
```

### Functions & classes
```python
def add(a, b): return a + b
square = lambda x: x * x
def greet(name, greeting="Hi"): return f"{greeting}, {name}"
def total(*args, **kwargs): return sum(args)

class User:
    def __init__(self, name, age):
        self.name = name; self.age = age
    def describe(self): return f"{self.name} ({self.age})"
    @classmethod
    def from_json(cls, j): return cls(j["name"], j["age"])
```

### Stdlib that wins interviews
```python
from collections import Counter, defaultdict, deque
Counter([1,1,2,3,3,3])               # {3:3,1:2,2:1}
Counter("hello").most_common(1)      # [('l',2)]
d = defaultdict(list); d["a"].append(1)   # no KeyError
q = deque([1,2,3]); q.popleft()      # O(1) both ends

import json
json.loads('{"a":1}')                # str -> dict
json.dumps({"a":1})                  # dict -> str

enumerate(nums)                      # (index, value) pairs
zip([1,2],[3,4])                     # (1,3),(2,4)
```

---

## PART 4 — LIVE FLUTTER CODING DRILLS (most likely category)

### Q1. Counter with a button (warm-up).
```dart
class Counter extends StatefulWidget {
  const Counter({super.key});
  @override State<Counter> createState() => _CounterState();
}
class _CounterState extends State<Counter> {
  int _count = 0;
  void _inc() => setState(() => _count++);
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('Count: $_count')),
    floatingActionButton: FloatingActionButton(
      onPressed: _inc, child: const Icon(Icons.add)),
  );
}
```
*Say:* "Local state via setState. If it needed to persist I'd use SharedPreferences; if shared across screens, a GetX controller."

### Q1b. Same thing in GetX (your actual stack — show it).
```dart
class CounterController extends GetxController {
  var count = 0.obs;             // reactive observable
  void increment() => count++;
}
// UI:
final c = Get.put(CounterController());
Obx(() => Text('${c.count}'));   // rebuilds ONLY this widget when count changes
ElevatedButton(onPressed: c.increment, child: const Text('+'));
```
*Say:* "`.obs` makes it observable; `Obx` rebuilds only the widget that reads it — not the whole tree. `Get.put` registers the controller for DI."

### Q2. Accessible toggle (Seekr-relevant — they build for blind users).
```dart
class _ToggleState extends State<AccessibleToggle> {
  bool _on = false;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Depth detection mode',
    toggled: _on,
    button: true,
    child: SwitchListTile(
      title: const Text('Depth Detection'),
      value: _on,
      onChanged: (v) {
        setState(() => _on = v);
        SemanticsService.announce(
          v ? 'Depth detection on' : 'Depth detection off',
          TextDirection.ltr);
      },
    ),
  );
}
```
**Volunteer this if the problem is open-ended** — it proves you internalized their mission.

### Q3. Debounced search (async + lifecycle).
```dart
import 'dart:async';
class _SearchState extends State<SearchScreen> {
  Timer? _debounce;
  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }
  @override
  void dispose() { _debounce?.cancel(); super.dispose(); }  // CRITICAL
  void _search(String q) { /* call API */ }
}
```
*Say:* "Without the dispose-cancel, the timer can fire after the widget is gone and crash."

### Q4. ListView from API — loading / error / empty (all three states).
```dart
FutureBuilder<List<String>>(
  future: _fetchItems(),
  builder: (context, snap) {
    if (snap.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snap.hasError) return const Center(child: Text('Error. Tap to retry.'));
    final items = snap.data ?? [];
    if (items.isEmpty) return const Center(child: Text('No items yet'));
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => ListTile(title: Text(items[i])),
    );
  },
);
```
Naming empty + error states is what separates you from a junior.

### Q5. DEBUG THIS (they may show broken code).
```dart
// BUGGY
void load() async {
  final data = await api.getProfile();
  setState(() => name = data.name);   // can crash
}
```
*Bug:* `setState` after the widget is disposed (user navigated away mid-await) → "setState called after dispose."
```dart
// FIX
void load() async {
  final data = await api.getProfile();
  if (!mounted) return;               // guard after every await
  setState(() => name = data.name);
}
```
**Common Flutter bugs to recognize on sight:** missing `key` → state attaches to wrong list item; `setState` inside `build` → infinite loop; not disposing controllers/streams → leak; `BuildContext` used across an async gap; `ListView` inside `Column` without `Expanded` → unbounded height crash.

### Q6. Navigation + passing data + getting a result back.
```dart
// Push and await a returned value
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => DetailScreen(id: 5)),
);
// On the detail screen, return data:
Navigator.pop(context, 'selected-value');

// GetX equivalent (your stack):
final result = await Get.to(() => DetailScreen(id: 5));
Get.back(result: 'selected-value');
```

### Q7. End-to-end API call: model + parse + fetch (very common ask).
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Deal {
  final String title;
  final double price;
  Deal({required this.title, required this.price});
  factory Deal.fromJson(Map<String, dynamic> j) =>
      Deal(title: j['title'], price: (j['price'] as num).toDouble());
}

Future<List<Deal>> fetchDeals() async {
  final res = await http.get(Uri.parse('https://api.example.com/deals'));
  if (res.statusCode != 200) throw Exception('Failed: ${res.statusCode}');
  final List data = jsonDecode(res.body);
  return data.map((j) => Deal.fromJson(j)).toList();
}
```
*Say:* "`(j['price'] as num).toDouble()` handles JSON that sends price as int OR double — a real-world gotcha. For big apps I'd codegen with `json_serializable` and use `dio` for interceptors/retries."

### Q8. Build a tiny app live (tip calculator / todo). Pattern if asked.
```dart
class _TipState extends State<TipCalc> {
  double _bill = 0;
  double _tipPct = 0.15;
  double get _tip => _bill * _tipPct;
  double get _total => _bill + _tip;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      TextField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Bill amount'),
        onChanged: (v) => setState(() => _bill = double.tryParse(v) ?? 0),
      ),
      Slider(value: _tipPct, min: 0, max: 0.3, divisions: 6,
        label: '${(_tipPct * 100).round()}%',
        onChanged: (v) => setState(() => _tipPct = v)),
      Text('Tip: \$${_tip.toStringAsFixed(2)}'),
      Text('Total: \$${_total.toStringAsFixed(2)}'),
    ]),
  );
}
```
*Edge cases to mention:* non-numeric input (`tryParse ?? 0`), negative bill, very large numbers, locale/currency formatting (`intl` package).

---

## PART 5 — REAL-WORLD SCENARIO DRILLS (HIGH PROBABILITY)

### Q1. 🔴 (Your Round 1 question — CORRECTED & UPGRADED.) On Android, if WiFi has no internet, the device doesn't fall back to cellular. How do you handle it?

**⚠️ Drop the claim you made in Round 1** that "after Android 12 it auto-switches for sure." It doesn't — users across Pixel, Samsung S24/S21, Note 20 still report this failing, and the "Switch to mobile data" toggle is an OEM (Samsung) feature, not guaranteed Android behaviour. A sharp engineer can poke that.

**The correct, senior answer — the multi-network binding API:**

The real scenario for Seekr: the wearable broadcasts its *own* local WiFi (or WiFi-Direct) so the phone can receive camera frames. That local network has **no internet by design**. So the phone is on WiFi (device) but needs the internet over **cellular at the same time**. Android solves this with the **multi-network API**, not by "switching."

Layered answer:
1. **Detect the failure type.** Wrap the call. A `SocketException` / timeout = connectivity problem (an HTTP 4xx/5xx means the network worked — different bucket).
2. **Explicitly request the right networks without binding the whole process** via a platform channel to native Android:
```kotlin
// Native Android (Kotlin) — invoked from a Flutter MethodChannel
val cm = getSystemService(ConnectivityManager::class.java)
val cellularRequest = NetworkRequest.Builder()
    .addTransportType(NetworkCapabilities.TRANSPORT_CELLULAR)
    .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    .build()
cm.requestNetwork(cellularRequest, object : ConnectivityManager.NetworkCallback() {
    override fun onAvailable(network: Network) {
        cellularNetwork = network          // hold for network-specific sockets/requests
    }
})
```
For the device AP on Android 10+, use `WifiNetworkSpecifier` so the wearable WiFi is app-scoped/local-only and does not replace cellular as the default internet route. For lower-level sockets, bind per socket/request via `network.openConnection(url)`, `network.socketFactory`, or `bindSocket` — do **not** use `bindProcessToNetwork()` as the default because it binds the whole app and can break the wearable WiFi path.
3. **Retry once** after requesting the cellular/default internet route.
4. **Graceful degrade for a blind user:** if it still fails, don't leave a silent dead screen — speak it: TTS "Connection lost, please wait." Safety-first because the user can't see a spinner.

```dart
// Flutter side
Future<Response> fetchWithFallback(Uri url) async {
  try {
    return await _client.get(url).timeout(const Duration(seconds: 5));
  } on SocketException {
    await _platform.invokeMethod('requestCellularNetwork');
    try {
      return await _client.get(url).timeout(const Duration(seconds: 5));
    } catch (_) {
      await _tts.speak('Connection lost, please wait');
      rethrow;
    }
  }
}
```
*Why this lands:* it distinguishes transport detection from route selection. Mention `connectivity_plus` for detecting network state, but note it only detects — route selection/local-only WiFi must be native.

### Q2. Seekr fires "obstacle ahead" and "scene description" at the same moment. Both produce audio. What plays first?

**A.** "Audio is one shared output — can't speak two things at once. Priority queue: safety alerts (obstacle/depth) are high priority and interrupt; descriptions are low priority and queue behind."
```dart
enum AudioPriority { safety, normal }
class AudioQueue {
  final _q = <_Utterance>[];
  bool _speaking = false;
  void enqueue(String text, AudioPriority p) {
    if (p == AudioPriority.safety) { _tts.stop(); _q.insert(0, _Utterance(text, p)); }
    else { _q.add(_Utterance(text, p)); }
    _drain();
  }
  Future<void> _drain() async {
    if (_speaking || _q.isEmpty) return;
    _speaking = true;
    final u = _q.removeAt(0);
    await _tts.speak(u.text);     // await completion
    _speaking = false;
    _drain();                     // next
  }
}
class _Utterance { final String text; final AudioPriority p; _Utterance(this.text, this.p); }
```
*Edge cases:* incoming phone call (respect `AudioFocus` / `AVAudioSession`); duplicate alerts within 1s (debounce so it doesn't repeat "obstacle, obstacle, obstacle").

### Q3. WiFi device keeps dropping. Design reconnection.
**A.** State machine + exponential backoff: `disconnected → scanning → connecting → connected → (lost) → reconnecting`. Backoff 1,2,4,8…cap 30s so you don't drain the device battery. After N fails, announce + stop to save power.
```dart
int _attempt = 0;
Future<void> _reconnect() async {
  final delay = Duration(seconds: (1 << _attempt).clamp(1, 30)); // 1,2,4,8...
  await Future.delayed(delay);
  if (await _tryConnect()) { _attempt = 0; return; }
  if (++_attempt > 5) { await _tts.speak('Device disconnected. Check it is on.'); return; }
  _reconnect();
}
```

### Q4. Make a core feature work offline.
**A.** "Offline-first. The edge AI on the device already works without internet, so the app's core modes must never hard-depend on the network. Cloud is only for sync, subscription checks, analytics. Cache last state locally (Hive/sqflite), queue writes, flush on reconnect. Reads serve from cache instantly, refresh in background."

### Q5. Throttle vs debounce.
**A.** "Debounce = wait until the user *stops* (search box). Throttle = fire at most once per interval regardless (scroll, sensor streams). For Seekr's scene descriptions I'd throttle so we don't narrate 30 frames/sec; for a settings search I'd debounce."

### Q6. (System-design-lite) "How would you architect the Seekr companion app?"
**A.** Layered / Clean Architecture:
- **Presentation** — screens + GetX controllers (or BLoC if that's their codebase).
- **Domain** — use cases (StartMode, PairDevice), entities, repository *interfaces*.
- **Data** — repository impls, data sources: a `DeviceDataSource` (WiFi/BLE), a `FirebaseDataSource` (Firestore/Analytics), a `LocalCache` (Hive).
- **Cross-cutting** — an `AudioQueue` service (Q2), a `ConnectivityService`, a `TtsService`.
- **Flavors** — dev/qa/staging/prod with separate Firebase projects.
*Say:* "I'd keep the device-comms layer behind an interface so the rest of the app doesn't care whether frames arrive over WiFi or, later, over the glasses' transport."

---

## PART 6 — PYTHON / DATA / AI DRILLS (Reshika may lean here)

### Q1. Extract emails from a JSON response.
```python
import json
def extract_emails(raw: str) -> list[str]:
    data = json.loads(raw)
    return [u["email"] for u in data.get("users", []) if "email" in u]
```

### Q2. Word frequency, top N.
```python
from collections import Counter
def top_words(text, n=3):
    return Counter(text.lower().split()).most_common(n)
```

### Q3. Group list of dicts by field.
```python
from collections import defaultdict
def group_by_city(people):
    g = defaultdict(list)
    for p in people:
        g[p["city"]].append(p["name"])
    return dict(g)
```

### Q4. Cosine similarity (your GenZGPT vector search).
```python
import math
def cosine(a, b):
    dot = sum(x*y for x, y in zip(a, b))
    na = math.sqrt(sum(x*x for x in a))
    nb = math.sqrt(sum(y*y for y in b))
    return 0.0 if na == 0 or nb == 0 else dot / (na * nb)
```
*Say:* "This is the metric behind semantic search — embed the query, embed each item, rank by cosine. Exactly what GenZGPT's discovery agent does over the vector DB."

### Q5. Rate limiter (sliding window) — ties to your CRM send caps.
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

### Q6. Moving average (sensor smoothing — Seekr-relevant).
```python
from collections import deque
def moving_average(readings, k):
    if k <= 0 or not readings: return []
    out, window, total = [], deque(), 0
    for r in readings:
        window.append(r); total += r
        if len(window) > k: total -= window.popleft()
        if len(window) == k: out.append(total / k)
    return out
```

### Q7. Parse + transform: bucket obstacle distances into alert levels.
```python
def alert_level(distance_m):
    if distance_m < 1:   return "DANGER"
    if distance_m < 2.5: return "WARNING"
    return "CLEAR"
# vectorized over a stream:
levels = [alert_level(d) for d in distances]
```

---

## PART 7 — DSA EASY/MEDIUM PRIMER (lower probability, but be ready)

Master these patterns — they cover ~80% of what could come up. Easy–medium only.

### Two Sum — hash map, O(n)
```python
def two_sum(nums, target):
    seen = {}
    for i, n in enumerate(nums):
        if target - n in seen: return [seen[target - n], i]
        seen[n] = i
    return []
```
```dart
List<int> twoSum(List<int> nums, int target) {
  final seen = <int, int>{};
  for (var i = 0; i < nums.length; i++) {
    final need = target - nums[i];
    if (seen.containsKey(need)) return [seen[need]!, i];
    seen[nums[i]] = i;
  }
  return [];
}
```

### Two pointers — pair sum in sorted array
```python
def pair_sum_sorted(arr, target):
    lo, hi = 0, len(arr) - 1
    while lo < hi:
        s = arr[lo] + arr[hi]
        if s == target: return [lo, hi]
        if s < target: lo += 1
        else: hi -= 1
    return []
```

### Sliding window — max sum of k consecutive
```python
def max_sum_k(arr, k):
    if len(arr) < k: return None
    window = sum(arr[:k]); best = window
    for i in range(k, len(arr)):
        window += arr[i] - arr[i-k]
        best = max(best, window)
    return best
```

### Valid parentheses — stack
```python
def is_valid(s):
    pairs = {')':'(', ']':'[', '}':'{'}; stack = []
    for c in s:
        if c in pairs.values(): stack.append(c)
        elif c in pairs:
            if not stack or stack.pop() != pairs[c]: return False
    return not stack
```

### Palindrome / first non-repeating char
```python
def is_palindrome(s): s = s.lower(); return s == s[::-1]

from collections import Counter
def first_unique(s):
    c = Counter(s)
    for ch in s:
        if c[ch] == 1: return ch
    return None
```

### Group anagrams — sorted-string key
```python
from collections import defaultdict
def group_anagrams(words):
    g = defaultdict(list)
    for w in words: g[''.join(sorted(w))].append(w)
    return list(g.values())
```

### Binary search — O(log n) (needs sorted input)
```python
def binary_search(arr, target):
    lo, hi = 0, len(arr) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if arr[mid] == target: return mid
        if arr[mid] < target: lo = mid + 1
        else: hi = mid - 1
    return -1
```

### Recursion + memoization — Fibonacci
```python
def fib(n, memo={}):
    if n <= 1: return n
    if n in memo: return memo[n]
    memo[n] = fib(n-1, memo) + fib(n-2, memo)
    return memo[n]
```

### Reverse a linked list (classic)
```python
class Node:
    def __init__(self, val, nxt=None): self.val, self.next = val, nxt
def reverse_list(head):
    prev = None
    while head:
        nxt = head.next
        head.next = prev
        prev = head
        head = nxt
    return prev
```

### FizzBuzz (still a warm-up)
```python
for i in range(1, 101):
    print("FizzBuzz" if i%15==0 else "Fizz" if i%3==0 else "Buzz" if i%5==0 else i)
```

### Big-O cheat sheet (say these aloud while solving)
| Pattern | Time |
|---|---|
| Hash map lookup | O(1) — the go-to optimization |
| Single loop | O(n) |
| Nested loop | O(n²) — say "I'd optimize with a map" |
| Sort | O(n log n) |
| Binary search | O(log n) |
| Two pointers / sliding window | O(n) |

**Verbalize:** "Nested loop to find pairs → a hash map usually drops it to one pass."

---

## PART 8 — JD TOPIC DEEP-DIVES (crisp verbal answers)

### UI/UX principles & design patterns
- **For Seekr:** large touch targets (56dp+ for elderly), high contrast (WCAG AA ≥ 4.5:1), dark mode, full screen-reader semantics, audio-first feedback, minimal taps, haptics.
- **Patterns you use:** *BLoC/MVVM* (separate UI from logic), *Repository* (abstract the data source), *Singleton* (one API client), *Factory* (`fromJson`), *Observer* (reactive `Obx`), *Dependency Injection* (mockable services).

### Git
- `git checkout -b feature/x`, `git add -p`, `git commit -m`, `git push`, PR.
- **Merge vs rebase:** merge keeps history + a merge commit; rebase replays commits for a linear history. "I rebase my feature branch before a PR; never rebase shared branches."
- **Conflict:** Git marks `<<<<<<<`/`=======`/`>>>>>>>`; pick/merge, remove markers, `git add`, continue.
- Conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`.

### Agile / Scrum
- Sprints (1–2 wks), daily standup (did / will do / blockers), planning, retro, demo. Kanban board for flow.
- "On a small team I'd keep it lightweight — short async standups given the 2.5h time gap, ship in small increments."

### RESTful APIs
- Verbs: GET / POST / PUT-PATCH / DELETE. Status: 200, 201, 400, 401, 403, 404, 500.
- Stateless, resource URLs (`/users/123/sessions`), idempotency (GET/PUT/DELETE retry-safe; POST not).

### JSON & web services in Flutter
```dart
final data = jsonDecode(body);        // String -> Map/List
final user = User.fromJson(data);
final out = jsonEncode(user.toJson()); // Map -> String
```
Mention `dio` (interceptors, retries), `json_serializable` (codegen for big models).

### Firebase Analytics
```dart
await FirebaseAnalytics.instance.logEvent(
  name: 'mode_activated',
  parameters: {'mode': 'text_recognition', 'language': 'en'});
```
Custom events + params, user properties, funnels, DebugView. For Seekr: track mode usage, inference latency, TTS replays (signal of unclear output) → feeds Reshika's model loop.

### Databases
- **SQL vs NoSQL:** SQL = structured, relations, joins, ACID. Firestore = documents, flexible schema, scales horizontally, no joins → denormalize.
- **Firestore:** collections → documents → fields/subcollections. Model for your queries; composite indexes for multi-field queries; security rules for per-user access.
- **Local mobile DB:** `sqflite` (SQL), `Hive` (fast key-value, no native dep), `shared_preferences` (small settings). Offline cache → Hive or Firestore offline persistence.

### Android SDK & Android Studio
- **AndroidManifest.xml:** permissions, components, intent filters.
- **Gradle:** build config, deps, product flavors (dev/qa/staging/prod), signing.
- **Runtime permissions:** request at point of use (`permission_handler`); handle permanently-denied → deep link to Settings. Android 12+ splits `BLUETOOTH_SCAN`/`BLUETOOTH_CONNECT`.
- **Tools:** Logcat, Layout Inspector, Profiler (CPU/memory), APK Analyzer (your 267MB investigation), Device Manager.
- **Release:** build AAB → sign → Play Console internal → closed → production staged rollout.

### Build modes (commonly asked)
Debug (JIT, hot reload, asserts on) · Profile (performance testing) · Release (AOT, optimized, no debug info).

---

## PART 9 — YOUR PRODUCTS: LIKELY FOLLOW-UPS

### ✅ Model name — LOCKED
GenZGPT runs on **GPT-5.4 Mini (Azure OpenAI Studio)**. You told Reshika this in Round 1 — say **exactly that** again. Never "GPT-5", never "5.5" on Monday. Consistency with a detail-oriented ML engineer is everything.

### GenZGPT multi-agent architecture — the clean narration
"A query wakes the **discovery agent**, which embeds the query and runs **semantic search over a vector database** to find relevant deals. **GPT-5.4 Mini** is the reasoning brain, with my own **fallback algorithms** for low-confidence or missed searches. I orchestrate specialized agents with **LangGraph**:
- **purchase agent** — buy flows
- **gift card agent** — gift card lookup/redeem
- **recharge agent** — mobile/utility recharge
- **shared subscription agent** — group subscription splits

LangGraph models this as a graph — each node an agent, edges define handoffs, shared state passes context. So 'buy a gift card and split a subscription' routes through two agents in one conversation state."

**If pressed "why LangGraph vs one big prompt":** "A mega-prompt gets unreliable and unauditable as flows multiply. A graph gives deterministic routing, isolated testable nodes, and lets me put a guard so an LLM never directly triggers a payment — it *suggests*, a deterministic rule *decides*."

**If asked about hallucinations / wrong deals:** "Two guards — semantic search grounds answers in real catalogue data (RAG), and a confidence threshold falls back to deterministic search or a clarifying question rather than inventing a deal."

### AI Wellness CRM (if asked)
"Outreach automation over 10K+ leads — Claude drafts, humans approve. Five fail-CLOSED safety belts: if any dependency (suppression list, daily-cap store) is unreachable, the send halts rather than risk a non-compliant message. 1,341 integration tests. Live in production."

### AI Wellness Connect app (if asked)
"HIPAA-aware Flutter healthcare super app, sole tech lead, 35 App Store releases in 7 months, live in 4 US clinics. No PHI ever logged or stored in plaintext — encrypted at rest, redacted from logs."

### Neural Mind / RELOOP (if asked)
Personal projects, in progress. Neural Mind = AI companion (Vercel preview). RELOOP = AI auto-listing for clothing resale (GitHub). "Side projects where I explore ideas end-to-end — happy to walk through the code."

---

## PART 10 — REACH RESHIKA'S LEVEL: ML / EDGE AI / COMPUTER VISION

Reshika built Seekr's vision models for 4 years (edge AI, CNN + RNN, proprietary datasets on embedded ICs). You don't out-ML her — you converse credibly and show you understand where the app layer meets her model layer.

### CNN — one paragraph
"Standard architecture for images. Conv layers slide filters to detect features — edges, then shapes, then objects in deeper layers. Pooling downsamples (less compute, translation-invariance). ReLU adds non-linearity. Final layers classify. Powers Seekr's object/scene recognition and obstacle detection."

### Edge AI vs Cloud AI (Seekr's core thesis — say it confidently)
"Edge = model runs on the device. Lower latency, works offline, privacy-preserving (image never leaves the device) — but constrained by chip compute/memory. Cloud = stronger models but needs connectivity, adds latency + privacy concerns. Seekr is edge-first because a blind user crossing a street can't wait on a round-trip and shouldn't depend on signal."

### Fitting models on tiny hardware
- **Quantization:** 32-bit floats → 8-bit ints → ~4× smaller/faster, small accuracy cost. Key for embedded ICs.
- **Pruning:** drop low-weight connections. **Distillation:** small "student" mimics big "teacher."
- **TFLite / TFLite Micro:** runtimes for mobile / microcontrollers.
- Bridge: "On the app side I consume model output, but I understand the device team quantizes — it directly drives the latency and battery the app designs around."

### Computer vision task vocabulary (know the differences)
- **Classification:** what is this image? (one label)
- **Object detection:** what + where (bounding boxes) → obstacle alerts. Real-time → single-shot detectors **YOLO / SSD** (fast) vs two-stage R-CNN (accurate but slow). On a wearable → YOLO/SSD + quantization.
- **Semantic segmentation:** label every pixel → fine scene understanding.
- **OCR:** image → preprocess (grayscale, threshold, deskew) → detect text regions → recognize (CNN+RNN/CTC or transformer) → string. On-device: ML Kit Text Recognition / Tesseract. → Seekr's "read this menu" mode.
- **Depth estimation:** distance per pixel → obstacle proximity.

### Precision vs Recall — the killer point for a safety device 🎯
- **Precision** = of the alerts we fired, how many were real obstacles.
- **Recall** = of the real obstacles, how many we caught.
- **For an obstacle-detection safety device, recall matters more.** Missing a real obstacle (false negative) is dangerous; a false alarm (low precision) is just annoying. So you bias the confidence threshold toward **high recall**, accepting some false positives. Lower threshold → more detections (↑recall, ↓precision); higher → fewer but surer (↑precision, ↓recall).
- *Say this to Reshika.* It shows ML + product + safety judgment in one breath — exactly the seniority she's testing.

### Embeddings & semantic search (your bridge to her world)
"Embeddings map text/images into vectors where similar things sit close. Semantic search = embed the query, find nearest by cosine similarity. Same principle whether matching a user question to a deal in GenZGPT or a captured scene to known objects."

### The new product — AI smart glasses (informed read, don't overclaim)
Reshika briefed you they're moving toward glasses for the visually impaired (not public — that's why no open-source trace). Show reasoning, not inside knowledge:
"Going from a clip-on to glasses changes the engineering — eye-level camera gives a more natural field of view, but power/heat in a small frame get harder, so quantized edge models matter even more. App-side, the companion app shifts toward setup, configuration, OTA firmware updates, and a caregiver layer. I'd be excited to own that app layer as the hardware evolves." Vision without overclaiming.

### 3 questions to ask Reshika (operate at her level)
1. "Does the device send the app raw inference labels, or embeddings the app post-processes?"
2. "Are you A/B testing model versions in production? I could wire Remote Config to flip versions without an app release."
3. "Biggest pain at the app↔model boundary right now — latency, output phrasing, or mode-switching?"

---

## PART 11 — BEHAVIORAL + "WHY YOU" + CURVEBALL QUESTIONS 🆕

Round 2 is partly technical, but Lamia (COO) and a founder will also gauge fit, commitment, and communication. Have these ready — short, confident, metric-backed, no rambling.

### "Tell me about yourself" (30 sec)
"Three years building cross-platform Flutter apps and Python/FastAPI backends since April 2022. Right now I'm sole tech lead on AI Wellness Connect — a HIPAA-aware healthcare app live in 4 US clinics, 35 App Store releases in 7 months — and tech lead at GenZDealZ, India's AI student marketplace with 10K+ users and a fine-tuned GPT-5.4 Mini agent system. I ship fast and clean, I'm Mumbai-based which fits your India-residency requirement, and I'm drawn to Seekr because it's accessibility tech that genuinely changes lives."

### "Why Seekr / why this role?"
"Two reasons. The stack is exactly my strength — Flutter + Firebase, accessibility-sensitive mobile UX, AI integration — and I've done it in healthcare, which has similarly high stakes for the end user. And the mission is real: a CES 2025 Innovation Award tells me the product has validation, not just a pitch. I want to build where a bug has real user consequences — it keeps engineering standards high."

### "Why should we hire you over a Hong Kong–based developer?"
(The unspoken subtext is cost, but answer on value.) "Your JD specifically wants an India-resident developer, so I fit the hiring model. Beyond that — velocity and ownership: I shipped 35 releases in 7 months solo. The timezone gap is only 2.5 hours, so we get a clean daily overlap for standups without anyone working odd hours. And I bring the accessibility + health-data sensitivity your product needs."

### "What's your biggest weakness?"
Pick a real one that maps to their JD need (code review), with a growth story: "As a solo dev I got used to moving fast without a second reviewer. To compensate I leaned hard on tests and docs — 1,341 integration tests on the CRM, a full handover doc. I'd actually welcome a team code-review culture here; it's the one thing solo work doesn't give you." (Turns a weakness into wanting *their* environment.)

### "Tell me about a hard bug / a time you failed."
"AI Wellness needed ZEGOCLOUD real-time video and I had zero WebRTC experience, 5 days to a working telehealth prototype. I read the SDK end-to-end, reproduced every bug in an isolated test project before touching production, and shipped on day 6. The lesson: isolate the unknown before it touches prod. Same approach I'd take with your WiFi/BLE device layer."

### "How do you handle disagreement with a teammate or founder?"
"At AI Wellness the clinic operators wanted auto-sent patient follow-ups. I pushed back — HIPAA needs human review on outbound patient comms. I didn't just say no; I showed the specific rule, then proposed a draft-only flow that automated 90% but kept a human approval step. They agreed. I disagree with specifics and a path forward, not just 'no'."

### "Where do you see yourself in 3–5 years?"
"Deeper technical ownership — leading the mobile function as Seekr scales from clip-on to glasses, mentoring as the team grows. I like owning a product long enough to see it mature, which is why I've stayed multi-year in my current roles."

### "How do you keep up with new tech?"
"I build. Neural Mind and RELOOP are side projects where I test new ideas end-to-end. I follow Flutter releases, read the changelogs, and I adopt deliberately — I knew about the 2025 GetX maintainer situation, for instance, and I'd evaluate the codebase before pushing any state-management opinion here."

### "Are you interviewing elsewhere?"
Honest, brief, no desperation, no games: "I'm exploring a few remote roles, yes. Seekr is a top choice for me because of the mission-plus-stack fit I mentioned." (Don't name companies. Don't claim it's your only option.)

### Curveballs specific to your situation (rehearse these)
- **"You haven't shipped a BLE/hardware app — is that a gap?"** → "My focus is the app layer, which is what the JD specifies. The device firmware is your team's domain; I interface with it over WiFi/API like any external data source. I integrated ZEGOCLOUD and HeyGen real-time streams — same connection-state-machine problem. I'd ask for the device protocol doc day one and ramp in the first two weeks."
- **"We're a tiny startup, funding is uncertain — are you OK with that risk?"** → "Yes. I've worked at startup pace for three years; early-stage is where I do my best work and where ownership is highest. The CES award and HKSTP backing tell me the foundation is solid."
- **"Have you actually used our app?"** → ONLY safe if you have. **Action item: download both Seekr AI + Seekr Companion before Monday and try them.** Then: "Yes — I went through onboarding on both. I noted opportunities around Android reliability, app size, accessibility declarations, and latency." (Specific, shows initiative.)
- **"Your portfolio says X but you said Y…"** → Pre-empt by being consistent: 3+ years, Tech Lead (not CTO), GPT-5.4 Mini, 4 US clinics, 200+ gift cards. Never inflate.

### Behavioral framework: answer in **STAR**
Situation → Task → Action → Result. Keep it under 90 seconds. Always end on a quantified Result. You have the stories in Parts 9 + here — just keep them tight.

---

## PART 12 — THE TWO-JOBS / COMMITMENT QUESTION ⚠️ (CRITICAL — DON'T WING THIS)

**This is the question most likely to quietly sink the offer, and you haven't prepared for it.**

The facts they can see: you're **sole tech lead at AI Wellness** *and* **tech lead at GenZDealZ** — two roles, right now. Their JD says **"Full-time, remote."** A careful COO will think: *How is he full-time for us with two other jobs? Is this moonlighting? Will Seekr get real hours? Is there a conflict of interest?*

You **must** have a clear, honest answer. Pick the version that's actually true for you and rehearse it. Do **not** imply you'll silently run three full-time jobs — that reads as divided attention, burnout risk, and a possible contract/ethics problem, and it's the fastest way to a soft "no."

### Decide BEFORE Monday: what's your real plan?

**Option A — You're transitioning to one full-time role (most credible for "full-time").**
> "To be transparent about my current roles — I'm actively moving toward a single full-time focus. My GenZDealZ work has matured into more of a lead/oversight capacity, and I'm in a position to transition out of my current engagements for the right full-time role. If Seekr and I move forward, Seekr would be my primary commitment and I'd give it full-time hours. I wanted to be upfront so there's no ambiguity about my availability."

**Option B — You'd treat current roles as wind-down / contract while ramping.**
> "I have two existing engagements, but both are at a stage where I can hand over or wind down responsibilities. I'd be straight with you about timelines — I wouldn't take a full-time role I couldn't actually staff full-time."

**Option C — If you genuinely intend to keep one role and want part-time/contract with Seekr.** Then you must say so, because the JD is full-time and you'd be proposing a different arrangement. Risky, but honest beats discovered-later.

### Whatever you choose, hit these reassurances:
1. **No conflict of interest.** "AI Wellness is healthcare, GenZDealZ is a marketplace, Seekr is assistive tech — no competitive overlap, and I'd never share anything across them." (True and important — say it.)
2. **Real overlap hours.** "HKT is only 2.5 hours ahead of IST — I can commit to your core hours and daily standups. My current US work is async and 10+ hours offset, which actually proves I manage commitments across time zones."
3. **Proof you deliver under load.** "I've run two roles concurrently and still shipped 35 releases in 7 months — so capacity isn't theoretical. But for a full-time role I'd structure my commitments so Seekr gets dedicated focus."

### What NOT to say
- ❌ "I'll just manage all three." (Red flag — divided attention.)
- ❌ Hiding the second job and hoping they don't ask. (Discovered-later kills trust.)
- ❌ Over-promising 60-hour weeks. (Sets up burnout / failure.)

**My honest push-back to you, Smit:** the cleanest, highest-offer-probability path is **Option A** — signal that Seekr would be your primary full-time home and you're transitioning. If that's not your real intention, you need to reconcile that with a JD that explicitly says full-time, *before* the call — because they will ask, and hesitation here reads as evasion. Decide your answer tonight.

---

## PART 13 — QUESTIONS YOU ASK THEM (have 4–5 ready)

End strong. Asking sharp questions signals seniority and genuine interest.

**Technical (for Reshika):**
1. "Does the device send raw inference labels or embeddings the app post-processes?"
2. "What state management + architecture does the current Flutter codebase use, so I know what I'd step into?"
3. "Biggest current pain at the app↔model boundary — latency, output phrasing, mode-switching?"
4. "Are you A/B testing model versions in production today?"

**Product / business (for Lamia):**
5. "How does the app team collaborate with the AI and business teams on new features — early input, or specs handed over?"
6. "The B2B direction — hotels, museums, the SEED program — how does that shape the near-term app roadmap?"
7. "What does success look like for this role in the first 90 days?"

**One that shows you did homework:**
8. "I noticed app-size, Android reliability, and accessibility declarations are areas worth inspecting — are any of those already on the roadmap?"

---

## PART 14 — SALARY (if it comes up)

You set your floor at **USD $2,000/month**; for Seekr you targeted **USD $3,000–3,500/month** with equity as a separate ask. The JD says salary is negotiable, so **anchor with a range, not a floor**.

**Script:** "Based on the scope — owning the app(s), CI/CD, releases on both platforms, and the AI integration work — I'm looking at USD 3,000 to 3,500 a month. Happy to find the right number for your budget once we align on scope."

**If pushed:** offer structure, not a lower floor — "I'm open to a 3-month trial around USD 2,500 with a performance review to 3,000+." Never go below $2,000. Ask about equity separately ("Given I'd be a core technical owner at this stage, is there an equity component?"). Prefer USD payment for forex consistency.

Don't raise salary first — let them. If they ask early, give the range and move on.

---

## PART 15 — 5-DAY PLAN + DAY-OF CHECKLIST

**Today is Wed, Jun 24. Interview Mon, Jun 29.**

### Wed Jun 24 (tonight) — decide + set up
- [ ] **Decide your two-jobs answer (Part 12).** This is the most important non-coding prep.
- [ ] Download + try **both** Seekr apps (so "have you used it?" is a yes).
- [ ] Lock the GPT-5.4 Mini answer in your head.

### Thu Jun 25 — syntax fluency
- Type every block in Parts 2 & 3 by hand in DartPad / Python REPL. No copy-paste.
- Do Part 7 DSA once each, out loud.

### Fri Jun 26 — Flutter + scenarios
- Rebuild Part 4 widgets from scratch without looking. Then Part 5 scenarios — say answers aloud as if pairing. Drill the corrected WiFi answer until the multi-network API is natural.

### Sat Jun 27 — Python/data + products + behavioral
- Part 6 from scratch. Rehearse Part 9 product narrations + Part 11 behavioral answers out loud.

### Sun Jun 28 — mock + ML
- Do 2–3 unseen easy/medium problems talking aloud the whole time (record yourself; watch for silence/freezing).
- Read Part 10 twice; practice the precision-vs-recall point and the 3 questions for Reshika.

### Mon Jun 29, 1:00 PM IST (30 min before):
- [ ] Test Meet + screen share on the real machine
- [ ] IDE warm: blank Dart + Python files open, a runnable Flutter project ready, DartPad tab open
- [ ] Part 16 cheat sheet open on a second screen / printed
- [ ] Notifications OFF, room quiet, water, paper + pen
- [ ] Re-read Part 1 (the 5-step loop) one final time

---

## PART 16 — ONE-PAGE GLANCE CHEAT SHEET (open this 10 min before)

**THE LOOP:** Clarify → Plan aloud → Code narrating → Test + edge cases → Trade-off. *Silence is the only real failure.*

**CLARIFY 4:** empty/null? size? duplicates/negatives? speed or clarity?

**WHEN STUCK:** brute force first → say what you're stuck on → ask for a hint (it's collaboration).

**DART MUSCLE MEMORY:**
`for (final x in list)` · `list.where((x)=>...).map((x)=>...)` · `int? x; x ?? d; x?.y; x!` · `setState(()=>...)` · `await f(); try{}catch(e){}` · `class A{ A(this.x); }`

**PYTHON MUSCLE MEMORY:**
`[x for x in xs if c]` · `{k:v for ...}` · `Counter(xs).most_common(n)` · `defaultdict(list)` · `dict.get(k, default)` · `json.loads/dumps`

**FLUTTER BUGS ON SIGHT:** setState after dispose (`if(!mounted)return;`) · setState in build · undisposed controllers · context across async gap · ListView in Column without Expanded.

**WIFI ANSWER (corrected):** local device WiFi has no internet → use Android **multi-network API**: `WifiNetworkSpecifier` for local-only device AP + `requestNetwork(TRANSPORT_CELLULAR + NET_CAPABILITY_INTERNET)` for cellular; avoid process-wide `bindProcessToNetwork()` as the default; retry → TTS fallback. (Do NOT say "Android 12 auto-switches.")

**ML ONE-LINERS:** edge AI = low latency + offline + private, constrained compute · CNN = conv+pool+ReLU+classify · **safety device → bias for RECALL** (a missed obstacle is dangerous; a false alarm is just annoying) · semantic search = embed + cosine similarity.

**FACTS (never inflate):** 3+ yrs · Tech Lead (not CTO) · **GPT-5.4 Mini** · 4 US clinics · 35 releases/7 months · 10K+ users · 200+ gift cards · floor $2K/mo, target $3–3.5K.

**TWO-JOBS ANSWER:** "Transitioning to a single full-time focus; Seekr would be my primary commitment. No competitive overlap. 2.5h overlap with HKT." (Decide your real version.)

**5 QUESTIONS TO ASK:** codebase architecture? · app↔model pain point? · raw labels vs embeddings? · first-90-days success? · Android reliability + app-size on roadmap?

---

*You shipped 35 releases in 7 months solo. You solved their real WiFi problem live in Round 1 (now you can solve it even more precisely). Round 2 confirms what they already saw. Reload the syntax, rehearse the loop and the two-jobs answer, walk in calm. — Good luck Monday, Smit.*
