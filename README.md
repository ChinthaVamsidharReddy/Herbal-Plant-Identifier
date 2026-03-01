# 🌿 Herbal Plant Identifier

A cross-platform Flutter application that identifies medicinal plants using a TensorFlow Lite deep learning model.
The app works completely offline and provides multilingual plant information, AI chatbot assistance, and voice interaction.

---

## 🚀 Features

### 🔍 AI-Based Plant Identification

* Capture plant image using camera
* Select image from gallery
* Top-3 predictions with confidence score
* Confidence explanation system
* Offline TensorFlow Lite inference

---

### 🌍 Multi-Language Support (5 Languages)

* English
* Hindi (हिंदी)
* Telugu (తెలుగు)
* Tamil (தமிழ்)
* Kannada (ಕನ್ನಡ)

✔ Plant details dynamically translated
✔ Chatbot responses localized
✔ Section headings translated
✔ Voice assistant language adaptive

---

### 🔊 AI Voice Assistant

* Text-to-Speech integration
* Speaks plant information in selected language
* Adjustable speech rate
* Fully offline
* Supports all 5 languages

---

### 🤖 AI Chatbot Assistant

* Intelligent offline chatbot
* Query plant names conversationally
* Multilingual structured responses
* Similarity-based smart search
* Section-wise formatted answers

---

### ⭐ Favorites System

* Save plants with image and name
* Offline persistent storage (SharedPreferences)
* Favorite toggle with visual indicator
* Quick access favorites list

---

### 📤 Sharing Feature

* Share plant name and description
* Works with WhatsApp, Email, and other apps
* Promotes herbal knowledge awareness

---

### 🎨 UI/UX

* Light and Dark theme support
* Modern card-based layout
* Clean material design
* Cross-platform consistency

---

## 📱 Supported Platforms

* Android (minSdk 26+)
* iOS (12.0+)
* Windows
* macOS
* Linux
* Web (Chrome)

---

## 🧠 Machine Learning Model

* Model: `assets/herbal_model.tflite`
* Framework: TensorFlow Lite
* Input Size: 224x224 normalized images
* Classes: 40 medicinal plants
* Training Epochs: 50
* Validation Accuracy: 92%
* Fully Offline Inference

---

## ⚙️ How It Works

* User captures or selects image
* Image preprocessed to 224x224
* TFLite model predicts class index
* Index maps to plant label
* Plant details retrieved from local multilingual JSON
* User can speak, share, favorite, or query chatbot

---

## 🖥 Emulator / Device Usage

This project can run on:

* **Android Emulator** (Pixel, Nexus, etc.)
* **iOS Simulator** (iPhone, iPad)
* **Desktop** (Windows, macOS, Linux)
* **Web Browsers**

### Recommended Emulator Settings

* Android: API 26+ (camera enabled)
* iOS: iOS 12.0+ (camera enabled)
* Desktop: No special configuration

### Run on Emulator

1. Install Flutter – https://docs.flutter.dev/get-started/install
2. Launch emulator (Android Studio / Xcode)
3. Run:

```bash
flutter run
```

---

## 📁 Project Structure

```
HerbAI/
├── assets/
│   ├── herbal_model.tflite
│   ├── labels.txt
│   └── images/
├── lib/
│   ├── main.dart
│   ├── services/
│   │   ├── tflite_service.dart
│   │   ├── favorites_service.dart
│   │   ├── voice_service.dart
│   │   ├── chatbot_service.dart
│   │   └── language_service.dart
│   ├── ui/
│   │   ├── home_screen.dart
│   │   ├── chatbot_screen.dart
│   │   ├── favorites_screen.dart
│   │   ├── search_screen.dart
│   │   ├── splash_screen.dart
│   │   └── about_screen.dart
│   ├── widgets/
│   │   ├── chat_bubble.dart
│   │   ├── plant_info_card.dart
│   │   └── capture_guidance_dialog.dart
│   └── utils/
│       ├── theme.dart
│       └── prediction_utils.dart
├── test/
├── pubspec.yaml
└── README.md
```

---

## 🧠 Model Details

* **Model:** `assets/herbal_model.tflite`
* **Labels:** `assets/labels.txt` (40 herbal plants)

Workflow:

1. Image selected/captured
2. Preprocessed
3. Model predicts label index
4. Label mapped to plant name
5. App displays information & allows favorites

---

## 📦 Dependencies

* provider (state management)
* image_picker (camera/gallery)
* tflite_flutter (ML inference)
* shared_preferences (storage)
* flutter_tts (voice assistant)
* string_similarity (chatbot matching)
* share_plus (sharing)
* package_info_plus (app version)

---

## ▶️ How to Run

### Install dependencies

```bash
flutter pub get
```

### Run App

Android / iOS

```bash
flutter run
```

Desktop

```bash
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

Web

```bash
flutter run -d chrome
```

---

## 🧪 Testing

```bash
flutter test
```

---

## 📂 Assets

* `assets/herbal_model.tflite` — Pre-trained model (85MB)
* `assets/labels.txt` — 40 plant labels

Example:

```
Aloevera
Amla
Amruta_Balli
...
Wood_sorel
```

---

## 📝 Notes

* App requests camera & storage permissions
* Model can be replaced by updating assets & `pubspec.yaml`
* Best results with clear single-plant images

---

## 👨‍💻 Developers & Collaboration

**CHINTHA VAMSIDHAR REDDY**

---

## 📜 License

This project is for educational and demonstration purposes.
Check dataset and model sources for additional licensing requirements.

---

## 🌱 HerbAI – Bridging AI with Traditional Herbal Knowledge

**Offline • Intelligent • Multilingual • Privacy-Focused**
