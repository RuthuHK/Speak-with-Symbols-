# 🗣️ Speak with Symbols

**Speak with Symbols** is an AI-powered Augmentative and Alternative Communication (AAC) application designed to help **non-verbal users communicate more easily and independently**.

Users select pictogram symbols to express their thoughts. The system intelligently suggests relevant next icons and converts the selected icons into **meaningful, grammatically correct sentences**, making communication faster, more natural, and accessible.

## 🎥 Demo

[▶️ Watch the Speak with Symbols Demo](./demo_video.mp4)

## ✨ Features

- 🖼️ **Symbol-Based Communication** – Build messages using pictograms.
- 💡 **Smart Icon Suggestions** – Predicts relevant next icons based on the current selection.
- ✍️ **Automatic Sentence Generation** – Converts icon sequences into grammatically correct sentences.
- 🌐 **Multilingual Support** – Translates generated sentences into multiple languages.
- 🔊 **Text-to-Speech** – Converts sentences into spoken output.
- 📍 **Location-Aware Suggestions** – Recommends context-relevant icons based on the user's surroundings.
- ❤️ **Favorites** – Provides quick access to frequently used symbols.

## 🧠 AI Pipeline

The application uses two fine-tuned **T5 Transformer models**:

1. **Icon Suggestion Model** – Recommends relevant icons based on previously selected icons.
2. **Sentence Generation Model** – Converts the selected icon sequence into a complete sentence.

Sentence embeddings using **Sentence-BERT (all-MiniLM-L6-v2)** are also used for semantic similarity and context-aware icon recommendations.

## 🛠️ Tech Stack

- **Frontend:** Flutter 
- **Backend:** Python / Flask
- **AI/NLP:** T5 Transformers, Sentence-BERT
- **Dataset:** ARASAAC Pictograms
- **Translation:** Google Translate
- **Text-to-Speech:** TTS

## 📊 Dataset

The project uses pictograms from **ARASAAC (Aragonese Portal of Augmentative and Alternative Communication)**.

A selected collection of approximately **850 pictograms** is used by the application along with supporting JSON, JSONL, and CSV files for icon mapping, embeddings, suggestions, and model training.

The pictogram images are **not included in this repository** to avoid uploading hundreds of image files.

Download the required pictograms from:

**[ARASAAC Pictograms](https://arasaac.org/pictograms/search)**

Place the downloaded icons in:

```text
flutter_app/assets/icons/
