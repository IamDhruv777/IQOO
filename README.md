# 🧠 MemoryLens

*Your intelligent, offline-first photographic memory.*

**MemoryLens** is a mobile application that allows you to photograph real-world information (college notices, receipts, visiting cards, posters, whiteboards) and instantly transforms them into structured, searchable personal memories. It doesn't just save the photo—it understands what matters inside it, connects related memories, and helps you act on important deadlines.

---

## 🌟 Core Features
*   **📷 Smart Capture:** Take a photo or upload from your gallery, and the app instantly extracts dates, entities, and summaries.
*   **🎙️ Voice Search:** Tap the microphone and search your memories in natural language (including mixed languages like Marathi/Hinglish).
*   **📝 Manual Reminders:** Need to quickly log a thought? Use the text-only reminder sheet—no photo required.
*   **🎨 Dynamic Peach/Terracotta Theme:** A completely custom, warm visual identity using Manrope and Yellowtail typography.
*   **🔒 100% Local Storage:** Your images and database live entirely on your device. Zero cloud storage.

---

## 🏗️ System Architecture & Data Flow

Our architecture is strictly designed around a **"Capture Once, Understand Once, Search Locally"** philosophy. Vision AI is expensive, so we designed a pipeline that uses it only when absolutely necessary.

```mermaid
graph TD
    subgraph Local Device (Offline Storage)
        A[Camera / Gallery] -->|Image Capture| B(Flutter UI - App Shell)
        B -->|Save Raw Image| C[Application Documents Directory]
        D[(SQLite Database)] -->|Provide Context| E[Search Engine / Voice Input]
    end

    subgraph AI Processing Layer (Gemini 3.5 Flash Lite)
        B -->|Image + JSON Schema Prompt| F[Vision Extraction Pipeline]
        F -->|Structured Data: Dates, Summary, Entities| D
        E -->|User Query + Top 30 Metadata| G[Contextual Reasoning Engine]
        G -->|Natural Language Answer & Ranked IDs| E
    end
```

### 🗄️ Storage Mechanisms
1.  **Images (`path_provider`):** Copied securely into the Android internal `ApplicationDocumentsDirectory`. They are never sent to the cloud after the initial extraction.
2.  **Metadata (`sqflite`):** The extracted text, dates, and categories are saved in an optimized local SQLite database (`memory_lens.db`).

---

## 🔬 Deep Dive: AI Token Optimization Strategy

One of the primary goals of MemoryLens was to avoid the massive token costs and latency associated with traditional AI vision apps. 

### The Problem with Naive AI Apps
If a user has 100 saved memories and asks, *"What was that hackathon notice?"*, a poorly designed app will send the query plus 100 images to the vision model. This results in massive latency and burns through API limits instantly.

### Our Solution: The "Capture Once" Pipeline
1.  **Extract & Compress:** When a photo is taken, we send the image to Gemini 3.5 Flash Lite **exactly once** with a `temperature: 0.1` strict JSON prompt.
2.  **Localize:** We extract only the required structured data (Title, Summary, Date, Location) and save it locally.
3.  **Lightweight Search:** When searching, **no images are ever sent to the AI**. We only send the highly-compressed text summaries. This reduces token usage by over 95%.

---

## 🧠 Deep Dive: Search Architecture (Why NOT Semantic Search?)

### The Theoretical Ideal: Hybrid Search
Ideally, an app like this would convert the user's query into an embedding, perform a **Local Vector Semantic Search** (Cosine Similarity) against the database to find the top 3-5 memories, and *only* send those 3-5 to the LLM for a final conversational answer.

### The Prototype Reality: The "Massive Context Window Shortcut"
For this hackathon, we intentionally **bypassed local semantic search** and vector databases for three critical reasons:

1.  **Complex Temporal Reasoning:** Semantic search (vector math) is great for keyword matching (e.g., "competition" = "hackathon"). However, it completely fails at temporal logic. If a user asks, *"What deadlines do I have next week?"*, vector math gets confused. By passing the data to the LLM, the AI can look at today's date, cross-reference the memory dates, and perform human-like reasoning.
2.  **Multi-lingual & Slang Capabilities:** We wanted the app to support local Indian languages and slang (e.g., Hinglish or Marathi voice queries). Standard embedding models struggle to map local slang to English documents accurately. Gemini Flash Lite, however, translates and reasons across mixed languages flawlessly on the fly.
3.  **Token Economics:** Because we are using **Gemini 3.5 Flash Lite**, context windows are massive, lightning-fast, and cost fractions of a penny. Instead of building a heavy local vector database (like `sqlite-vss`), we can simply grab the user's 30 most recent memory summaries and dump them straight into the prompt. The LLM reads the entire catalog instantly and outputs the relevant Memory IDs.

*(Note: We have already written the starter code for Embeddings and Cosine Similarity in our `ai_service.dart`. If this app scales to 5,000+ memories per user, we will activate the Hybrid Search pipeline to prevent overwhelming the context window).*

---

## 🧩 State Management & UI Routing

Building a seamless AI app requires rock-solid UI routing to mask processing times.

*   **Riverpod State Management:** We use `flutter_riverpod` to separate our AI and Database logic from the UI. This ensures that while Gemini is processing an image in the background, the UI remains perfectly responsive.
*   **IndexedStack Navigation:** We built a custom `AppShell` that utilizes an `IndexedStack` for the bottom navigation bar. This ensures that if you are halfway through typing a search query, switch to the Memories tab, and switch back, your state is preserved perfectly.
*   **Custom PopScope Routing:** We intercepted Android's system back-button. If you are deep in a secondary tab, pressing back won't exit the app—it smartly routes you back to the Home tab. If you try to exit from the Home tab, you are greeted with a playful custom exit dialog (*"Escaping reality?"*).

---

## 🧗 Challenges Faced & Overcome

1.  **Handling Broken AI JSON Outputs:** Early on, the AI would occasionally return malformed JSON or wrap it in markdown blockquotes, causing the SQLite parser to crash. **Solution:** We implemented aggressive RegEx cleaning in `_parseExtractionResponse` to strip markdown artifacts and ensure a fallback object is created so the user never loses a capture.
2.  **UI Clipping on Custom Fonts:** When applying our custom `Manrope` font, the search bar text began vertically clipping because of hardcoded container heights. **Solution:** We removed fixed UI constraints and allowed the `TextField` internal padding to dynamically size the container.
3.  **Black Screen Navigation Crashes:** Our custom Bottom Navigation bar was causing Red Screens of Death when integrating the Memories tab. **Solution:** We decoupled the navigation index `_navIndex` from the screen list index `_screenIndex`, allowing us to intercept the "Capture" button to open a Bottom Sheet instead of pushing a route.
