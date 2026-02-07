# 🧙‍♂️ SketchMage: The Living Path

**"Where graphite strokes breathe life and motor skills become magic."**

SketchMage is a cutting-edge **Multimodal AI & Augmented Reality (AR)** experience designed to bridge the gap between physical play and digital learning. Built for the Google Gemini Hackathon, it focuses on developing children's fine motor skills by transforming real-world pencil sketches into interactive digital wonders.

---

## ✨ The Core Innovation: "The Living Path"

Unlike traditional apps that keep children glued to a touchscreen, SketchMage uses **Google Gemini 1.5 Flash** to turn physical paper into an interactive stage. 

### 🔄 The Interaction Loop
1.  **Challenge:** A virtual character (e.g., a lost bird) appears on the device screen, trapped behind a physical gap on the paper.
2.  **Creative Action:** The child uses a real pencil to draw a "bridge," a "shield," or a "path" on a physical sheet of paper.
3.  **AI Vision & Logic:** Gemini analyzes the live camera feed, validating the stroke's precision, connectivity, and shape.
4.  **Magical Transformation:** If the stroke is valid, the app triggers a "Magic Transformation"—playing the object's sound and revealing its realistic 3D-like form.

---

## 🚀 Key Features

### 🎮 Pedagogical Adventure Mode
Five mastery levels designed by experts to cover natural graphomotor progression:
*   **Level 1: Rain of Life (Vertical Strokes):** Eye-hand coordination.
*   **Level 2: Bubble Shield (Circular Strokes):** Shape closure (crucial for letters like 'o', 'a').
*   **Level 3: Cross the Abyss (Horizontal Connection):** Lateral precision.
*   **Level 4: Lightning Mountain (Zig-Zag/Angles):** Sharp direction changes.
*   **Level 5: Acrobatic Flight (Loops):** Fluidity for cursive writing.

### 🤖 Intelligent Multimodal Feedback
*   **Object Identification:** Powered by Gemini, the app identifies what the child drew (e.g., "A happy dog") and displays it as a global state (`objectType`).
*   **Interactive TTS (Text-to-Speech):** The AI acts as a tutor, speaking aloud to celebrate successes or provide encouraging guidance if a stroke needs improvement.
*   **Asset-Based Transformation:** When a drawing is recognized, a **Magic Transform** button appears, linking the sketch to realistic images and sound effects (Spatial Audio) from the local assets.

---

## 🛠️ Technical Stack

*   **Frontend:** Flutter (Dart) for a seamless cross-platform AR experience.
*   **AI Engine:** Google Gemini 1.5 Flash (API) for low-latency multimodal analysis and JSON-structured validation.
*   **Voice Engine:** Flutter TTS for real-time pedagogical feedback.
*   **Audio Engine:** Audioplayers for immersive object-specific sound effects.
*   **Logic:** Provider-based state management for a reactive "Magic Flow".

---

## 📦 Current Implementation Status

1.  **Intelligent Camera System:** High-performance live feed with frame-capture logic.
2.  **Validation Pipeline:** Fully integrated Gemini API that parses sketches into coordinates and pedagogical feedback.
3.  **Magic Transformation Gate:** A specialized results screen that maps detected IDs (e.g., `cat`, `dog`, `bird`) to realistic assets with specific file extensions (`.png`, `.jpg`, `.wav`, `.mp3`).
4.  **Error-Resilient Matching:** Fuzzy-search logic that allows Gemini's descriptive responses to match local assets accurately.

---

## 🏁 Getting Started

### Prerequisites
*   Flutter SDK (3.10.8+)
*   Google Gemini API Key (Set as `--dart-define=GEMINI_API_KEY=your_key`)
*   Device with a working camera (iOS/Android)

### Installation
1.  Clone the repository.
2.  Run `flutter pub get`.
3.  Launch with your API key:
    ```bash
    flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE
    ```

---

*Developed for the Google Gemini 3 DeepMind Hackathon 2026.*
