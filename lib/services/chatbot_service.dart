import 'package:string_similarity/string_similarity.dart';

class ChatbotService {
  final Map<String, Map<String, dynamic>> plantInfo;
  final String language;

  final String unknown = "unknown";
  ChatbotService(this.plantInfo, this.language);

  String _buildPlantText(Map<String, String> plant) {
    return "${plant['name']} ${plant['description']} ${plant['uses']} ${plant['more_info']}";
  }

  bool _isUnknownPlant(Map<String, dynamic> plant) {
    final unknownPlant = plantInfo[unknown];
    return identical(plant, unknownPlant);
  }

  String _buildUnknownResponse() {
    final unknown = plantInfo["unknown"];

    if (unknown == null) return _notFoundMessage();

    return _text(unknown['name']) +
        "\n\n${_heading("description")}\n" +
        _text(unknown['description']) +
        "\n\n${_heading("more")}\n" +
        _text(unknown['tips']);
  }

  Map<String, dynamic>? _searchPlant(String query) {
    query = query.toLowerCase().trim();

    Map<String, dynamic>? bestPlant;
    double bestScore = 0;

    for (var entry in plantInfo.entries) {
      final key = entry.key;
      final plant = entry.value;

      // 🔒 SAFE English extraction
      String name = "";
      String description = "";
      String uses = "";
      String scientific = "";

      if (plant['name'] is Map) {
        name = plant['name']['en']?.toString().toLowerCase() ?? "";
      } else {
        name = plant['name']?.toString().toLowerCase() ?? "";
      }

      if (plant['description'] is Map) {
        description =
            plant['description']['en']?.toString().toLowerCase() ?? "";
      } else {
        description = plant['description']?.toString().toLowerCase() ?? "";
      }

      if (plant['uses'] is Map) {
        uses = plant['uses']['en']?.toString().toLowerCase() ?? "";
      } else {
        uses = plant['uses']?.toString().toLowerCase() ?? "";
      }

      if (plant['scientific_name'] is Map) {
        scientific =
            plant['scientific_name']['en']?.toString().toLowerCase() ?? "";
      } else {
        scientific = plant['scientific_name']?.toString().toLowerCase() ?? "";
      }

      // ✅ Direct matches (and BREAK properly)
      if (query.contains(name) ||
          query.contains(scientific) ||
          query.contains(key.toLowerCase())) {
        return plant;
      }

      // ✅ Similarity match
      final combined = "$name $description $uses $scientific";
      final score = StringSimilarity.compareTwoStrings(query, combined);

      if (score > bestScore) {
        bestScore = score;
        bestPlant = plant;
      }
    }

    return bestScore > 0.35 ? bestPlant : null;
  }

  String _buildUnknownChatbotResponse() {
    final unknownPlant = plantInfo["unknown"];
    if (unknownPlant == null) return _notFoundMessage();

    return _text(unknownPlant['chatbot']);
  }

  String _text(dynamic field) {
    if (field is Map) {
      if (field.containsKey(language)) return field[language].toString();
      if (field.containsKey("en")) return field["en"].toString();
      return field.values.first.toString();
    }
    return field?.toString() ?? "";
  }

  String generateResponse(String query) {
    final plant = _searchPlant(query);

    // Case 1: nothing matched strongly
    // if (plant == null) {
    //   return _buildUnknownResponse();
    // }

    // // Case 2: matched but it is UNKNOWN plant
    // if (_isUnknownPlant(plant)) {
    //   return _buildUnknownResponse();
    // }

    if (plant == null) {
      return _buildUnknownChatbotResponse();
    }

    if (_isUnknownPlant(plant)) {
      return _buildUnknownChatbotResponse();
    }

    // Case 3: real plant
    return _text(plant['name']) +
        "\n\n${_heading("scientific")}\n" +
        _text(plant['scientific_name']) +
        "\n\n${_heading("description")}\n" +
        _text(plant['description']) +
        "\n\n${_heading("uses")}\n" +
        _text(plant['uses']) +
        "\n\n${_heading("local")}\n" +
        _text(plant['local_names']) +
        "\n\n${_heading("side")}\n" +
        _text(plant['side_effects']) +
        "\n\n${_heading("more")}\n" +
        _text(plant['more_info']);
  }

  String _notFoundMessage() {
    switch (language) {
      case "hi":
        return "क्षमा करें, हमें आपके द्वारा पूछी गई जानकारी नहीं मिली।";
      case "te":
        return "క్షమించండి, మీరు అడిగిన సమాచారం మాకు అందుబాటులో లేదు.";
      case "ta":
        return "மன்னிக்கவும், நீங்கள் கேட்ட தகவல் எங்களிடம் இல்லை.";
      case "kn":
        return "ಕ್ಷಮಿಸಿ, ನೀವು ಕೇಳಿದ ಮಾಹಿತಿ ಲಭ್ಯವಿಲ್ಲ.";
      default:
        return "Sorry, we could not find the information you requested.";
    }
  }

  String _heading(String type) {
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
}
