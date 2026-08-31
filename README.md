# MemoryLens 👁️

> **"You don't need to remember where you saved it. You only need to remember what you're looking for."**

MemoryLens turns your phone into a searchable personal memory layer. Capture a notice, receipt, business card, or any document — AI extracts the meaning, and you find it later in plain English.

Built for the **iQOO Hackathon 2026, Pune** in ~30 hours.

---

## Quick Start

### 1. Add your Gemini API key

Open `lib/config/api_config.dart` and replace the placeholder:

```dart
const String kGeminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

Get a free key at: https://aistudio.google.com/app/apikey

> This file is gitignored — never commit your real key.

### 2. Run on Android device

```bash
# Connect your Android device via USB with USB debugging enabled
flutter devices          # confirm your device is listed
flutter run              # builds and installs on device
```

Or from Android Studio: open the `memory_lens/` folder and click Run.

**Minimum Android version:** Android 6.0 (API 23)  
**Tested on:** iQOO device (Android 14)

---

## App Flow

```
Home → Capture (Camera) or Import (Gallery)
     → Processing screen ("Reading image…" → "Extracting details…")
     → Extraction Review (editable title, see AI output)
     → Save → Memory stored locally
     → (later) Search with natural language → correct memory returned
     → Memory Details → original image + extracted info + deadline
     → "Remind me" → local notification scheduled
```

---

## Demo Scenario (for judging)

1. Capture a hackathon notice live with the camera
2. AI extracts: event name, deadline, location
3. Save the memory
4. Point out the 8 pre-seeded unrelated memories (receipts, contacts, events, notices)
5. Search with a vague query: *"that AI competition I saw"*
6. Correct memory surfaces — original image visible
7. Open details → deadline detected → tap "Remind me" → notification fires

---

## Architecture Notes (Hackathon Shortcuts)

| What | Shortcut | Production approach |
|---|---|---|
| **Semantic search** | AI text ranking — sends all memory summaries to Gemini and asks it to rank by relevance | Embeddings + pgvector / dedicated vector DB |
| **API key** | Stored in client-side `api_config.dart` (gitignored) | Backend proxy or Firebase Remote Config |
| **Offline retry** | Raw capture saved; manual retry button | WorkManager background job queue |
| **No unit tests** | Time budget | Add as CI step |

The "semantic search" approach works because the demo dataset is small (8–15 memories). The AI's reasoning capability acts as the semantic layer — it understands that "that AI competition I saw" matches "iQOO AI Hackathon 2026." This is not a production pattern.

---

## Project Structure

```
lib/
  config/        api_config.dart (gitignored — add your key here)
  models/        Memory, MemoryDate
  services/      DatabaseService, AiService, NotificationService, ImageService
  providers/     memory_provider.dart (Riverpod)
  screens/       HomeScreen, ProcessingScreen, ExtractionReviewScreen,
                 MemoryDetailsScreen, SearchScreen
  widgets/       MemoryCard, CategoryChipWidget, DateBadge,
                 EmptyStateWidget, StagedProgress
  utils/         date_utils.dart, seed_data.dart
  main.dart
```

---

## Seed Images

The app seeds 8 demo memories on first launch. The seed images live in `assets/images/seed/`. If the images are missing, memories will show a placeholder thumbnail but all text/metadata will still display correctly.

To add real seed images, place JPEGs in `assets/images/seed/` with these exact filenames:
- `hackathon_notice.jpg`
- `coffee_receipt.jpg`
- `business_card.jpg`
- `library_notice.jpg`
- `amazon_order.jpg`
- `project_timeline.jpg`
- `workshop_flyer.jpg`
- `fee_receipt.jpg`

---

## Privacy

Captured images are sent to Google's Gemini API for processing. The app discloses this to the user before each save. Images are not stored remotely — only used transiently for extraction.
