# 🧠 MemoryLens

### Your camera remembers what you don't.

> MemoryLens turns images of real-world information into structured, searchable personal memories. Capture a hackathon notice, a receipt, a whiteboard, or a visiting card — and ask about it later in plain language.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Gemini API](https://img.shields.io/badge/Gemini%20API-8E75B2?style=for-the-badge&logo=google&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-000000?style=for-the-badge&logo=dart&logoColor=white)

---

## Table of Contents

1. [What is MemoryLens?](#-what-is-memorylens)
2. [The Problem](#-the-problem)
3. [The Solution](#-the-solution)
4. [Demo](#-demo)
5. [Key Features](#-key-features)
6. [Real-World Use Cases](#-real-world-use-cases)
7. [Product Walkthrough](#-product-walkthrough--app-screens)
8. [How It Works](#-how-it-works)
9. [System Architecture](#-system-architecture)
10. [End-to-End Data Flow](#-end-to-end-data-flow)
11. [AI & Vision Architecture](#-ai--vision-architecture)
12. [Search & Retrieval Architecture](#-search--retrieval-architecture)
13. [AI Token Optimization](#-ai-token-optimization)
14. [Privacy & Security](#-privacy--security)
15. [Design System](#-design-system)
16. [Tech Stack](#-tech-stack)
17. [Project Structure](#-project-structure)
18. [Engineering Challenges](#-engineering-challenges--solutions)
19. [Technical Decisions](#-technical-decisions)
20. [Why MemoryLens?](#-why-memorylens)
21. [Testing](#-testing)
22. [Installation](#-installation)
23. [Configuration](#-configuration)
24. [Roadmap](#-roadmap)
25. [Future Vision](#-future-vision)
26. [Hackathon](#-hackathon)
27. [Team](#-team)
28. [Contributing](#-contributing)
29. [License](#-license)
30. [Acknowledgements](#-acknowledgements)
31. [References](#-references)
32. [Contact](#-contact)

---

## 🧠 What is MemoryLens?

MemoryLens is a mobile-first application that converts captured images into structured, queryable memories.

Most photo apps answer: *"Where are my photos?"*
MemoryLens answers: *"What was that thing I saw?"*

A student photographs a hackathon notice. MemoryLens reads it, extracts the title, deadline, and location, and stores it as a structured memory. Three days later, the student asks *"What was that hackathon?"* — and gets a direct, conversational answer pointing back to the original image.

The pipeline:

```
Capture → Understand → Structure → Store → Search → Act
```

MemoryLens is not a gallery replacement. It is a purpose-built tool for the specific workflow of:

> *"I photographed this because it mattered. Help me remember why."*

---

## ❗ The Problem

People encounter information worth remembering constantly:

- College notices pinned to bulletin boards
- Hackathon and event posters
- Electricity bills and receipts
- Visiting cards from professionals
- Deadlines on whiteboards
- Internship and workshop announcements
- Medicine labels and product information

The standard response: take a photo.

The outcome: that photo joins thousands of others. Six days later:

> *"I photographed that notice."* — Which one?
> *"Which screenshot had the internship deadline?"* — Scroll through 500 screenshots.
> *"What was written on that whiteboard?"* — Check 30 similar photos.
> *"Where was that event near the library?"* — Unknown.

**The information is not missing. Retrieval is the problem.**

Photo apps organize by date, location, or album. None of them understand *why* you took the photo. None of them know that a particular image contains a deadline for September 5th.

---

## 💡 The Solution

MemoryLens reframes image capture as a memory creation event.

```
RAW IMAGE
    ↓
VISUAL UNDERSTANDING (Gemini Vision)
    ↓
TEXT EXTRACTION + STRUCTURE
    ↓
title · summary · category · entities · dates · actions
    ↓
LOCAL SQLite STORAGE
    ↓
NATURAL-LANGUAGE RETRIEVAL
    ↓
ACT — set reminders, review originals, share details
```

The key distinction: **AI runs once at capture time**, not repeatedly during search. What gets stored is not just an image — it's meaning.

---

## 🎥 Demo

> 📌 **Demo video and screenshots coming soon.** Seed images used during development are in `assets/images/seed/`.

Sample seed data categories:
- `hackathon_notice.jpg` — Event with deadline
- `electric_bill.jpg` — Receipt with amount
- `business_card.jpg` — Contact information
- `zomato_internship.jpg` — Opportunity with deadline
- `gsoc_poster.jpg` — Event announcement
- `coffee_receipt.jpg` — Daily receipt
- `library_notice.jpg` — Notice with dates

---

## ✨ Key Features

### 📷 Smart Capture
Capture using the device camera or import from the gallery. Images are saved immediately at up to 1920px width with 85% quality compression before AI processing begins.

### 👁️ Vision Understanding
Google Gemini (`gemini-1.5-flash`) analyzes the full image — reading printed text, handwriting, and visual layout to understand context that pure OCR misses.

### 📝 Structured Memory
Every captured image produces a structured record containing:
- **Title** — 3–7 word human-readable label
- **Summary** — One-sentence description
- **Category** — `event`, `receipt`, `contact`, `document`, `notice`, or `other`
- **Extracted Text** — All visible text, verbatim
- **Entities** — Key-value pairs (merchant, amount, event name, location, organizer, etc.)
- **Dates** — ISO 8601 timestamps typed as `deadline`, `event_date`, `issue_date`
- **Actions** — Actionable tasks extracted (register, pay, attend) with due dates

### 🔎 Natural-Language Search
Ask questions in plain English, Hinglish, or Marathi:
- *"What was that hackathon notice?"*
- *"What deadlines are coming up?"*
- *"Which receipt had the electricity bill?"*
- *"Find something about an internship deadline."*

### 🎙️ Voice Search
Tap the microphone on the Search screen and speak your query. Uses the device's native speech recognition (`speech_to_text`) — no additional API call required.

### 🔔 Smart Reminders
- Deadlines detected during extraction can be converted into scheduled device notifications.
- Manual reminders (text-only, with optional photo attachment) can be created independently.
- Advance notification fires one day before a deadline automatically.

### 🧠 Remember Screen
A proactive tab that surfaces upcoming deadlines, recently added memories, and suggested actions — without requiring the user to search.

### 📚 Memory Browser
Browse all memories filtered by category (Event, Receipt, Notice, etc.) with a scrollable card layout.

### 🌓 Light & Dark Themes
Full warm Peach/Terracotta light theme and a deep warm Brown/Terracotta dark theme — both with independent semantic color systems.

### 🔒 Local-First Storage
All images and structured memory data live on-device in `ApplicationDocumentsDirectory` and a local SQLite database. No application backend, no cloud storage.

> ⚠️ Note: AI image processing requires an outbound Gemini API request at capture time. Once extracted, all memory data and images remain on-device.

---

## 🎯 Real-World Use Cases

### 🎓 Student — Hackathon Notice
**Situation:** A poster is pinned outside the CS department.
**Capture:** Student photographs it with MemoryLens.
**Extracted:** Title: *AI Innovation Hackathon*, Deadline: *September 5, 11:59 PM*, Location: *Main Auditorium*, Action: *Register*.
**Later:** *"What was that hackathon?"* → Direct answer with original image.

### 🧾 Household — Electricity Bill
**Situation:** Monthly bill arrives. Amount and due date need to be remembered.
**Capture:** Photo of the bill.
**Extracted:** Merchant: *State Electricity Board*, Amount: *₹1,840*, Due date: *September 10*.
**Later:** *"What was my electricity bill?"* → Amount and due date retrieved instantly.

### 💼 Professional — Visiting Card
**Situation:** Met someone at a conference, received their card.
**Capture:** Photo of the visiting card.
**Extracted:** Name, phone, email, company, designation as structured entities.
**Later:** *"What was that person's email from the conference?"* → Contact details retrieved.

### 📋 Student — Internship Poster
**Situation:** Internship opportunity poster spotted on campus.
**Capture:** Photo of the poster.
**Extracted:** Company: *Zomato*, Role: *SDE Intern*, Deadline: *September 15*, Action: *Apply*.
**Later:** Reminder set. Advance notification fires on September 14.

---

## 📱 Product Walkthrough / App Screens

| Screen | Purpose |
|---|---|
| **Splash** | Animated brand intro; routes to Landing or Home based on auth state |
| **Landing** | First-time welcome with rotating product quotes and CTA |
| **Sign In** | Prototype auth — accepts any credentials |
| **Create Account** | Prototype registration — accepts any input |
| **Home** | Dashboard with quick capture actions, recent memories, search shortcut |
| **Remember** | Proactive tab surfacing upcoming deadlines and recent captures |
| **Capture (Bottom Sheet)** | Camera / Gallery / Manual Reminder — launched from bottom nav |
| **Processing** | Animated status while Gemini processes the image |
| **Extraction Review** | User verifies and edits AI-extracted data before saving |
| **Memories** | Full memory browser with category filters |
| **Search** | Natural-language + voice search with AI-powered answers |
| **Memory Details** | Original image + full structured data + reminder/share actions |
| **Reminders** | Upcoming and completed reminders management |
| **Profile** | Theme toggle and basic app settings |

---

## 🪄 How It Works

### 1 — 📷 Capture
User opens the Capture sheet from the bottom navigation bar. They choose camera, gallery, or manual reminder. The image is copied locally at up to 1920px before any AI call is made.

### 2 — 👁️ Understand
The local image is read as bytes, Base64-encoded, and sent with a strict JSON-schema prompt to the Gemini API (`gemini-1.5-flash`). Temperature is set to `0.1` to maximize deterministic structured output.

### 3 — 📝 Extract & Review
Gemini returns a JSON object. The app cleans markdown artifacts with regex, parses the structure, and presents it to the user in the Extraction Review screen. The user can edit any field before saving.

### 4 — 🧠 Create Memory
On confirmation, a `Memory` object is created and written to the local SQLite database (`memory_lens.db`). The original image file remains on-device.

### 5 — 🔎 Search
User types or speaks a query. The app retrieves the 30 most recently created memory metadata records and sends them — along with the query — to Gemini as text. No images are sent during search. Gemini reasons over the context and returns a ranked list of memory IDs and a conversational answer.

### 6 — 🔔 Act
From Memory Details, the user can schedule a local device notification for any extracted deadline. Reminders are stored in `flutter_local_notifications` and fire even when the app is closed.

---

## 🏗️ System Architecture

```mermaid
flowchart TD
    subgraph DEVICE["On-Device"]
        A["Camera / Gallery"]
        B["Flutter App UI"]
        C["Local Image Storage\n(ApplicationDocumentsDirectory)"]
        D["SQLite Database\n(memory_lens.db)"]
        H["Local Notifications\n(flutter_local_notifications)"]
    end

    subgraph REMOTE["Remote — Gemini API"]
        E["gemini-1.5-flash\n(Vision + Text)"]
    end

    A -->|XFile capture| B
    B -->|Copy to disk| C
    B -->|Base64 image + prompt| E
    E -->|Structured JSON| B
    B -->|Memory object| D
    D -->|Metadata context| B
    B -->|Text query + memory list| E
    E -->|Ranked IDs + answer| B
    B -->|Schedule| H
```

**Key boundary:** Images live on-device. Only the image bytes (at capture time) and memory text metadata (at search time) travel to the Gemini API.

---

## 🔄 End-to-End Data Flow

### Capture Flow

```
ImageService.captureFromCamera() / pickFromGallery()
    ↓
ImageService.saveImageLocally()          ← copies to ApplicationDocumentsDirectory/memories/
    ↓
AiService.extractFromImage()
    ↓  base64-encodes image bytes
    ↓  POST generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent
    ↓  temperature=0.1, maxOutputTokens=8192
    ↓  returns raw JSON string
    ↓
_parseExtractionResponse()               ← regex-strips markdown fences, parses JSON
    ↓
Memory object constructed
    ↓
ExtractionReviewScreen                   ← user verifies / edits
    ↓
DatabaseService.insertMemory()           ← written to memory_lens.db
```

### Search Flow

```
User query (typed or voice)
    ↓
DatabaseService.getAllMemories()         ← retrieves all stored memories
    ↓
Sort by createdAt descending, take 30
    ↓
Build memory context JSON array          ← title, summary, extracted_text, entities, dates, actions (NO images)
    ↓
AiService.rankMemoriesForQuery()
    ↓  POST gemini-1.5-flash:generateContent (text-only)
    ↓  temperature=0.1, maxOutputTokens=8192
    ↓  returns { answer, rankedIds }
    ↓
Display answer + ranked Memory cards
    ↓
Fallback: keyword search if AI call fails
```

---

## 🤖 AI & Vision Architecture

**Model:** `gemini-1.5-flash` via the Google Generative Language REST API v1beta.

**Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`

**Authentication:** API key passed as a query parameter. *(Hackathon prototype — see Configuration section.)*

### Extraction Prompt Strategy

The extraction prompt uses structured instruction with explicit JSON schema:

```json
{
  "title": "3-7 word label",
  "summary": "One sentence description",
  "category": "event|receipt|contact|document|notice|other",
  "extracted_text": "All visible text verbatim",
  "entities": { "key": "value" },
  "dates": [{ "type": "deadline|event_date|issue_date|other", "value": "ISO 8601" }],
  "actions": [{ "type": "apply|register|pay|attend|other", "description": "...", "dueDate": "ISO 8601 or null" }]
}
```

The prompt explicitly says: *"Return ONLY a valid JSON object — no prose, no markdown fences."*

Temperature is set to `0.1` to minimize hallucinations and maximize deterministic output.

**Fallback handling:** If the model wraps output in markdown fences (` ```json `), the parser strips them with regex before JSON decode. If parsing still fails, a `Memory` with `processingFailed = true` is returned so the raw image is not lost.

### Search Prompt Strategy

At search time, no image data is transmitted. The prompt includes:
- The user's query (supports English, Hinglish, Marathi natively)
- A JSON array of up to 30 memory metadata records
- Instructions to synthesize a conversational answer and return ranked memory IDs

---

## 🔎 Search & Retrieval Architecture

**Current implementation:** LLM-based context window retrieval.

The search flow sends the user query plus up to 30 memory metadata records (as structured text) to Gemini. The model reasons over the full context and returns:
1. A synthesized conversational answer
2. A ranked list of relevant memory IDs

**Why this instead of vector/semantic search?**

The codebase includes a stub `_cosineSimilarity()` function and an `embedding` field on the `Memory` model, but local embedding-based retrieval is **not currently active**. The LLM context window approach was chosen for the prototype because:

- It handles temporal reasoning natively (*"What deadlines are next week?"*)
- It supports multilingual queries without separate translation
- It requires zero additional infrastructure for a hackathon demo
- At 5–30 memories, context window size is not a bottleneck

**Keyword fallback:** If the Gemini API call fails for any reason, the app falls back to client-side keyword matching across title, summary, and extracted text.

**Scaling note:** This approach is O(n) in token cost as memories grow. The intended future path is local embedding generation + cosine similarity pre-filtering before sending a bounded top-k set to the LLM.

---

## ⚡ AI Token Optimization

A naive vision search would re-send all captured images to the AI at every query — extremely expensive and slow.

MemoryLens avoids this by separating concerns:

| Stage | What is sent to AI | When |
|---|---|---|
| Capture | Full image (Base64) + extraction prompt | **Once per image** |
| Search | Text metadata of ≤30 memories + query | **Once per query** |
| Reminders | Nothing | Local only |
| Memory Details | Nothing | Local only |

After a memory is created, the original image is **never sent to the AI again**. All retrieval works on the compact structured text stored in SQLite.

This significantly reduces repeated image processing costs compared to architectures that re-analyze images during search.

---

## 🔐 Privacy & Security

**What stays on-device:**
- All captured images (stored in `ApplicationDocumentsDirectory/memories/`)
- All structured memory data (SQLite at the default `getDatabasesPath()` location)
- Reminder schedules (managed by `flutter_local_notifications`)
- Auth state (stored in `SharedPreferences`)

**What goes to the Gemini API:**
- Image bytes (Base64-encoded) — sent once at capture time
- Memory text metadata — sent as plaintext context during search queries

**What this means:**

> MemoryLens is **local-first** — your memories and images are stored on your device. AI image processing requires a remote request to Google's Gemini API. The app is not fully offline.

**API key handling (Hackathon prototype):**

The API key is stored in `lib/config/api_config.dart`, which is excluded from version control via `.gitignore`. For production, this should be moved to a backend proxy or a secrets management solution — never hardcoded in a client application.

**No encryption at rest** in the current prototype. Production deployment would require SQLCipher or equivalent.

**No user authentication backend.** The current sign-in/create-account flow is a UI prototype using `SharedPreferences` to persist a boolean flag. No passwords are stored.

---

## 🎨 Design System

MemoryLens deliberately avoids the generic "AI purple" or sterile white aesthetic. The visual identity is built around warmth and personality.

### Color Philosophy

| | Light Theme | Dark Theme |
|---|---|---|
| **Feel** | Warm sunlight | Warm evening |
| **Background** | `#FFF8F3` — warm cream | `#1C1513` — deep warm brown |
| **Surface** | `#FFFFFF` | `#271D1A` |
| **Surface Elevated** | `#FFFDFC` | `#30221E` |
| **Surface Secondary** | `#F8E9DF` | `#34241F` |
| **Primary** | `#B9654D` — terracotta | `#E29477` — peach |
| **Primary Container** | `#F4D8CC` | `#513229` |
| **Accent** | `#D98C70` | `#C87559` |
| **Text Primary** | `#302522` — deep brown | `#F8EEE9` — warm cream |
| **Text Secondary** | `#806F67` | `#B5A29A` |
| **Border** | `#E8D8D0` | `#45332D` |
| **Success** | `#66856B` — warm green | `#91B395` |
| **Warning** | `#C58A45` — warm amber | `#D7A465` |
| **Error** | `#B85C5C` — muted red | `#DF8585` |

Dark mode is independently designed — not inverted light mode. The same component feels like warm candlelight in both modes.

### Typography

| Font | Usage |
|---|---|
| **Yellowtail** | Brand name, decorative accents, expressive short phrases only |
| **Manrope** | All functional UI — buttons, fields, body text, navigation, headings |

Yellowtail is never used for body copy, inputs, or navigation labels. Its role is purely expressive.

### Category Colors

Each memory category has its own distinct surface and accent color in both light and dark modes — from Event (soft lavender surface) to Receipt (warm peach) to Opportunity (soft green).

---

## 🧩 Tech Stack

| Layer | Technology | Version | Purpose |
|---|---|---|---|
| UI Framework | Flutter | SDK ≥3.3.0 | Cross-platform mobile UI |
| Language | Dart | ≥3.3.0 | Application logic |
| State Management | flutter_riverpod | ^2.5.1 | Reactive state / dependency injection |
| AI / Vision | Gemini API (`gemini-1.5-flash`) | REST v1beta | Image extraction + search reasoning |
| Local Database | sqflite | ^2.3.3+1 | Structured memory persistence |
| Image Capture | image_picker | ^1.1.2 | Camera + gallery access |
| Gallery Browser | photo_manager | ^3.12.0 | Advanced gallery access |
| Local Storage | path_provider | ^2.1.4 | App directory resolution |
| Notifications | flutter_local_notifications | ^17.2.2 | Scheduled deadline reminders |
| Timezone | timezone | ^0.9.4 | Accurate reminder scheduling |
| Voice Search | speech_to_text | ^7.4.0 | Microphone speech-to-text |
| Auth Persistence | shared_preferences | ^2.5.3 | Prototype auth state |
| HTTP | http | ^1.2.2 | Gemini API REST calls |
| Typography | google_fonts | ^6.3.2 | Manrope + Yellowtail |
| ID Generation | uuid | ^4.4.2 | Unique memory identifiers |
| Date Formatting | intl | ^0.19.0 | Localized date display |
| Grid Layout | flutter_staggered_grid_view | ^0.7.0 | Masonry memory grid |
| Path Utilities | path | ^1.9.0 | File path manipulation |

---

## 📂 Project Structure

```
lib/
├── config/
│   └── api_config.dart          # API key + model name (gitignored)
├── models/
│   ├── memory.dart              # Core Memory model + MemoryAction
│   └── memory_date.dart         # Typed date model (deadline, event_date, etc.)
├── providers/
│   ├── auth_provider.dart       # Prototype auth state (SharedPreferences)
│   ├── memory_provider.dart     # Memory list state
│   └── theme_provider.dart      # Light/Dark theme toggle
├── screens/
│   ├── app_shell.dart           # IndexedStack navigation shell
│   ├── create_account_screen.dart
│   ├── extraction_review_screen.dart
│   ├── home_screen.dart
│   ├── landing_screen.dart
│   ├── memories_screen.dart
│   ├── memory_details_screen.dart
│   ├── processing_screen.dart
│   ├── profile_screen.dart
│   ├── remember_screen.dart
│   ├── reminders_screen.dart
│   ├── search_screen.dart
│   ├── sign_in_screen.dart
│   └── splash_screen.dart
├── services/
│   ├── ai_service.dart          # Gemini extraction + search ranking
│   ├── database_service.dart    # SQLite CRUD (memory_lens.db)
│   ├── image_service.dart       # Camera/gallery capture + local copy
│   ├── notification_service.dart # Scheduled deadline notifications
│   └── sync_service.dart        # Seed data loader (development)
├── theme/
│   └── app_theme.dart           # MemoryLensColors + ThemeData builder
├── utils/
│   ├── date_utils.dart          # Date formatting helpers
│   └── seed_data.dart           # Development seed memory generator
├── widgets/
│   ├── category_chip.dart       # Colored category label
│   ├── date_badge.dart          # Deadline/date display badge
│   ├── empty_state.dart         # Empty screen placeholder
│   ├── glass_container.dart     # Frosted card effect
│   ├── manual_reminder_sheet.dart # Text-only reminder creation
│   ├── memory_card.dart         # Memory list/grid card
│   └── staged_progress.dart     # Multi-step processing indicator
└── main.dart                    # App entry, ProviderScope, MaterialApp

assets/
└── images/seed/                 # Development seed images (11 JPEGs)

android/
└── app/src/main/AndroidManifest.xml  # Permissions: CAMERA, INTERNET, RECORD_AUDIO, etc.
```

---

## 🧗 Engineering Challenges & Solutions

| Challenge | Root Cause | Solution |
|---|---|---|
| Malformed AI JSON output | Gemini occasionally wraps JSON in markdown fences | Regex pre-processing strips ` ```json ` before `jsonDecode()`. Falls back to `processingFailed=true` to preserve capture. |
| Broken app on extraction failure | Unhandled parsing exceptions crashed the app | `try/catch` at every JSON field with per-field defaults; `processingFailed` flag ensures raw images are never silently lost. |
| Image persistence across app restarts | `XFile` temp path is ephemeral | `ImageService.saveImageLocally()` copies to `ApplicationDocumentsDirectory/memories/` immediately at capture, before AI processing begins. |
| Search bar text vertically clipping | Hardcoded `height: 44` on `TextField` container | Removed fixed height constraint; let `TextField` internal padding size the container naturally. |
| Black screen on back navigation | Popping the root `AppShell` navigator accidentally | Removed `leading` back buttons from nested screens; custom `PopScope` in `AppShell` intercepts system back to route to Home tab. |
| App exit confirmation boring | Default system back dialog | Custom `PopScope` shows a playful "Escaping reality?" dialog on Home tab with Manrope typography. |
| `onPopInvoked` deprecation | Flutter 3.22+ deprecation | Acknowledged — `onPopInvokedWithResult` migration is in progress. |

---

## 🧠 Technical Decisions

### Why Flutter?
Single codebase for Android target. Riverpod + widget composition maps well to the layered UI needed (cards, sheets, animated processing screen). Hot reload significantly accelerated UI iteration.

**Trade-off:** Larger APK size than a native-only Android app.

### Why Gemini `gemini-1.5-flash`?
Multimodal by default — handles image + text in a single request. `flash` tier offers lower latency than `pro` and is cost-appropriate for a hackathon demo. The 1M token context window is more than sufficient for the 30-memory search context.

**Trade-off:** Requires internet at capture time. Not available offline.

### Why SQLite over a remote database?
All memory data stays on-device. No backend infrastructure to set up, no authentication complexity, no data residency concerns. `sqflite` provides a well-tested relational store with full SQL query capabilities.

**Trade-off:** Data does not sync across devices.

### Why LLM retrieval instead of vector search?
At hackathon scale (5–50 memories), sending all metadata to the LLM is faster to build, supports temporal queries (*"What's due next week?"*) that vector similarity cannot handle natively, and supports multilingual input without a separate embedding model.

**Trade-off:** O(n) API cost as memories grow. Not suitable for thousands of memories.

### Why `gemini-1.5-flash` for both extraction and search?
Avoids integrating separate services (OCR API + embedding API + vector DB + LLM). One model, one endpoint, one authentication flow. Appropriate for prototype scope.

**Trade-off:** Not optimal for production at scale; production architecture would separate these concerns.

### Why local image storage instead of a CDN?
Eliminates network dependency for image display. Memory Details and card thumbnails load instantly from the filesystem without any API call.

**Trade-off:** Images are lost if the user uninstalls the app or clears storage.

---

## 🆚 Why MemoryLens?

Photo libraries and AI-powered galleries are powerful tools. Google Photos already performs strong image search and can find objects and people in photos.

MemoryLens serves a different, more focused use case:

| Dimension | Photo Gallery | MemoryLens |
|---|---|---|
| Primary purpose | Archive moments | Extract actionable information |
| Search model | Visual similarity / date / location | Semantic query over structured metadata |
| Output | Returns photos | Returns answers + original images |
| Deadlines | Not tracked | Extracted and actionable |
| Actions | None | Register, apply, pay, attend — with reminders |
| Temporal reasoning | Limited | Native (via LLM context) |
| Data unit | Image | Structured memory |

MemoryLens is not trying to replace your gallery. It targets the specific moment where you see information that requires action, and you need to retrieve it later on demand.

---

## 🧪 Testing

**Static analysis:** `flutter analyze` passes for all new files introduced in this project. A small number of pre-existing warnings remain in older screens (unused imports, deprecated APIs) and are documented in the Challenges section above.

**Automated tests:** No unit or widget tests have been written for this prototype.

**Manual testing performed on:** Motorola G85 5G (Android 14, Adreno GPU, Vulkan/Impeller rendering).

> Automated test coverage is currently absent. Core capture, extraction, storage, search, and reminder flows are manually verified. Test infrastructure (`flutter_test`, `flutter_lints`) is configured and ready.

---

## ⚙️ Installation

### Prerequisites

- Flutter SDK ≥ 3.3.0
- Android SDK (API 21+)
- Android Studio or VS Code with Flutter extension
- Android device or emulator
- Google Gemini API key (see Configuration)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/IamDhruv777/IQOO.git
cd IQOO

# 2. Install dependencies
flutter pub get

# 3. Configure your API key (see Configuration section)

# 4. Run on a connected Android device
flutter run
```

---

## 🔑 Configuration

Create the file `lib/config/api_config.dart` (this file is gitignored and must be created locally):

```dart
// lib/config/api_config.dart
const String kGeminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
const String kGeminiModel  = 'gemini-1.5-flash';
```

Obtain a free API key at [Google AI Studio](https://aistudio.google.com/).

### Android Permissions (pre-configured in `AndroidManifest.xml`)

| Permission | Purpose |
|---|---|
| `CAMERA` | Image capture |
| `READ_MEDIA_IMAGES` | Gallery access (Android 13+) |
| `READ_EXTERNAL_STORAGE` | Gallery access (Android < 13) |
| `INTERNET` | Gemini API calls |
| `RECORD_AUDIO` | Voice search |
| `POST_NOTIFICATIONS` | Deadline reminders (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Precise reminder timing (Android 12+) |
| `VIBRATE` | Notification vibration |

---

## 🗺️ Roadmap

### ✅ Completed
- Camera + gallery image capture
- Gemini vision extraction (title, summary, category, text, entities, dates, actions)
- Local image storage (`ApplicationDocumentsDirectory`)
- SQLite persistence (`memory_lens.db`)
- Extraction review screen with user editing
- Natural-language search (LLM context window approach)
- Keyword search fallback
- Voice search (speech_to_text)
- Scheduled deadline reminders (advance + exact)
- Manual reminders with optional image attachment
- Remember screen with proactive deadline surfacing
- Memory details with original image
- Category browsing
- Light + Dark themes (independent warm palettes)
- Beautiful landing / prototype auth flow
- `flutter analyze` passing for new code

### 🚧 In Progress / Known Issues
- `onPopInvoked` → `onPopInvokedWithResult` migration (deprecation warning)
- Unused imports cleanup in several older screens
- Search screen: unused `theme` variable

### 🔮 Planned (Post-Hackathon)
- Local embedding generation + cosine similarity pre-filtering for large memory collections
- On-device OCR as a fallback when Gemini is unavailable
- Related memory discovery (link semantically similar memories)
- Batch re-indexing for memories captured with `processingFailed = true`
- Backend API key proxy (production security)
- Database encryption at rest
- iCloud / Google Drive backup for cross-device sync
- Broader input types (audio notes, PDF documents)

---

## 🔮 Future Vision

MemoryLens points toward a simple idea: your phone should function as a genuine external memory system, not just a camera roll.

The longer-term direction is a personal memory layer that:

- Resurfaces relevant memories proactively before you ask
- Discovers relationships between things you captured weeks apart
- Works entirely on-device with local AI models
- Handles broader inputs — audio, documents, handwritten notes
- Integrates with your calendar and task tools

These are not current features. They represent the direction the product is designed to grow toward.

---

## 🏆 Hackathon

| Field | Details |
|---|---|
| **Project** | MemoryLens |
| **Track** | AI / Productivity |
| **Repository** | [github.com/IamDhruv777/IQOO](https://github.com/IamDhruv777/IQOO) |
| **Demo Device** | Motorola G85 5G (Android 14) |

---

## 👥 Team

| Member | Role | GitHub |
|---|---|---|
| Dhruv Madderlawar | Lead Developer — Architecture, AI, UI, Navigation | [@IamDhruv777](https://github.com/IamDhruv777) |
| Dishant Parjane | UI Components, Theme System | [dishant1313](https://github.com/dishant1313)|
| Ishika Mahadar | Models, Services | [Ishika-eng](https://github.com/Ishika-eng) |

---

## 🤝 Contributing

This is a hackathon project. If you'd like to build on it:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Run `flutter analyze` — ensure no new errors
5. Submit a Pull Request with a clear description

---

## 📜 License

No license file has been added to this repository yet. License information will be added.

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/) — The UI framework
- [Google Gemini](https://deepmind.google/technologies/gemini/) — Vision and language model
- [sqflite](https://pub.dev/packages/sqflite) — Flutter SQLite implementation
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) — State management
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) — Scheduled notifications
- [speech_to_text](https://pub.dev/packages/speech_to_text) — Voice input
- [google_fonts](https://pub.dev/packages/google_fonts) — Manrope + Yellowtail typography

---

## 📚 References

- [Google Generative Language API Documentation](https://ai.google.dev/api/generate-content)
- [Flutter Documentation](https://docs.flutter.dev/)
- [sqflite Documentation](https://pub.dev/packages/sqflite)
- [flutter_local_notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [speech_to_text Documentation](https://pub.dev/packages/speech_to_text)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material Design 3 Guidelines](https://m3.material.io/)

---

## 📬 Contact

- **GitHub:** [github.com/IamDhruv777](https://github.com/IamDhruv777)
- **Repository:** [github.com/IamDhruv777/IQOO](https://github.com/IamDhruv777/IQOO)

---

<p align="center">
  <i>Your gallery stores the picture. MemoryLens stores why it mattered.</i>
</p>
