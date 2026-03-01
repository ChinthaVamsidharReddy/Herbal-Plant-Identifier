import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantKey;
  final Map<String, Map<String, dynamic>> plantInfo;

  const PlantDetailScreen({
    super.key,
    required this.plantKey,
    required this.plantInfo,
  });
  String _heading(String type, String language) {
    final headings = {
      "scientific": {
        "en": "Scientific Name:",
        "hi": "वैज्ञानिक नाम:",
        "te": "శాస్త్రీయ నామం:",
        "ta": "அறிவியல் பெயர்:",
        "kn": "ವೈಜ್ಞಾನಿಕ ಹೆಸರು:",
      },
      "description": {
        "en": "Description:",
        "hi": "विवरण:",
        "te": "వివరణ:",
        "ta": "விளக்கம்:",
        "kn": "ವಿವರಣೆ:",
      },
      "uses": {
        "en": "Uses & Benefits:",
        "hi": "उपयोग और लाभ:",
        "te": "ఉపయోగాలు మరియు ప్రయోజనాలు:",
        "ta": "பயன்கள்:",
        "kn": "ಉಪಯೋಗಗಳು ಮತ್ತು ಲಾಭಗಳು:",
      },
      "local": {
        "en": "Local Names:",
        "hi": "स्थानीय नाम:",
        "te": "స్థానిక పేర్లు:",
        "ta": "உள்ளூர் பெயர்கள்:",
        "kn": "ಸ್ಥಳೀಯ ಹೆಸರುಗಳು:",
      },
      "side": {
        "en": "Side Effects:",
        "hi": "दुष्प्रभाव:",
        "te": "దుష్ప్రభావాలు:",
        "ta": "பக்க விளைவுகள்:",
        "kn": "ಪಾರ್ಶ್ವ ಪರಿಣಾಮಗಳು:",
      },
      "more": {
        "en": "More Information:",
        "hi": "अधिक जानकारी:",
        "te": "మరింత సమాచారం:",
        "ta": "மேலும் தகவல்:",
        "kn": "ಹೆಚ್ಚಿನ ಮಾಹಿತಿ:",
      },
    };

    return headings[type]?[language] ?? headings[type]?["en"] ?? "";
  }

  String _text(dynamic field, String lang) {
    if (field is Map) {
      return field[lang] ?? field["en"] ?? "";
    }
    return field?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>().currentLanguage;
    final info = plantInfo[plantKey];

    return Scaffold(
      appBar: AppBar(title: Text(_text(info?['name'], lang))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_heading("scientific", lang)} ${_text(info?['scientific_name'], lang)}",
              ),
              const SizedBox(height: 10),
              Text(
                "${_heading("Description", lang)} ${_text(info?['description'], lang)}",
              ),
              const SizedBox(height: 10),
              Text("${_heading("uses", lang)} ${_text(info?['uses'], lang)}"),
              const SizedBox(height: 10),
              Text(
                "${_heading("more", lang)} ${_text(info?['more_info'], lang)}",
              ),
              const SizedBox(height: 10),
              Text(
                "${_heading("local", lang)} ${_text(info?['local_names'], lang)}",
              ),
              const SizedBox(height: 10),
              Text(
                "${_heading("side", lang)} ${_text(info?['side_effects'], lang)}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
