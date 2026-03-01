import 'package:flutter_tts/flutter_tts.dart';
class VoiceService {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> _configureVoice(String language) async {
    String locale;

    switch (language) {
      case "hi":
        locale = "hi-IN";
        break;
      case "te":
        locale = "te-IN";
        break;
      case "ta":
        locale = "ta-IN";
        break;
      case "kn":
        locale = "kn-IN";
        break;
      default:
        locale = "en-US";
    }

    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  static String _text(dynamic field, String lang) {
    if (field is Map) {
      return field[lang] ?? field["en"] ?? "";
    }
    return field?.toString() ?? "";
  }
static Future<void> printVoices() async {
  final voices = await _tts.getVoices;
  print(voices);
}

  static Future<void> speak(
    String plantName,
    Map plantInfo,
    String language,
  ) async {
    final info = plantInfo[plantName];
    if (info == null) return;

    await _tts.stop();
    await _configureVoice(language);

    final text =
        "${_text(info['name'], language)}. "
        "Scientific Name: ${_text(info['scientific_name'], language)}. "
        "Description: ${_text(info['description'], language)}. "
        "Uses: ${_text(info['uses'], language)}.";

    await _tts.speak(text);
  }
}