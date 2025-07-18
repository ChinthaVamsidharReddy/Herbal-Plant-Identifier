# Herbal Plant Identifier

A cross-platform Flutter application that identifies herbal plants from images using a machine learning model. The app provides plant information, supports favorites, and works on Android, iOS, Windows, macOS, Linux, and Web.

## Features
- Identify herbal plants from photos or gallery images
- View detailed information about each plant
- Save favorite plants for quick access
- Light and dark theme support
- Cross-platform: Android, iOS, Windows, macOS, Linux, Web

## Emulator/Device Usage
This project can be run on:
- **Android Emulator** (e.g., Pixel, Nexus, etc.)
- **iOS Simulator** (e.g., iPhone 14, iPad, etc.)
- **Desktop** (Windows, macOS, Linux)
- **Web Browsers**

### Recommended Emulator Settings
- **Android:** API 26+ (minSdk 26), camera enabled for image capture
- **iOS:** iOS 12.0+, camera enabled
- **Desktop:** No special configuration needed

To run on an emulator:
1. Install Flutter and set up your environment ([Flutter Docs](https://docs.flutter.dev/get-started/install))
2. Launch your emulator (Android Studio/AVD Manager or Xcode for iOS)
3. Run `flutter run` in the project root

## Project Structure & Key Files

```
Herbal Plant Identifier/
├── assets/
│   ├── herbal_model.tflite   # TensorFlow Lite model for plant identification
│   └── labels.txt            # List of plant labels (40 herbal plants)
├── lib/
│   ├── main.dart             # App entry point
│   ├── services/             # Business logic and ML model handling
│   │   ├── tflite_service.dart      # Loads and runs the TFLite model
│   │   ├── favorites_service.dart  # Manages favorite plants
│   │   ├── storage_service.dart    # (Alias for favorites_service.dart)
│   │   └── model_service.dart      # (Alias for tflite_service.dart)
│   ├── ui/                   # User interface screens
│   │   ├── home_screen.dart        # Main plant identification UI
│   │   ├── favorites_screen.dart   # Favorites list UI
│   │   └── splash_screen.dart      # Splash/loading screen
│   ├── widgets/              # Reusable UI components
│   │   └── plant_info_card.dart    # Card displaying plant info
│   └── utils/
│       └── theme.dart              # Theme management (light/dark)
├── test/
│   └── widget_test.dart      # Basic widget test (Flutter default)
├── pubspec.yaml              # Dependencies and asset registration
├── README.md                 # Project documentation
└── ...                       # Platform-specific and config files
```

## Machine Learning Model
- **Model:** `assets/herbal_model.tflite` (TensorFlow Lite)
- **Labels:** `assets/labels.txt` (40 herbal plant names, one per line)
- **How it works:**
  - User selects or captures an image
  - Image is preprocessed and passed to the TFLite model
  - The model predicts the plant class (index matches a label)
  - The app displays plant info and allows saving to favorites

## Dependencies
Key dependencies (see `pubspec.yaml` for all):
- `flutter`
- `image_picker` (for camera/gallery)
- `tflite_flutter` (for running the ML model)
- `shared_preferences` (for storing favorites and theme)
- `provider` (for state management)
- `image` (for image preprocessing)

## How to Run
1. **Install Flutter** ([Flutter Install Guide](https://docs.flutter.dev/get-started/install))
2. **Get dependencies:**
   ```
   flutter pub get
   ```
3. **Run on your platform:**
   - **Android/iOS:**
     ```
     flutter run
     ```
   - **Desktop (Windows/macOS/Linux):**
     ```
     flutter run -d windows   # or macos, linux
     ```
   - **Web:**
     ```
     flutter run -d chrome
     ```

## Testing
- Basic widget test in `test/widget_test.dart`
- To run tests:
  ```
  flutter test
  ```

## Assets
- `assets/herbal_model.tflite`: Pre-trained TFLite model (85MB)
- `assets/labels.txt`: 40 herbal plant labels, e.g.:
  ```
  Aloevera
  Amla
  Amruta_Balli
  ...
  Wood_sorel
  ```

## Notes
- The app requests camera and storage permissions on mobile.
- The model and labels can be updated by replacing the files in `assets/` and updating `pubspec.yaml`.
- For best results, use clear, well-lit images of single plants.

## License
This project is for educational and demonstration purposes. Please check the model and data sources for any additional licensing requirements.
#
