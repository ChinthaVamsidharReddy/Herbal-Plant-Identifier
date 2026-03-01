import 'package:flutter/material.dart';
import 'dart:io';
import 'favorites_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tflite_service.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import 'package:flutter/services.dart';
import 'chatbot_screen.dart';
import '../utils/prediction_utils.dart';
import '../widgets/capture_guidance_dialog.dart';
import 'search_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/voice_service.dart';
import '../services/favorites_service.dart';
import '../services/favorites_service.dart';
import 'package:provider/provider.dart';
import '../ui/about_screen.dart';

import 'package:provider/provider.dart';
import '../services/language_service.dart';

final FlutterTts _tts = FlutterTts();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFavorite = false;
  int _selectedIndex = 0;
  String? _imagePath;
  String? _plantName;
  String? _plantDescription;
  final ImagePicker _picker = ImagePicker();
  bool _isIdentifying = false;
  List<String> _labels = [];
  List<Map<String, dynamic>> _top3 = [];
  double? _confidence;
  static const double _confidenceThreshold = 0.55;

  int _favoriteCount = 0;

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

  // Comprehensive plant information mapping (add more as needed)
  final Map<String, Map<String, dynamic>> _plantInfo = {
    "Aloevera": {
      "name": {
        "en": "Aloe Vera",
        "hi": "एलोवेरा",
        "te": "కలబంద",
        "ta": "கற்றாழை",
        "kn": "ಲೋಳಸಾರ ಗಿಡ",
      },
      "description": {
        "en":
            "Aloe Vera is a succulent plant species widely recognized for its medicinal and cosmetic applications. It has thick, fleshy leaves filled with a gel-like substance that offers several therapeutic benefits.",
        "hi":
            "एलोवेरा एक रसीला पौधा है जो औषधीय और सौंदर्य प्रसाधन उपयोगों के लिए प्रसिद्ध है। इसकी मोटी मांसल पत्तियों में जेल जैसा पदार्थ होता है जो कई चिकित्सीय लाभ देता है।",
        "te":
            "కలబంద ఒక రసభరితమైన మొక్క జాతి, ఇది ఔషధ మరియు సౌందర్య ఉపయోగాలకు విస్తృతంగా ప్రసిద్ధి చెందింది. దీని మందమైన ఆకులలో జెల్ లాంటి పదార్థం ఉండి అనేక ఆరోగ్య ప్రయోజనాలు అందిస్తుంది.",
        "ta":
            "கற்றாழை ஒரு சSucculent வகைத் தாவரம் ஆகும், இது மருத்துவ மற்றும் அழகு பயன்பாடுகளுக்காக பரவலாக அறியப்படுகிறது. இதன் தடித்த இலைகளில் ஜெல் போன்ற பொருள் உள்ளது, அது பல சிகிச்சை நன்மைகள் தருகிறது.",
        "kn":
            "ಲೋಳಸಾರ ಗಿಡವು ಔಷಧೀಯ ಮತ್ತು ಸೌಂದರ್ಯ ಉಪಯೋಗಗಳಿಗೆ ಪ್ರಸಿದ್ಧವಾದ ರಸಗಿಡ ಜಾತಿಯ ಸಸ್ಯವಾಗಿದೆ. ಇದರ ದಪ್ಪ ಎಲೆಗಳಲ್ಲಿ ಜೆಲ್ ಹೋಲುವ ಪದಾರ್ಥವಿದ್ದು ಅನೇಕ ಚಿಕಿತ್ಸಾ ಲಾಭಗಳನ್ನು ನೀಡುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Used to soothe burns and wounds, moisturize skin, and improve digestion. Also used in treating acne and dandruff.",
        "hi":
            "जलन और घाव को शांत करने, त्वचा को मॉइस्चराइज करने और पाचन सुधारने के लिए उपयोग किया जाता है। मुंहासे और डैंड्रफ के उपचार में भी उपयोगी है।",
        "te":
            "కాలిన గాయాలు మరియు గాయాలను ఉపశమనం చేయడానికి, చర్మాన్ని తేమగా ఉంచడానికి మరియు జీర్ణక్రియ మెరుగుపరచడానికి ఉపయోగిస్తారు. మొటిమలు మరియు చుండ్రు చికిత్సలో కూడా ఉపయోగిస్తారు.",
        "ta":
            "தீக்காயங்கள் மற்றும் காயங்களை ஆற்ற, தோலை ஈரப்பதமாக வைத்திருக்க மற்றும் செரிமானத்தை மேம்படுத்த பயன்படுகிறது. முகப்பரு மற்றும் பொடுகு சிகிச்சையிலும் பயன்படுகிறது.",
        "kn":
            "ಬೆಂಕಿ ಗಾಯಗಳು ಮತ್ತು ಗಾಯಗಳನ್ನು ಶಮನಗೊಳಿಸಲು, ಚರ್ಮವನ್ನು ತೇವವಾಗಿರಿಸಲು ಮತ್ತು ಜೀರ್ಣಕ್ರಿಯೆಯನ್ನು ಸುಧಾರಿಸಲು ಬಳಸಲಾಗುತ್ತದೆ. ಮೊಡವೆ ಮತ್ತು ಹೊಟ್ಟು ಚಿಕಿತ್ಸೆಯಲ್ಲಿಯೂ ಉಪಯೋಗಿಸಲಾಗುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Aloe Vera thrives in warm climates and requires minimal care. It is rich in vitamins A, C, E, and B12, enzymes, and amino acids. Its gel is often used in skin care products and health drinks.",
        "hi":
            "एलोवेरा गर्म जलवायु में अच्छी तरह बढ़ता है और कम देखभाल की आवश्यकता होती है। इसमें विटामिन A, C, E और B12, एंजाइम और अमीनो एसिड प्रचुर मात्रा में होते हैं। इसका जेल त्वचा देखभाल उत्पादों और स्वास्थ्य पेय में उपयोग होता है।",
        "te":
            "కలబంద వేడి వాతావరణంలో బాగా పెరుగుతుంది మరియు తక్కువ సంరక్షణ అవసరం. ఇందులో విటమిన్ A, C, E మరియు B12, ఎంజైములు మరియు అమినో ఆమ్లాలు సమృద్ధిగా ఉంటాయి. దీని జెల్ చర్మ సంరక్షణ ఉత్పత్తులు మరియు ఆరోగ్య పానీయాలలో ఉపయోగిస్తారు.",
        "ta":
            "கற்றாழை சூடான காலநிலைகளில் நன்றாக வளரும் மற்றும் குறைந்த பராமரிப்பு போதும். இதில் வைட்டமின் A, C, E மற்றும் B12, என்சைம்கள் மற்றும் அமினோ அமிலங்கள் நிறைந்துள்ளன. இதன் ஜெல் தோல் பராமரிப்பு பொருட்கள் மற்றும் ஆரோக்கிய பானங்களில் பயன்படுத்தப்படுகிறது.",
        "kn":
            "ಲೋಳಸಾರ ಗಿಡವು ಬಿಸಿ ಹವಾಮಾನದಲ್ಲಿ ಚೆನ್ನಾಗಿ ಬೆಳೆಯುತ್ತದೆ ಮತ್ತು ಕಡಿಮೆ ಆರೈಕೆ ಬೇಕಾಗುತ್ತದೆ. ಇದರಲ್ಲಿ ವಿಟಮಿನ್ A, C, E ಮತ್ತು B12, ಎಂಜೈಮ್ ಮತ್ತು ಅಮಿನೋ ಆಮ್ಲಗಳು ಸಮೃದ್ಧವಾಗಿವೆ. ಇದರ ಜೆಲ್ ಚರ್ಮದ ಆರೈಕೆ ಉತ್ಪನ್ನಗಳು ಮತ್ತು ಆರೋಗ್ಯ ಪಾನೀಯಗಳಲ್ಲಿ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Aloe barbadensis Miller",
        "hi": "एलो बारबाडेन्सिस मिलर",
        "te": "అలో బార్బాడెన్సిస్ మిల్లర్",
        "ta": "அலோ பார்படென்சிஸ் மில்லர்",
        "kn": "ಅಲೋ ಬಾರ್ಬಡೆನ್ಸಿಸ್ ಮಿಲ್ಲರ್",
      },
      "local_names": {
        "en":
            "Telugu: Kalabanda, Hindi: Ghritkumari, Tamil: Katrazhai ,Kannada :Lolesara  ",
        "hi":
            "तेलुगु: कलाबंदा, हिंदी: घृतकुमारी, तमिल: कற்றாழை, कन्नडा: लोळेಸರ ",
        "te": "తెలుగు: కలబంద, హిందీ: ఘృతకుమారి, తమిళం: கற்றாழை, ",
        "ta": "தெலுங்கு: கலபந்தா, இந்தி: கிறுதகுமாரி, தமிழ்: கற்றாழை",
        "kn": "ತೆಲುಗು: ಕಲಬಂದ, ಹಿಂದಿ: ಘೃತಕುಮಾರಿ, ತಮಿಳು: கற்றாழை",
      },
      "side_effects": {
        "en":
            "Excess oral intake may cause diarrhea due to anthraquinone laxative compounds, latex portion can trigger abdominal cramps.",
        "hi":
            "अधिक मात्रा में सेवन करने पर एंथ्राक्विनोन रेचक यौगिकों के कारण दस्त हो सकता है और लेटेक्स भाग पेट में ऐंठन पैदा कर सकता है।",
        "te":
            "అధికంగా తీసుకుంటే ఆంథ్రాక్వినోన్ విరేచన సంయోగాల వల్ల విరేచనాలు రావచ్చు, లాటెక్స్ భాగం కడుపు మంటలు కలిగించవచ్చు.",
        "ta":
            "அதிகமாக உட்கொண்டால் ஆன்த்ராக்வினோன் காரணமாக வயிற்றுப்போக்கு ஏற்படலாம், லேடெக்ஸ் பகுதி வயிற்று வலியை ஏற்படுத்தும்.",
        "kn":
            "ಹೆಚ್ಚು ಸೇವಿಸಿದರೆ ಆಂತ್ರಾಕ್ವಿನೋನ್ ಕಾರಣದಿಂದ ಅತಿಸಾರ ಉಂಟಾಗಬಹುದು ಮತ್ತು ಲ್ಯಾಟೆಕ್ಸ್ ಭಾಗವು ಹೊಟ್ಟೆ ನೋವನ್ನು ಉಂಟುಮಾಡಬಹುದು.",
      },
    },
    "Amla": {
      "name": {
        "en": "Amla (Indian Gooseberry)",
        "hi": "आंवला",
        "te": "ఉసిరికాయ",
        "ta": "நெல்லிக்காய்",
        "kn": "ನೆಲ್ಲಿಕಾಯಿ",
      },
      "description": {
        "en":
            "Amla is a nutrient-rich fruit high in Vitamin C and antioxidants, revered in Ayurveda for its rejuvenating properties. It supports overall health and longevity.",
        "hi":
            "आंवला एक पोषक तत्वों से भरपूर फल है जिसमें विटामिन C और एंटीऑक्सीडेंट प्रचुर मात्रा में होते हैं। आयुर्वेद में इसे पुनर्यौवन गुणों के लिए सम्मानित किया जाता है और यह समग्र स्वास्थ्य को समर्थन देता है।",
        "te":
            "ఉసిరికాయలో విటమిన్ C మరియు యాంటీఆక్సిడెంట్లు సమృద్ధిగా ఉంటాయి. ఆయుర్వేదంలో దీన్ని పునరుజ్జీవన లక్షణాల కోసం ఉపయోగిస్తారు మరియు మొత్తం ఆరోగ్యాన్ని మెరుగుపరుస్తుంది.",
        "ta":
            "நெல்லிக்காய் வைட்டமின் C மற்றும் ஆன்டி ஆக்ஸிடென்ட்கள் நிறைந்த பழமாகும். ஆயுர்வேதத்தில் இளம் தோற்றம் தரும் குணங்களுக்கு பயன்படுத்தப்படுகிறது.",
        "kn":
            "ನೆಲ್ಲಿಕಾಯಿ ವಿಟಮಿನ್ C ಮತ್ತು ಆಂಟಿಆಕ್ಸಿಡೆಂಟ್‌ಗಳಿಂದ ಸಮೃದ್ಧವಾದ ಹಣ್ಣು. ಆಯುರ್ವೇದದಲ್ಲಿ ಪುನರುಜ್ಜೀವನ ಗುಣಗಳಿಗಾಗಿ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Improves immunity, aids digestion, enhances hair health, and promotes liver detoxification. Also beneficial for heart health.",
        "hi":
            "प्रतिरक्षा बढ़ाता है, पाचन में मदद करता है, बालों को मजबूत करता है और यकृत शुद्धि में सहायक है। हृदय स्वास्थ्य के लिए भी लाभदायक है।",
        "te":
            "రోగనిరోధక శక్తిని పెంచుతుంది, జీర్ణక్రియను మెరుగుపరుస్తుంది, జుట్టు ఆరోగ్యాన్ని మెరుగుపరుస్తుంది మరియు కాలేయ శుద్ధికి సహాయపడుతుంది.",
        "ta":
            "நோய் எதிர்ப்பு சக்தி அதிகரிக்கிறது, செரிமானம் மேம்படும், முடி ஆரோக்கியம் மேம்படும்.",
        "kn":
            "ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿ ಹೆಚ್ಚಿಸುತ್ತದೆ, ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಿಸುತ್ತದೆ, ಕೂದಲು ಆರೋಗ್ಯಕ್ಕೆ ಒಳ್ಳೆಯದು.",
      },
      "more_info": {
        "en":
            "Amla can be consumed raw, as juice, or in dried form. It is a primary ingredient in Ayurvedic formulations like Triphala and Chyawanprash.",
        "hi":
            "आंवला कच्चा, रस या सूखे रूप में सेवन किया जा सकता है। यह त्रिफला और च्यवनप्राश में मुख्य घटक है।",
        "te":
            "ఉసిరికాయను పచ్చిగా, రసం లేదా ఎండిన రూపంలో తీసుకోవచ్చు. ఇది త్రిఫల మరియు చ్యవన్‌ప్రాష్‌లో ప్రధాన పదార్థం.",
        "ta":
            "நெல்லிக்காய் பச்சையாக, ஜூஸ் அல்லது உலர்ந்த வடிவில் எடுத்துக்கொள்ளலாம்.",
        "kn": "ನೆಲ್ಲಿಕಾಯಿ ಕಚ್ಚಾ, ರಸ ಅಥವಾ ಒಣ ರೂಪದಲ್ಲಿ ಸೇವಿಸಬಹುದು.",
      },
      "scientific_name": {
        "en": "Phyllanthus emblica",
        "hi": "फिलैंथस एम्ब्लिका",
        "te": "ఫిల్లాంతస్ ఎంబ్లికా",
        "ta": "பிலாந்தஸ் எம்ப்ளிக்கா",
        "kn": "ಫಿಲ್ಯಾಂಥಸ್ ಎಂಬ್ಲಿಕಾ",
      },
      "local_names": {
        "en": "Telugu: Usirikaya, Hindi: Amla, Tamil: Nellikai",
        "hi": "तेलुगु: उसिरीकाया, हिंदी: आंवला, तमिल: நெல்லிக்காய்",
        "te": "తెలుగు: ఉసిరికాయ, హిందీ: ఆమ్లా, తమిళం: நெல்லிக்காய்",
        "ta": "தெலுங்கு: உசிரிகாயா, இந்தி: आंवला, தமிழ்: நெல்லிக்காய்",
        "kn": "ತೆಲುಗು: ಉಸಿರಿಕಾಯ, ಹಿಂದಿ: ಆಂಲಾ, ತಮಿಳು: நெல்லிக்காய்",
      },
      "side_effects": {
        "en":
            "High consumption may increase acidity because of high vitamin C and tannin content.",
        "hi": "अधिक सेवन से अम्लता बढ़ सकती है।",
        "te": "అధికంగా తీసుకుంటే ఆమ్లత్వం పెరుగుతుంది.",
        "ta": "அதிகமாக எடுத்தால் அமிலத்தன்மை அதிகரிக்கலாம்.",
        "kn": "ಹೆಚ್ಚು ಸೇವಿಸಿದರೆ ಅಮ್ಲತೆ ಹೆಚ್ಚಾಗಬಹುದು.",
      },
    },

    "Amruta_Balli": {
      "name": {
        "en": "Amruta Balli (Giloy)",
        "hi": "गिलोय (अमृता)",
        "te": "తిప్ప తీగ (అమృతబల్లి)",
        "ta": "சீந்தில் கொடி (அமிர்தவள்ளி)",
        "kn": "ಅಮೃತಬಳ್ಳಿ (ಗಿಲೋಯ್)",
      },
      "description": {
        "en":
            "Amruta Balli, commonly called Giloy, is a climbing medicinal shrub widely used in Ayurveda. The stem contains powerful antioxidants, alkaloids and glycosides that support immunity and reduce chronic inflammation. It is traditionally considered a rejuvenating herb (Rasayana).",
        "hi":
            "गिलोय एक चढ़ने वाली आयुर्वेदिक औषधीय लता है। इसकी डंडी में एंटीऑक्सीडेंट, एल्कलॉइड और ग्लाइकोसाइड होते हैं जो प्रतिरक्षा बढ़ाते हैं और सूजन कम करते हैं। इसे आयुर्वेद में रसायन औषधि माना जाता है।",
        "te":
            "తిప్ప తీగ ఒక ఎక్కే ఆయుర్వేద ఔషధ మొక్క. దీని కాండంలో యాంటీఆక్సిడెంట్లు, ఆల్కలాయిడ్లు మరియు గ్లైకోసైడ్లు ఉండి రోగనిరోధక శక్తిని పెంచి వాపును తగ్గిస్తాయి. ఇది రసాయన ఔషధంగా పరిగణించబడుతుంది.",
        "ta":
            "சீந்தில் கொடி ஒரு ஏறும் மூலிகை. இதன் தண்டு ஆன்டி ஆக்ஸிடென்ட் மற்றும் ஆல்கலாய்டுகள் நிறைந்தது, நோய் எதிர்ப்பு சக்தியை அதிகரித்து அழற்சியை குறைக்கும். ஆயுர்வேதத்தில் இளமையூட்டும் மூலிகை என்று கருதப்படுகிறது.",
        "kn":
            "ಅಮೃತಬಳ್ಳಿ ಒಂದು ಏರುವ ಔಷಧೀಯ ಬೆಳ್ಳಿ. ಇದರ ಕಾಂಡದಲ್ಲಿ ಆಂಟಿಆಕ್ಸಿಡೆಂಟ್ ಹಾಗೂ ಆಲ್ಕಲಾಯ್ಡ್‌ಗಳು ಇರುತ್ತವೆ, ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿ ಹೆಚ್ಚಿಸಿ ಉರಿಯೂತ ಕಡಿಮೆ ಮಾಡುತ್ತದೆ. ಆಯುರ್ವೇದದಲ್ಲಿ ರಸಾಯನ ಸಸ್ಯವೆಂದು ಪರಿಗಣಿಸಲಾಗುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Boosts immunity, reduces fever, controls diabetes, supports liver function, improves digestion, treats respiratory infections and chronic fatigue.",
        "hi":
            "प्रतिरक्षा बढ़ाता है, बुखार कम करता है, मधुमेह नियंत्रित करता है, यकृत की रक्षा करता है और श्वसन संक्रमण में उपयोगी है।",
        "te":
            "రోగనిరోధక శక్తి పెంచుతుంది, జ్వరాన్ని తగ్గిస్తుంది, మధుమేహాన్ని నియంత్రిస్తుంది, కాలేయాన్ని రక్షిస్తుంది మరియు శ్వాసకోశ ఇన్ఫెక్షన్లలో ఉపయోగిస్తారు.",
        "ta":
            "நோய் எதிர்ப்பு சக்தி அதிகரிக்கும், காய்ச்சல் குறைக்கும், நீரிழிவு கட்டுப்படுத்தும் மற்றும் சுவாச நோய்களில் பயன்படும்.",
        "kn":
            "ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿ ಹೆಚ್ಚಿಸುತ್ತದೆ, ಜ್ವರ ಕಡಿಮೆ ಮಾಡುತ್ತದೆ, ಮಧುಮೇಹ ನಿಯಂತ್ರಿಸುತ್ತದೆ ಮತ್ತು ಉಸಿರಾಟ ಸೋಂಕುಗಳಲ್ಲಿ ಉಪಯೋಗ.",
      },
      "more_info": {
        "en":
            "Often consumed as stem decoction or juice. Used in Ayurvedic formulations for dengue recovery and post-illness weakness. Considered safe in moderate doses but should be taken under guidance for long-term use.",
        "hi":
            "काढ़ा या रस के रूप में सेवन किया जाता है। डेंगू के बाद कमजोरी में उपयोगी माना जाता है और लंबे समय तक लेने से पहले विशेषज्ञ की सलाह आवश्यक है।",
        "te":
            "కషాయం లేదా రసం రూపంలో తీసుకుంటారు. డెంగ్యూ తరువాత బలహీనతలో ఉపయోగపడుతుంది, దీర్ఘకాల వినియోగం ముందు వైద్య సలహా అవసరం.",
        "ta":
            "கஷாயம் அல்லது சாறு வடிவில் குடிக்கப்படுகிறது. டெங்கு பிந்தைய பலவீனத்தில் பயன்படுத்தப்படுகிறது, நீண்டகாலம் மருத்துவர் ஆலோசனை அவசியம்.",
        "kn":
            "ಕಷಾಯ ಅಥವಾ ರಸದ ರೂಪದಲ್ಲಿ ಸೇವನೆ. ಡೆಂಗ್ಯೂ ನಂತರದ ದುರ್ಬಲತೆಯಲ್ಲಿ ಉಪಯೋಗ, ದೀರ್ಘಕಾಲ ವೈದ್ಯ ಸಲಹೆ ಅಗತ್ಯ.",
      },
      "scientific_name": {
        "en": "Tinospora cordifolia",
        "hi": "टिनोस्पोरा कॉर्डिफोलिया",
        "te": "టినోస్పోరా కార్డిఫోలియా",
        "ta": "டினோஸ்போரா கார்டிபோலியா",
        "kn": "ಟಿನೋಸ್ಪೋರಾ ಕಾರ್ಡಿಫೋಲಿಯಾ",
      },
      "local_names": {
        "en":
            "Telugu: Tippa Teega, Hindi: Giloy, Tamil: Seenthil kodi, Kannada: Amruthaballi",
        "hi": "तेलुगु: तिप्पा तीगा, तमिल: சீந்தில் கொடி, कन्नड़: ಅಮೃತಬಳ್ಳಿ",
        "te": "తెలుగు: తిప్ప తీగ, హిందీ: గిలోయ్, తమిళం: சீந்தில் கொடி",
        "ta": "தமிழ்: சீந்தில் கொடி, தெலுங்கு: తిప్ప తీగ, இந்தி: गिलोय",
        "kn": "ಕನ್ನಡ: ಅಮೃತಬಳ್ಳಿ, ತೆಲುಗು: తిప్ప తీగ, ಹಿಂದಿ: गिलोय",
      },
      "side_effects": {
        "en":
            "Excess use may overstimulate immunity, cause constipation or lower blood sugar excessively. Not recommended for autoimmune patients without medical supervision.",
        "hi":
            "अधिक सेवन से प्रतिरक्षा अति सक्रिय हो सकती है, कब्ज या शुगर कम हो सकती है। ऑटोइम्यून रोगियों में सावधानी।",
        "te":
            "అధిక వినియోగం రోగనిరోధక ప్రతిస్పందన పెంచి మలబద్ధకం లేదా షుగర్ తగ్గించవచ్చు. ఆటోఇమ్యూన్ రోగులకు జాగ్రత్త.",
        "ta":
            "அதிகம் எடுத்தால் நோய் எதிர்ப்பு அதிகரித்து மலச்சிக்கல் அல்லது சர்க்கரை குறையலாம். ஆட்டோஇம்யூன் நோயாளிகள் கவனம்.",
        "kn":
            "ಹೆಚ್ಚು ಸೇವನೆ ಇಮ್ಯೂನ್ ಪ್ರತಿಕ್ರಿಯೆ ಹೆಚ್ಚಿಸಿ ಮಲಬದ್ದತೆ ಅಥವಾ ಶುಗರ್ ಕಡಿಮೆ ಮಾಡಬಹುದು. ಆಟೋಇಮ್ಯೂನ್ ರೋಗಿಗಳಿಗೆ ಜಾಗ್ರತೆ.",
      },
    },

    "Arali": {
      "name": {
        "en": "Arali (Oleander)",
        "hi": "कनेर",
        "te": "గన్నేరు",
        "ta": "அரளி",
        "kn": "ಕಣೇರು",
      },
      "description": {
        "en":
            "Arali (Oleander) is an ornamental evergreen shrub commonly grown in tropical regions. Despite its attractive flowers, all parts of the plant including leaves, flowers and sap contain potent cardiac glycosides and are highly poisonous. In traditional medicine it is used only in carefully processed external preparations.",
        "hi":
            "कनेर एक सजावटी सदाबहार झाड़ी है। इसके पत्ते, फूल और दूधिया रस में शक्तिशाली कार्डियक ग्लाइकोसाइड होते हैं और यह अत्यधिक विषैला होता है। आयुर्वेद में केवल शुद्धिकरण के बाद बाहरी उपयोग में लिया जाता है।",
        "te":
            "గన్నేరు ఒక అలంకార ఎప్పుడూ పచ్చగా ఉండే పొద. ఆకులు, పువ్వులు మరియు పాలు లాంటి రసం విషపూరిత కార్డియాక్ గ్లైకోసైడ్లు కలిగి ఉంటాయి. శుద్ధి చేసిన తర్వాత మాత్రమే బయటి ఆయుర్వేద చికిత్సల్లో ఉపయోగిస్తారు.",
        "ta":
            "அரளி ஒரு அலங்கார எப்போதும் பசுமையான செடி. இலை, பூ மற்றும் பால் போன்ற சாறு அனைத்தும் நச்சு கார்டியாக் குளைகோசைட்கள் கொண்டது. சுத்திகரித்த பின் வெளிப்புற பயன்பாட்டில் மட்டுமே பயன்படுத்தப்படுகிறது.",
        "kn":
            "ಕಣೇರು ಒಂದು ಅಲಂಕಾರಿಕ ಸದಾ ಹಸಿರು ಗಿಡ. ಎಲೆ, ಹೂ ಮತ್ತು ರಸದಲ್ಲಿ ವಿಷಕಾರಿ ಕಾರ್ಡಿಯಾಕ್ ಗ್ಲೈಕೋಸೈಡ್‌ಗಳು ಇವೆ. ಶೋಧಿಸಿದ ನಂತರ ಮಾತ್ರ ಬಾಹ್ಯ ಆಯುರ್ವೇದ ಬಳಕೆ.",
      },
      "uses": {
        "en":
            "Traditionally used externally for certain skin diseases, parasites and joint pain after purification. Never used internally in home remedies.",
        "hi":
            "शुद्धिकरण के बाद त्वचा रोग, कीड़े और जोड़ों के दर्द में बाहरी उपयोग। घरेलू सेवन वर्जित।",
        "te":
            "శుద్ధి చేసిన తర్వాత చర్మవ్యాధులు, పురుగులు మరియు సంధివాత నొప్పుల్లో బయటి ఉపయోగం. లోపల తీసుకోవడం నిషేధం.",
        "ta":
            "சுத்திகரித்த பின் தோல் நோய் மற்றும் மூட்டு வலியில் வெளிப்புற பயன்பாடு. உட்கொள்ளக் கூடாது.",
        "kn":
            "ಶೋಧಿಸಿದ ನಂತರ ಚರ್ಮರೋಗ ಮತ್ತು ಸಂಧಿವಾತದಲ್ಲಿ ಬಾಹ್ಯ ಬಳಕೆ. ಒಳಗೆ ಸೇವನೆ ಮಾಡಬಾರದು.",
      },
      "more_info": {
        "en":
            "Even small ingestion can be life-threatening. Smoke from burning wood is also toxic. Children and pets are at high risk of accidental poisoning.",
        "hi":
            "थोड़ी मात्रा भी जानलेवा हो सकती है। लकड़ी का धुआँ भी विषैला है। बच्चों और पशुओं के लिए खतरनाक।",
        "te":
            "చిన్న మోతాదు కూడా ప్రాణాపాయం. దహనం చేసినప్పుడు వచ్చే పొగ కూడా విషపూరితం. పిల్లలు మరియు జంతువులకు ప్రమాదం.",
        "ta":
            "சிறிய அளவும் உயிருக்கு ஆபத்து. எரியும் புகையும் நச்சு. குழந்தைகள் மற்றும் செல்லப்பிராணிகளுக்கு ஆபத்து.",
        "kn":
            "ಸ್ವಲ್ಪ ಪ್ರಮಾಣವೂ ಪ್ರಾಣಾಪಾಯ. ಹೊಗೆಯೂ ವಿಷಕಾರಿ. ಮಕ್ಕಳಿಗೂ ಪ್ರಾಣಿಗಳಿಗೂ ಅಪಾಯ.",
      },
      "scientific_name": {
        "en": "Nerium oleander",
        "hi": "नेरियम ओलियेंडर",
        "te": "నీరియం ఓలియాండర్",
        "ta": "நேரியம் ஒலியாண்டர்",
        "kn": "ನೇರಿಯಮ್ ಓಲಿಯಾಂಡರ್",
      },
      "local_names": {
        "en": "Telugu: Ganneru, Hindi: Kaner, Tamil: Arali, Kannada: Kaneru",
        "hi": "तेलुगु: गन्नेरु, हिंदी: कनेर, तमिल: अरली, कन्नड़: कनेरु",

        "te": "తెలుగు: గన్నేరు, హిందీ: కనేర, తమిళం: அரளி, కన్నడ: ಕಣೇರು",

        "ta": "தெலுங்கு: கன்னேறு, இந்தி: கனேர், தமிழ்: அரளி, கன்னட: ಕಣೇರು",

        "kn": "ತೆಲುಗು: ಗನ್ನೇರು, ಹಿಂದಿ: ಕನೇರ, ತಮಿಳು: அரளி, ಕನ್ನಡ: ಕಣೇರು",
      },
      "side_effects": {
        "en":
            "Causes vomiting, dizziness, irregular heartbeat, low blood pressure and can lead to fatal cardiac arrest if ingested.",
        "hi": "उल्टी, चक्कर, अनियमित धड़कन और हृदयाघात का खतरा।",
        "te":
            "వాంతులు, తలనిర్మలం, అసమాన గుండె చప్పుళ్లు మరియు హార్ట్ అటాక్ ప్రమాదం.",
        "ta": "வாந்தி, மயக்கம், இதய துடிப்பு கோளாறு மற்றும் இதயநிலை பாதிப்பு.",
        "kn": "ವಾಂತಿ, ತಲೆ ಸುತ್ತು, ಅಸಮಾನ ಹೃದಯ ಬಡಿತ ಮತ್ತು ಹೃದಯಾಘಾತ ಅಪಾಯ.",
      },
    },

    "Ashoka": {
      "name": {
        "en": "Ashoka Tree",
        "hi": "अशोक वृक्ष",
        "te": "అశోక వృక్షం",
        "ta": "அசோக மரம்",
        "kn": "ಅಶೋಕ ಮರ",
      },
      "description": {
        "en":
            "Ashoka (Saraca asoca) is a sacred evergreen tree native to the Indian subcontinent. The bark is highly valued in Ayurveda for its uterine tonic, anti-inflammatory and antioxidant properties. It is traditionally associated with women's reproductive health and is considered a rejuvenating herb in classical Ayurvedic texts.",
        "hi":
            "अशोक भारतीय उपमहाद्वीप का पवित्र सदाबहार वृक्ष है। इसकी छाल आयुर्वेद में गर्भाशय टॉनिक, सूजनरोधी और एंटीऑक्सीडेंट गुणों के कारण प्रसिद्ध है और महिलाओं के प्रजनन स्वास्थ्य के लिए विशेष रूप से उपयोगी मानी जाती है।",
        "te":
            "అశోకము భారత ఉపఖండానికి చెందిన పవిత్ర ఎప్పుడూ పచ్చగా ఉండే చెట్టు. దీని చెక్క ఆయుర్వేదంలో గర్భాశయ టానిక్, యాంటీఇన్‌ఫ్లమేటరీ మరియు యాంటీఆక్సిడెంట్ లక్షణాల వల్ల ప్రసిద్ధి చెందింది.",
        "ta":
            "அசோக மரம் இந்தியாவைச் சேர்ந்த புனித எப்போதும் பசுமையான மரம். இதன் பட்டை கருப்பை ஆரோக்கியத்திற்கு பயன்படும் மருத்துவ குணங்கள் கொண்டது.",
        "kn":
            "ಅಶೋಕ ಭಾರತಕ್ಕೆ ಸೇರಿದ ಪವಿತ್ರ ಸದಾ ಹಸಿರು ಮರ. ಇದರ ಸಿಪ್ಪೆ ಗರ್ಭಾಶಯ ಆರೋಗ್ಯಕ್ಕೆ ಉಪಯುಕ್ತ ಔಷಧೀಯ ಗುಣಗಳನ್ನು ಹೊಂದಿದೆ.",
      },
      "uses": {
        "en":
            "Used to regulate menstrual cycle, reduce excessive bleeding, relieve menstrual pain, support fertility, and improve hormonal balance. Also used for skin disorders and internal inflammation.",
        "hi":
            "मासिक धर्म नियमित करता है, अत्यधिक रक्तस्राव कम करता है, दर्द घटाता है, हार्मोन संतुलित करता है और त्वचा रोगों में उपयोगी है।",
        "te":
            "మాసిక ధర్మం సక్రమం చేస్తుంది, అధిక రక్తస్రావం తగ్గిస్తుంది, నొప్పి తగ్గిస్తుంది మరియు హార్మోన్ల సమతుల్యతకు సహాయపడుతుంది.",
        "ta":
            "மாதவிடாய் ஒழுங்குபடுத்தும், அதிக இரத்தப்போக்கு குறைக்கும், வலி குறைக்கும் மற்றும் ஹார்மோன் சமநிலையை மேம்படுத்தும்.",
        "kn":
            "ಮಾಸಿಕ ಚಕ್ರ ನಿಯಂತ್ರಿಸುತ್ತದೆ, ರಕ್ತಸ್ರಾವ ಕಡಿಮೆ ಮಾಡುತ್ತದೆ, ನೋವು ತಗ್ಗಿಸುತ್ತದೆ ಮತ್ತು ಹಾರ್ಮೋನ್ ಸಮತೋಲನಕ್ಕೆ ಸಹಾಯಕ.",
      },
      "more_info": {
        "en":
            "The bark decoction is a key ingredient in famous Ayurvedic formulations like Ashokarishta. The flowers are also used in cooling remedies and traditional rituals. The tree is culturally sacred and often planted near temples.",
        "hi":
            "इसकी छाल का काढ़ा अशोकअरिष्ट जैसे आयुर्वेदिक औषधि में मुख्य घटक है। फूल भी शीतल औषधि और धार्मिक उपयोग में आते हैं।",
        "te":
            "దీని చెక్క కషాయం అశోకారిష్ట వంటి ఆయుర్వేద ఔషధాలలో ప్రధాన భాగం. పూలను శీతల ఔషధాలలో ఉపయోగిస్తారు.",
        "ta":
            "அசோகாரிஷ்டம் போன்ற மருந்துகளில் பட்டை முக்கிய բաղமாகும். பூக்கள் குளிர்ச்சி மருந்தாகவும் பயன்படும்.",
        "kn":
            "ಅಶೋಕಾರಿಷ್ಟ ಔಷಧಿಯಲ್ಲಿ ಸಿಪ್ಪೆ ಮುಖ್ಯ ಅಂಶ. ಹೂವುಗಳು ಶೀತಲ ಔಷಧಿಯಾಗಿ ಬಳಕೆ.",
      },
      "scientific_name": {
        "en": "Saraca asoca",
        "hi": "सराका अशोका",
        "te": "సరాకా అసోకా",
        "ta": "சராகா அசோகா",
        "kn": "ಸರಾಕಾ ಅಶೋಕಾ",
      },
      "local_names": {
        "en": "Hindi: Ashok, Telugu: Ashokam, Tamil: Asogam, Kannada: Ashoka",

        "hi": "तेलुगु: अशोकम, हिंदी: अशोक, तमिल: அசோகம், कन्नड़: ಅಶೋಕ",

        "te": "తెలుగు: అశోకం, హిందీ: अशोक, తమిళం: அசோகம், కన్నడ: ಅಶೋಕ",

        "ta": "தெலுங்கு: அசோகம், இந்தி: अशोक, தமிழ்: அசோகம், கன்னட: ಅಶೋಕ",

        "kn": "ತೆಲುಗು: ಅಶೋಕಂ, ಹಿಂದಿ: अशोक, ತಮಿಳು: அசோகம், ಕನ್ನಡ: ಅಶೋಕ",
      },
      "side_effects": {
        "en":
            "Excess consumption may cause constipation or stomach upset due to high tannin content. Should be used under guidance during pregnancy.",
        "hi":
            "अधिक सेवन से कब्ज या पेट दर्द हो सकता है, गर्भावस्था में सावधानी।",
        "te":
            "అధిక వినియోగం మలబద్ధకం లేదా కడుపు నొప్పి కలిగించవచ్చు, గర్భధారణలో జాగ్రత్త.",
        "ta":
            "அதிகம் எடுத்தால் மலச்சிக்கல் அல்லது வயிற்று வலி ஏற்படும், கர்ப்பத்தில் கவனம்.",
        "kn":
            "ಹೆಚ್ಚು ಸೇವನೆ ಮಲಬದ್ದತೆ ಅಥವಾ ಹೊಟ್ಟೆ ನೋವು ಉಂಟುಮಾಡಬಹುದು, ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ಜಾಗ್ರತೆ.",
      },
    },
    "Ashwagandha": {
      "name": {
        "en": "Ashwagandha (Indian Ginseng)",
        "hi": "अश्वगंधा (भारतीय जिनसेंग)",
        "te": "అశ్వగంధ (ఇండియన్ జిన్సెంగ్)",
        "ta": "அமுக்கரா (இந்திய ஜின்செங்)",
        "kn": "ಅಶ್ವಗಂಧ (ಭಾರತೀಯ ಜಿನ್ಸೆಂಗ್)",
      },
      "description": {
        "en":
            "Ashwagandha (Withania somnifera) is one of the most important Rasayana herbs in Ayurveda. The roots contain withanolides that help the body adapt to physical and mental stress, support nervous system health and improve vitality. It is traditionally used as a rejuvenating tonic for strength, longevity and recovery from illness.",
        "hi":
            "अश्वगंधा आयुर्वेद की प्रमुख रसायन औषधि है। इसकी जड़ में विथेनोलाइड्स होते हैं जो शरीर को तनाव के अनुकूल बनाते हैं, तंत्रिका तंत्र को मजबूत करते हैं और ऊर्जा बढ़ाते हैं।",
        "te":
            "అశ్వగంధ ఆయుర్వేదంలో ప్రముఖ రసాయన ఔషధం. దీని వేరులో ఉండే విథనోలైడ్లు శారీరక మరియు మానసిక ఒత్తిడిని తగ్గించి నాడీ వ్యవస్థను బలపరుస్తాయి.",
        "ta":
            "அமுக்கரா ஆயுர்வேதத்தின் முக்கிய ரசாயன மூலிகை. இதன் வேர் உடல் மற்றும் மன அழுத்தத்தை குறைத்து நரம்பு மண்டலத்தை பலப்படுத்துகிறது.",
        "kn":
            "ಅಶ್ವಗಂಧ ಆಯುರ್ವೇದದ ಪ್ರಮುಖ ರಸಾಯನ ಸಸ್ಯ. ಇದರ ಬೇರು ಒತ್ತಡ ಕಡಿಮೆ ಮಾಡಿ ನರಮಂಡಲ ಬಲಪಡಿಸುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Improves stamina, boosts immunity, enhances memory, reduces anxiety, supports sleep, improves muscle strength and supports male and female reproductive health.",
        "hi":
            "शक्ति बढ़ाता है, प्रतिरक्षा मजबूत करता है, स्मरण शक्ति बढ़ाता है, चिंता कम करता है और नींद सुधारता है।",
        "te":
            "శక్తి పెంచుతుంది, రోగనిరోధక శక్తి మెరుగుపరుస్తుంది, జ్ఞాపకశక్తి పెంచుతుంది, ఆందోళన తగ్గిస్తుంది మరియు నిద్ర మెరుగుపరుస్తుంది.",
        "ta":
            "உடல் சக்தி அதிகரிக்கும், நினைவாற்றல் மேம்படும், மனஅழுத்தம் குறையும் மற்றும் நல்ல தூக்கம் கிடைக்கும்.",
        "kn":
            "ಶಕ್ತಿ ಹೆಚ್ಚಿಸುತ್ತದೆ, ಸ್ಮರಣೆ ಸುಧಾರಿಸುತ್ತದೆ, ಆತಂಕ ಕಡಿಮೆ ಮಾಡುತ್ತದೆ ಮತ್ತು ನಿದ್ರೆ ಸುಧಾರಿಸುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Commonly consumed as root powder with milk or in herbal formulations like churnas and capsules. Often recommended for students, athletes and people recovering from chronic illness due to its adaptogenic and anabolic properties.",
        "hi":
            "दूध के साथ चूर्ण के रूप में लिया जाता है। विद्यार्थियों और कमजोरी वाले लोगों के लिए उपयोगी माना जाता है।",
        "te":
            "పొడి రూపంలో పాలతో తీసుకుంటారు. విద్యార్థులు మరియు బలహీనత ఉన్నవారికి ఉపయోగకరం.",
        "ta":
            "பொடி வடிவில் பாலும் சேர்த்து உட்கொள்கின்றனர். மாணவர்கள் மற்றும் பலவீனமானவர்களுக்கு பயன்படும்.",
        "kn":
            "ಹಾಲಿನೊಂದಿಗೆ ಪುಡಿ ರೂಪದಲ್ಲಿ ಸೇವನೆ. ವಿದ್ಯಾರ್ಥಿಗಳು ಮತ್ತು ದುರ್ಬಲರಿಗೆ ಉಪಯುಕ್ತ.",
      },
      "scientific_name": {
        "en": "Withania somnifera",
        "hi": "विथानिया सोम्निफेरा",
        "te": "వితానియా సోమ్నిఫెరా",
        "ta": "விதானியா சோம்னிபெரா",
        "kn": "ವಿಥಾನಿಯಾ ಸೋಮ್ನಿಫೆರಾ",
      },
      "local_names": {
        "en":
            "Telugu: Penneru, Hindi: Ashwagandha, Tamil: Amukkara, Kannada: Ashwagandha",

        "te":
            "తెలుగు: పెన్నేరు, హిందీ: अश्वगंधा, తమిళం: அமுக்கரா, కన్నಡ: ಅಶ್ವಗಂಧ",

        "ta":
            "தெலுங்கு: பென்னேறு, இந்தி: अश्वगंधा, தமிழ்: அமுக்கரா, கன்னட: ಅಶ್ವಗಂಧ",

        "kn":
            "ತೆಲುಗು: ಪೆನ್ನೇರು, ಹಿಂದಿ: अश्वगंधा, ತಮಿಳು: அமுக்கரா, ಕನ್ನಡ: ಅಶ್ವಗಂಧ",
      },
      "side_effects": {
        "en":
            "High doses may cause drowsiness, stomach upset or increased thyroid activity. Avoid during pregnancy and use cautiously with sedatives or thyroid medications.",
        "hi":
            "अधिक मात्रा से नींद, पेट खराब या थायरॉयड प्रभाव हो सकता है। गर्भावस्था में सावधानी।",
        "te":
            "అధిక మోతాదు నిద్రమత్తు, కడుపు సమస్యలు లేదా థైరాయిడ్ ప్రభావం కలిగించవచ్చు. గర్భధారణలో జాగ్రత్త.",
        "ta":
            "அதிகம் எடுத்தால் தூக்கம் அல்லது வயிற்று கோளாறு ஏற்படும். கர்ப்பத்தில் கவனம்.",
        "kn":
            "ಹೆಚ್ಚು ಪ್ರಮಾಣ ನಿದ್ರೆ ಅಥವಾ ಹೊಟ್ಟೆ ತೊಂದರೆ ಉಂಟುಮಾಡಬಹುದು. ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ಜಾಗ್ರತೆ.",
      },
    },

    "Avacado": {
      "name": {
        "en": "Avocado (Butter Fruit)",
        "hi": "मक्खन फल (एवोकाडो)",
        "te": "వెన్నపండు (అవకాడో)",
        "ta": "வெண்ணெய் பழம் (அவகாடோ)",
        "kn": "ಬೆಣ್ಣೆ ಹಣ್ಣು (ಅವಕಾಡೋ)",
      },
      "description": {
        "en":
            "Avocado (Persea americana) is a creamy nutrient-dense tropical fruit rich in monounsaturated fats, fiber, potassium and vitamins E, K, C and B-complex. It is considered a heart-protective functional food and helps reduce inflammation and oxidative stress in the body.",
        "hi":
            "एवोकाडो एक पोषक तत्वों से भरपूर फल है जिसमें मोनोअनसैचुरेटेड वसा, फाइबर, पोटैशियम और विटामिन E, K, C तथा B-समूह होते हैं। यह हृदय की रक्षा करने वाला और सूजन कम करने वाला फल माना जाता है।",
        "te":
            "అవకాడో పోషకాలతో నిండిన పండు. ఇందులో ఆరోగ్యకరమైన కొవ్వులు, ఫైబర్, పొటాషియం మరియు విటమిన్లు E, K, C, B సమూహం ఉంటాయి. ఇది గుండె ఆరోగ్యాన్ని కాపాడి వాపును తగ్గిస్తుంది.",
        "ta":
            "அவகாடோ ஊட்டச்சத்து நிறைந்த பழம். இதில் நல்ல கொழுப்பு, நார்ச்சத்து, பொட்டாசியம் மற்றும் பல வைட்டமின்கள் உள்ளன; இதயம் பாதுகாக்க உதவுகிறது.",
        "kn":
            "ಅವಕಾಡೋ ಪೌಷ್ಟಿಕ ಹಣ್ಣು. ಆರೋಗ್ಯಕರ ಕೊಬ್ಬು, ನಾರು, ಪೊಟ್ಯಾಸಿಯಂ ಮತ್ತು ವಿಟಮಿನ್‌ಗಳು ಹೊಂದಿದ್ದು ಹೃದಯ ರಕ್ಷಣೆಗೆ ಸಹಾಯಕ.",
      },
      "uses": {
        "en":
            "Supports heart health, lowers bad cholesterol, improves skin hydration, enhances brain function, aids digestion and helps in weight management when consumed moderately.",
        "hi":
            "हृदय स्वास्थ्य सुधारता है, खराब कोलेस्ट्रॉल घटाता है, त्वचा को पोषण देता है और पाचन में सहायक है।",
        "te":
            "గుండె ఆరోగ్యాన్ని మెరుగుపరుస్తుంది, చెడు కొలెస్ట్రాల్ తగ్గిస్తుంది, చర్మాన్ని పోషిస్తుంది మరియు జీర్ణక్రియకు సహాయపడుతుంది.",
        "ta":
            "இதய ஆரோக்கியம் மேம்படும், தோல் பளபளப்பு அதிகரிக்கும், செரிமானம் மேம்படும்.",
        "kn":
            "ಹೃದಯ ಆರೋಗ್ಯ ಸುಧಾರಿಸುತ್ತದೆ, ಚರ್ಮ ಪೋಷಿಸುತ್ತದೆ ಮತ್ತು ಜೀರ್ಣಕ್ರಿಯೆಗೆ ಸಹಾಯಕ.",
      },
      "more_info": {
        "en":
            "Often eaten raw, mashed, or blended in smoothies and spreads. The oil extracted from avocado is widely used in cosmetic and hair care products due to its moisturizing and antioxidant properties.",
        "hi":
            "कच्चा, सलाद, स्मूदी और स्प्रेड में खाया जाता है। इसका तेल सौंदर्य और बालों की देखभाल में उपयोग होता है।",
        "te":
            "పచ్చిగా, సలాడ్, స్మూతీ లేదా పేస్ట్‌గా తింటారు. దీని నూనె సౌందర్య మరియు జుట్టు సంరక్షణలో ఉపయోగిస్తారు.",
        "ta":
            "சாலட், ஸ்மூதி மற்றும் பேஸ்ட் வடிவில் உண்ணப்படுகிறது. இதன் எண்ணெய் அழகு பராமரிப்பில் பயன்படும்.",
        "kn":
            "ಸಲಾಡ್, ಸ್ಮೂದಿ ರೂಪದಲ್ಲಿ ಸೇವನೆ. ಇದರ ಎಣ್ಣೆ ಸೌಂದರ್ಯ ಹಾಗೂ ಕೂದಲು ಆರೈಕೆಯಲ್ಲಿ ಬಳಕೆ.",
      },
      "scientific_name": {
        "en": "Persea americana",
        "hi": "पर्सिया अमेरिकाना",
        "te": "పెర్సియా అమెరికానా",
        "ta": "பெர்சியா அமெரிக்கானா",
        "kn": "ಪರ್ಸಿಯಾ ಅಮೆರಿಕಾನಾ",
      },
      "local_names": {
        "en":
            "Telugu: Vennapandu, Hindi: Makhanphal, Tamil: Butter fruit, Kannada: Benne hannu",
        "hi":
            "तेलुगु: वेन्नापंडु, हिंदी: मक्खन फल, तमिल: வெண்ணெய் பழம், कन्नड़: ಬೆಣ್ಣೆ ಹಣ್ಣು",

        "te":
            "తెలుగు: వెన్నపండు, హిందీ: मक्खन फल, తమిళం: வெண்ணெய் பழம், కన్నಡ: ಬೆಣ್ಣೆ ಹಣ್ಣು",

        "ta":
            "தெலுங்கு: வென்னபண்டு, இந்தி: मक्खन फल, தமிழ்: வெண்ணெய் பழம், கன்னಡ: ಬೆಣ್ಣೆ ಹಣ್ಣು",

        "kn":
            "ತೆಲುಗು: ವೆನ್ನಪಂಡು, ಹಿಂದಿ: मक्खन फल, ತಮಿಳು: வெண்ணெய் பழம், ಕನ್ನಡ: ಬೆಣ್ಣೆ ಹಣ್ಣು",
      },
      "side_effects": {
        "en":
            "Excess consumption may cause weight gain and digestive discomfort. People allergic to latex may experience allergic reactions due to latex-fruit syndrome.",
        "hi":
            "अधिक सेवन से वजन बढ़ सकता है और लेटेक्स एलर्जी वालों में प्रतिक्रिया हो सकती है।",
        "te":
            "అధికంగా తింటే బరువు పెరుగుతుంది మరియు లేటెక్స్ అలర్జీ ఉన్నవారికి ప్రతిక్రియ రావచ్చు.",
        "ta":
            "அதிகம் எடுத்தால் எடை கூடும், லேடெக்ஸ் அலர்ஜி உள்ளவர்களுக்கு பாதிப்பு இருக்கலாம்.",
        "kn":
            "ಹೆಚ್ಚು ಸೇವನೆ ತೂಕ ಹೆಚ್ಚಿಸಬಹುದು ಮತ್ತು ಲ್ಯಾಟೆಕ್ಸ್ ಅಲರ್ಜಿ ಇರುವವರಿಗೆ ಸಮಸ್ಯೆ.",
      },
    },

    "Bamboo": {
      "name": {
        "en": "Bamboo",
        "hi": "बांस",
        "te": "వేదురు",
        "ta": "மூங்கில்",
        "kn": "ಬಿದಿರು",
      },
      "description": {
        "en":
            "Bamboo (Bambusa vulgaris and related species) is a fast-growing woody grass belonging to the Poaceae family. In traditional medicine its young shoots, leaves and silica-rich exudate (Bamboo manna or Tabasheer) are valued for anti-inflammatory, cooling and bone-strengthening properties. It is also nutritionally rich in fiber, minerals and plant antioxidants.",
        "hi":
            "बांस एक तेजी से बढ़ने वाली घास है जिसके अंकुर, पत्ते और तबाशीर औषधीय माने जाते हैं। इसमें फाइबर, खनिज और एंटीऑक्सीडेंट पाए जाते हैं।",
        "te":
            "వేదురు వేగంగా పెరిగే గడ్డి. దీని మొగ్గలు, ఆకులు మరియు తబషీర్ ఔషధ గుణాలు కలిగి ఉంటాయి.",
        "ta":
            "மூங்கில் வேகமாக வளரும் புல்வகை தாவரம்; இதன் மொட்டுகள் மற்றும் சாறு மருத்துவப் பயன்பாடு உடையவை.",
        "kn":
            "ಬಿದಿರು ವೇಗವಾಗಿ ಬೆಳೆಯುವ ಹುಲ್ಲು; ಇದರ ಮೊಗ್ಗುಗಳು ಮತ್ತು ಸ್ರಾವ ಔಷಧೀಯ ಗುಣ ಹೊಂದಿವೆ.",
      },
      "uses": {
        "en":
            "Strengthens bones and joints, supports digestion, helps respiratory health, aids weight management due to low calories, and promotes skin healing.",
        "hi":
            "हड्डियां मजबूत करता है, पाचन सुधारता है और श्वसन स्वास्थ्य में सहायक है।",
        "te":
            "ఎముకలు బలపరుస్తుంది, జీర్ణక్రియకు మరియు శ్వాసకోశానికి సహాయపడుతుంది.",
        "ta": "எலும்பு வலிமை, செரிமானம் மற்றும் சுவாச ஆரோக்கியத்திற்கு உதவும்.",
        "kn": "ಎಲುಬು ಬಲ, ಜೀರ್ಣಕ್ರಿಯೆ ಮತ್ತು ಉಸಿರಾಟ ಆರೋಗ್ಯಕ್ಕೆ ಸಹಾಯಕ.",
      },
      "more_info": {
        "en":
            "Young bamboo shoots are eaten as a vegetable after proper boiling to remove natural cyanogenic compounds. Bamboo leaves are used in herbal teas, while bamboo silica (Tabasheer) is used in Ayurveda and Siddha medicine for bone health and cooling the body.",
        "hi":
            "अंकुर उबालकर सब्जी के रूप में खाए जाते हैं और तबाशीर आयुर्वेद में उपयोग होता है।",
        "te":
            "మొగ్గలను మరిగించి కూరగా తింటారు; తబషీర్ ఆయుర్వేదంలో ఉపయోగిస్తారు.",
        "ta":
            "மொட்டுகள் வேக வைத்து உணவாக உண்ணப்படுகின்றன; சாறு மருந்தாக பயன்படும்.",
        "kn": "ಮೊಗ್ಗುಗಳನ್ನು ಬೇಯಿಸಿ ಆಹಾರವಾಗಿ ಸೇವನೆ; ಸ್ರಾವ ಆಯುರ್ವೇದದಲ್ಲಿ ಬಳಕೆ.",
      },
      "scientific_name": {
        "en": "Bambusa vulgaris",
        "hi": "बाम्बूसा वल्गारिस",
        "te": "బాంబూసా వల్గారిస్",
        "ta": "பாம்பூசா வல்காரிஸ்",
        "kn": "ಬ್ಯಾಂಬೂಸಾ ವಲ್ಗಾರಿಸ್",
      },
      "local_names": {
        "en": "Hindi: Bans, Telugu: Veduru, Tamil: Moongil, Kannada: Bidiru",
        "hi": "तेलुगु: वेदुरु, हिंदी: बांस, तमिल: மூங்கில், कन्नड़: ಬಿದಿರು",

        "te": "తెలుగు: వేదురు, హిందీ: बांस, తమిళం: மூங்கில், కన్నడ: ಬಿದಿರು",

        "ta": "தெலுங்கு: வேதுரு, இந்தி: बांस, தமிழ்: மூங்கில், கன்னட: ಬಿದಿರು",

        "kn": "ತೆಲುಗು: ವೇದುರು, ಹಿಂದಿ: बांस, ತಮಿಳು: மூங்கில், ಕನ್ನಡ: ಬಿದಿರು",
      },
      "side_effects": {
        "en":
            "Raw bamboo shoots contain cyanogenic glycosides which can release cyanide; they must always be boiled or fermented before consumption. Excess intake may cause bloating in sensitive individuals.",
        "hi": "कच्चे अंकुर विषैले हो सकते हैं, पकाकर ही सेवन करें।",
        "te": "పచ్చిగా తింటే విషపూరితం; తప్పనిసరిగా మరిగించాలి.",
        "ta": "சமைக்காமல் சாப்பிடக் கூடாது.",
        "kn": "ಕಚ್ಚಾಗಿ ಸೇವನೆ ಮಾಡಬಾರದು.",
      },
    },

    "Basale": {
      "name": {
        "en": "Basale (Malabar Spinach)",
        "hi": "पोई साग",
        "te": "బచ్చలి కూర",
        "ta": "பசலை கீரை",
        "kn": "ಬಸಳೆ ಸೊಪ್ಪು",
      },
      "description": {
        "en":
            "Basale (Basella alba) is a tropical perennial leafy vine commonly known as Malabar spinach. Unlike true spinach, it thrives in warm and humid climates and produces thick, succulent leaves rich in vitamins A, C, E and iron. The leaves contain mucilage, antioxidants, flavonoids and beta-carotene which help reduce oxidative stress and inflammation. In traditional medicine systems like Ayurveda and Siddha it is considered a cooling plant that nourishes body tissues, supports blood formation and helps maintain hydration.",
        "hi":
            "पोई साग एक उष्णकटिबंधीय बेल वाली हरी सब्जी है जो गर्म जलवायु में उगती है। इसके पत्तों में विटामिन A, C, आयरन और एंटीऑक्सीडेंट प्रचुर मात्रा में होते हैं और यह शरीर को ठंडक देने वाला पौधा माना जाता है।",
        "te":
            "బచ్చలి కూర ఒక వేడి ప్రాంతాల్లో పెరిగే ఆకుకూర. ఇందులో విటమిన్ A, C, ఐరన్ మరియు యాంటీఆక్సిడెంట్లు సమృద్ధిగా ఉంటాయి మరియు శరీరాన్ని చల్లబరచే గుణం కలిగి ఉంటుంది.",
        "ta":
            "பசலை கீரை வெப்பமண்டலத்தில் வளரும் கொடி வகை கீரை. இதில் வைட்டமின் A, C, இரும்பு மற்றும் ஆன்டி ஆக்ஸிடென்ட் அதிகம் உள்ளது; உடலை குளிர்விக்கும் தன்மை கொண்டது.",
        "kn":
            "ಬಸಳೆ ಸೊಪ್ಪು ಉಷ್ಣವಲಯದಲ್ಲಿ ಬೆಳೆಯುವ ಲತಾ ಸಸ್ಯ. ಇದರಲ್ಲಿ ವಿಟಮಿನ್ A, C ಮತ್ತು ಕಬ್ಬಿಣ ಹೆಚ್ಚು ಇದ್ದು ದೇಹಕ್ಕೆ ತಂಪು ನೀಡುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Traditionally consumed to improve digestion, relieve constipation and acidity due to its natural soluble fiber and mucilage content. It supports hemoglobin formation in anemia, promotes lactation in nursing mothers, improves skin hydration and helps body cooling during summer heat. The leaves are also used in soups and porridges for patients recovering from illness because they are easy to digest and nutrient dense. Regular consumption strengthens immunity and helps maintain gut health by acting as a mild prebiotic.",
        "hi":
            "पाचन सुधारने, कब्ज कम करने, रक्त की कमी में लाभ और शरीर को ठंडक देने के लिए उपयोगी।",
        "te":
            "జీర్ణక్రియ మెరుగుపరచడం, మలబద్ధకం తగ్గించడం మరియు రక్తహీనతలో సహాయపడుతుంది.",
        "ta":
            "செரிமானம், மலச்சிக்கல் குறைப்பு மற்றும் உடல் குளிர்ச்சி தர பயன்படும்.",
        "kn": "ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಣೆ ಮತ್ತು ದೇಹದ ತಂಪಿಗೆ ಉಪಯುಕ್ತ.",
      },
      "more_info": {
        "en":
            "The plant produces purple berries traditionally used as natural food coloring. Leaves and stems are cooked in curries, dals and stir-fries across South India. In folk remedies, leaf paste is applied externally for minor burns, skin irritation and swelling due to its soothing mucilage. The plant grows rapidly with minimal care and is often cultivated in kitchen gardens as a nutritional leafy vegetable throughout the year in tropical regions.",
        "hi":
            "इसके बैंगनी फल प्राकृतिक रंग के रूप में उपयोग होते हैं और पत्तों का लेप त्वचा पर लगाया जाता है।",
        "te":
            "దాని ఊదా పండ్లు సహజ రంగుగా ఉపయోగిస్తారు మరియు ఆకుల పేస్ట్ చర్మానికి వేస్తారు.",
        "ta":
            "இதன் பழம் இயற்கை நிறமூட்டியாகவும் இலை விழுது தோலில் பயன்படுத்தப்படுகிறது.",
        "kn": "ಹಣ್ಣುಗಳು ಸಹಜ ಬಣ್ಣವಾಗಿ ಮತ್ತು ಎಲೆ ಲೇಪ ಚರ್ಮಕ್ಕೆ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Basella alba",
        "hi": "बसेला अल्बा",
        "te": "బసెల్లా ఆల్బా",
        "ta": "பசெல்லா ஆல்பா",
        "kn": "ಬಸೆಲ್ಲಾ ಆಲ್ಬಾ",
      },
      // "local_names": {
      //   "en":
      //       "Telugu: Bachhali kura, Hindi: Poi saag, Tamil: Pasalai keerai, Kannada: Basale soppu",
      "local_names": {
        "en":
            "Telugu: Bachhali Koora, Hindi: Poi Saag, Tamil: Pasalai Keerai, Kannada: Basale Soppu",

        "hi":
            "तेलुगु: बच्छली कूरा, हिंदी: पोई साग, तमिल: பசலை கீரை, कन्नड़: ಬಸಳೆ ಸೊಪ್ಪು",

        "te":
            "తెలుగు: బచ్చలి కూర, హిందీ: पोई साग, తమిళం: பசலை கீரை, కన్నడ: ಬಸಳೆ ಸೊಪ್ಪು",

        "ta":
            "தெலுங்கு: பச்சலி கூரா, இந்தி: पोई साग, தமிழ்: பசலை கீரை, கன்னಡ: ಬಸಳೆ ಸೊಪ್ಪು",

        "kn":
            "ತೆಲುಗು: ಬಚ್ಚಲಿ ಕೂರೆ, ಹಿಂದಿ: पोई साग, ತಮಿಳು: பசலை கீரை, ಕನ್ನಡ: ಬಸಳೆ ಸೊಪ್ಪು",
      },
      "side_effects": {
        "en":
            "Contains moderate oxalates; excessive daily consumption in very large quantities may contribute to kidney stone formation in susceptible individuals. Because of its mucilage texture it may cause mild bloating if eaten raw in large amounts; cooking improves digestibility.",
        "hi": "अधिक मात्रा में सेवन से पथरी की संभावना हो सकती है।",
        "te": "చాలా ఎక్కువగా తింటే రాళ్లు ఏర్పడే అవకాశం ఉంది.",
        "ta": "அதிகமாக சாப்பிட்டால் கல் உருவாகலாம்.",
        "kn": "ಹೆಚ್ಚು ಸೇವಿಸಿದರೆ ಕಲ್ಲು ಸಮಸ್ಯೆ ಸಾಧ್ಯ.",
      },
    },

    "Betel": {
      "name": {
        "en": "Betel Leaf (Sacred Betel Vine)",
        "hi": "पान",
        "te": "తమలపాకు",
        "ta": "வெற்றிலை",
        "kn": "ವೀಳ್ಯದೆಲೆ",
      },
      "description": {
        "en":
            "Betel leaf (Piper betle) is a perennial evergreen climbing vine belonging to the pepper family Piperaceae. The glossy heart-shaped leaves contain essential oils such as chavicol, eugenol and betel phenols which provide strong antimicrobial, antifungal and anti-inflammatory activity. It is widely cultivated across India and Southeast Asia and has both medicinal and cultural importance. In traditional medicine systems like Ayurveda and Siddha, the leaf is considered warming, stimulant and carminative, helping regulate digestion and respiratory balance. The leaf is also rich in vitamins A, C, calcium and polyphenols that help neutralize free radicals and protect body tissues.",
        "hi":
            "पान (पाइपर बेटल) एक सदाबहार बेल है जिसके पत्तों में आवश्यक तेल, एंटीऑक्सीडेंट और सूजनरोधी गुण होते हैं। आयुर्वेद में इसे गरम प्रकृति का पत्ता माना जाता है जो पाचन और श्वसन तंत्र को संतुलित करता है।",
        "te":
            "తమలపాకు పైపర్ కుటుంబానికి చెందిన ఎప్పుడూ పచ్చగా ఉండే వల్లి. ఇందులో సహజ తైలాలు, యాంటీఆక్సిడెంట్లు మరియు కఫాన్ని తగ్గించే గుణాలు ఉన్నాయి.",
        "ta":
            "வெற்றிலை ஒரு ஏறும் கொடி வகை தாவரம். இதில் உள்ள இயற்கை எண்ணெய்கள் மற்றும் ஆன்டி ஆக்ஸிடென்ட்கள் கிருமி எதிர்ப்பு மற்றும் அழற்சி எதிர்ப்பு தன்மை அளிக்கின்றன.",
        "kn":
            "ವೀಳ್ಯದೆಲೆ ಒಂದು ಏರು ಬೆಳೆಸುವ ಸದಾಕಾಲ ಹಸಿರು ಸಸ್ಯ. ಇದರಲ್ಲಿರುವ ತೈಲಗಳು ಮತ್ತು ಆಂಟಿಆಕ್ಸಿಡೆಂಟ್‌ಗಳು ಔಷಧೀಯ ಗುಣಗಳನ್ನು ನೀಡುತ್ತವೆ.",
      },
      "uses": {
        "en":
            "Chewing plain betel leaf after meals stimulates saliva secretion, improves digestion and reduces bloating and gas formation. Warmed leaves are traditionally applied on the chest to relieve cough, congestion and asthma symptoms. Leaf juice mixed with honey is used for sore throat and cold relief. The paste is applied externally to treat minor wounds, fungal infections, insect bites and joint swelling due to its antiseptic action. It also helps reduce bad breath and oral bacteria and is commonly used in postpartum care to aid recovery and reduce body pain.",
        "hi":
            "भोजन के बाद पान चबाने से पाचन सुधरता है, गैस कम होती है और सर्दी-खांसी में राहत मिलती है।",
        "te":
            "భోజనం తర్వాత నమిలితే జీర్ణక్రియ మెరుగుపడి గ్యాస్ తగ్గుతుంది మరియు దగ్గు, జలుబు తగ్గుతుంది.",
        "ta":
            "உணவுக்குப் பிறகு மென்றால் செரிமானம் மேம்படும் மற்றும் சளி குறையும்.",
        "kn":
            "ಭೋಜನದ ನಂತರ ಬಳಕೆ ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಿಸುತ್ತದೆ ಮತ್ತು ಶೀತ ಕಡಿಮೆ ಮಾಡುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Betel leaf plays an important role in Indian culture and rituals including weddings, festivals and religious offerings as a symbol of prosperity and respect. Different varieties such as Kolkata, Banarasi and Karpoori differ in aroma and pungency. The leaf is often used in herbal steam inhalation and medicinal oils. In traditional household remedies, warm betel leaf oil massage is given to infants for cold relief and to adults for joint pain. It is also used in natural oral care preparations and herbal mouth fresheners.",
        "hi":
            "भारत में धार्मिक अनुष्ठानों और अतिथि सत्कार में पान का विशेष महत्व है और विभिन्न किस्में अलग स्वाद और सुगंध देती हैं।",
        "te":
            "పూజలు, వివాహాలు మరియు ఆచారాల్లో తమలపాకు శుభప్రదంగా ఉపయోగిస్తారు.",
        "ta":
            "திருமணம் மற்றும் பூஜைகளில் வெற்றிலை மரியாதையின் அடையாளமாக வழங்கப்படுகிறது.",
        "kn": "ಹಬ್ಬಗಳು ಮತ್ತು ಪೂಜೆಯಲ್ಲಿ ವೀಳ್ಯದೆಲೆ ಗೌರವದ ಸಂಕೇತವಾಗಿ ನೀಡಲಾಗುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Piper betle",
        "hi": "पाइपर बेटल",
        "te": "పైపర్ బెటెల్",
        "ta": "பைப்பர் பெட்ல்",
        "kn": "ಪೈಪರ್ ಬೆಟಲ್",
      },
      "local_names": {
        "en":
            "Telugu: Tamalapaku, Hindi: Paan, Tamil: Vetrilai, Kannada: Veeḷyadele, Malayalam: Vettila",
        "hi": "तेलुगु: तमलपाकु, हिंदी: पान, तमिल: வெற்றிலை, कन्नड़: ವೀಳ್ಯದೆಲೆ",

        "te": "తెలుగు: తమలపాకు, హిందీ: पान, తమిళం: வெற்றிலை, కన్నಡ: ವೀಳ್ಯದೆಲೆ",

        "ta":
            "தெலுங்கு: தமலபாகு, இந்தி: पान, தமிழ்: வெற்றிலை, கன்னಡ: ವೀಳ್ಯದೆಲೆ",

        "kn": "ತೆಲುಗು: ತಮಲಪಾಕು, ಹಿಂದಿ: पान, ತಮಿಳು: வெற்றிலை, ಕನ್ನಡ: ವೀಳ್ಯದೆಲೆ",
      },
      "side_effects": {
        "en":
            "Plain betel leaf in moderation is generally safe; however chewing with areca nut, lime or tobacco for long durations may lead to oral submucous fibrosis, gum damage and increased oral cancer risk. Excess intake may also cause mild burning sensation in sensitive individuals due to strong essential oils. Pregnant women should avoid medicinal doses without medical advice.",
        "hi":
            "तंबाकू या सुपारी के साथ लंबे समय तक सेवन करने से मुंह की गंभीर बीमारियां हो सकती हैं।",
        "te":
            "పొగాకు లేదా పాకుతో ఎక్కువగా వాడితే నోటి వ్యాధులు వచ్చే ప్రమాదం ఉంది.",
        "ta":
            "புகையிலை சேர்த்து அதிகம் பயன்படுத்தினால் வாய்நோய் அபாயம் உள்ளது.",
        "kn": "ತಂಬಾಕು ಜೊತೆ ಹೆಚ್ಚು ಬಳಸಿದರೆ ಬಾಯಿ ರೋಗ ಅಪಾಯ ಇದೆ.",
      },
    },

    "Betel_Nut": {
      "name": {
        "en": "Betel Nut (Areca Nut)",
        "hi": "सुपारी",
        "te": "పొక చెక్క (అడికాయ)",
        "ta": "பாக்கு",
        "kn": "ಅಡಿಕೆ",
      },
      "description": {
        "en":
            "Betel nut, also known as areca nut, is the seed of the areca palm tree. It contains natural stimulant compounds such as arecoline that act on the nervous system. It has been traditionally used in many Asian cultures for centuries.",
        "hi":
            "सुपारी अरेका ताड़ के पेड़ का बीज है। इसमें उत्तेजक रसायन होते हैं जो तंत्रिका तंत्र पर प्रभाव डालते हैं। इसका उपयोग एशिया में पारंपरिक रूप से होता रहा है।",
        "te":
            "పొక చెక్క అరక తాటి చెట్టు గింజ. ఇందులో నాడీ వ్యవస్థను ప్రభావితం చేసే ఉత్తేజక పదార్థాలు ఉంటాయి.",
        "ta":
            "பாக்கு என்பது அரேகா மரத்தின் விதை. இதில் நரம்பு மண்டலத்தை தூண்டும் சேர்மங்கள் உள்ளன.",
        "kn":
            "ಅಡಿಕೆ ಅರೆಕಾ ತಾಳೆ ಮರದ ಬೀಜವಾಗಿದ್ದು, ನರ ವ್ಯವಸ್ಥೆಯನ್ನು ಉತ್ತೇಜಿಸುವ ಗುಣ ಹೊಂದಿದೆ.",
      },
      "uses": {
        "en":
            "Traditionally chewed with betel leaf in cultural and social practices. It has been used to increase alertness and reduce fatigue in traditional settings.",
        "hi":
            "पारंपरिक रूप से पान के साथ चबाया जाता है और सामाजिक व सांस्कृतिक अवसरों में उपयोग होता है।",
        "te": "సాంప్రదాయంగా తమలపాకుతో కలిసి నములుతారు.",
        "ta": "பாரம்பரியமாக வெற்றிலையுடன் சேர்த்து மென்றல் வழக்கத்தில் உள்ளது.",
        "kn": "ಪಾರಂಪರಿಕವಾಗಿ ವೀಳ್ಯದೆಲೆಯೊಂದಿಗೆ ಜಗಿಯಲಾಗುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Betel nut contains alkaloids that stimulate the central nervous system. While it has cultural importance, modern medical research warns against regular consumption due to serious health risks.",
        "hi":
            "सुपारी में मौजूद एल्कलॉइड केंद्रीय तंत्रिका तंत्र को उत्तेजित करते हैं, लेकिन आधुनिक चिकित्सा इसके नियमित सेवन से बचने की सलाह देती है।",
        "te":
            "ఇందులోని ఆల్కలాయిడ్లు నాడీ వ్యవస్థను ఉత్తేజితం చేస్తాయి, కానీ వైద్యులు ఎక్కువ వాడకాన్ని నిరోధిస్తున్నారు.",
        "ta":
            "இதில் உள்ள ஆல்கலாய்டுகள் நரம்பு மண்டலத்தை தூண்டும்; ஆனால் மருத்துவ ரீதியாக தொடர்ந்து பயன்படுத்துவது ஆபத்தானது.",
        "kn":
            "ಇದರಲ್ಲಿ ಇರುವ ಆಲ್ಕಲಾಯಿಡ್ಗಳು ನರ ವ್ಯವಸ್ಥೆಯನ್ನು ಉತ್ತೇಜಿಸುತ್ತವೆ, ಆದರೆ ನಿಯಮಿತ ಬಳಕೆ ಅಪಾಯಕಾರಿಯಾಗಿದೆ.",
      },
      "scientific_name": {
        "en": "Areca catechu",
        "hi": "अरेका कैटेकू",
        "te": "అరేకా కటేచు",
        "ta": "அரேகா கட்டேச்சு",
        "kn": "ಅರೆಕಾ ಕಟೆಚು",
      },
      "local_names": {
        "en":
            "Hindi: Supari, Telugu: Adikaya / Poka Chekka, Tamil: Paakku, Kannada: Adike",
        "hi": "तेलुगु: अडिकाया, हिंदी: सुपारी, तमिल: பாக்கு, कन्नड़: ಅಡಿಕೆ",

        "te": "తెలుగు: అడికాయ, హిందీ: सुपारी, తమిళం: பாக்கு, కన్నడ: ಅಡಿಕೆ",

        "ta": "தெலுங்கு: அடிகாய, இந்தி: सुपारी, தமிழ்: பாக்கு, கன்னಡ: ಅಡಿಕೆ",

        "kn": "ತೆಲುಗು: ಅಡಿಕಾಯ, ಹಿಂದಿ: सुपारी, ತಮಿಳು: பாக்கு, ಕನ್ನಡ: ಅಡಿಕೆ",
      },
      "side_effects": {
        "en":
            "Regular or long-term use can lead to addiction, oral submucous fibrosis, dental damage, and a significantly increased risk of oral cancer. Risk increases further when combined with tobacco.",
        "hi":
            "नियमित सेवन से लत, दांतों की समस्या और मुंह के कैंसर का खतरा बढ़ता है।",
        "te":
            "ఎక్కువకాలం వాడితే అలవాటు, నోటి వ్యాధులు మరియు క్యాన్సర్ ప్రమాదం పెరుగుతుంది.",
        "ta":
            "நீண்ட கால பயன்பாடு பழக்கத்தையும் வாய் புற்றுநோய் அபாயத்தையும் அதிகரிக்கும்.",
        "kn":
            "ದೀರ್ಘಕಾಲ ಬಳಕೆ ಮಾಡಿದರೆ ವ್ಯಸನ, ಬಾಯಿ ರೋಗಗಳು ಮತ್ತು ಕ್ಯಾನ್ಸರ್ ಅಪಾಯ ಹೆಚ್ಚುತ್ತದೆ.",
      },
    },

    "Brahmi": {
      "name": {
        "en": "Brahmi (Water Hyssop / Herb of Grace)",
        "hi": "ब्राह्मी",
        "te": "సరస్వతి ఆకు",
        "ta": "நீர்பிரஹ்மி",
        "kn": "ಬ್ರಾಹ್ಮಿ",
      },
      "description": {
        "en":
            "Brahmi (Bacopa monnieri) is a small creeping perennial herb that grows naturally in wetlands and marshy areas. It is one of the most important Medhya Rasayana herbs in Ayurveda, meaning a rejuvenator for the brain and nervous system. The plant contains active compounds called bacosides which enhance neuronal communication, repair damaged neurons and protect brain cells from oxidative stress. It possesses antioxidant, neuroprotective, anti-inflammatory and anxiolytic properties. Traditionally it is used to enhance intelligence, learning ability and mental clarity and is especially valued for supporting long-term cognitive health and nervous system balance.",
        "hi":
            "ब्राह्मी एक छोटी रेंगने वाली जड़ी-बूटी है जो मस्तिष्क और तंत्रिका तंत्र को मजबूत करने के लिए आयुर्वेद में मेध्य रसायन के रूप में उपयोग की जाती है। इसमें बैकोसाइड नामक यौगिक होते हैं जो मस्तिष्क कोशिकाओं की रक्षा करते हैं।",
        "te":
            "బ్రాహ్మి తడి ప్రదేశాల్లో పెరిగే చిన్న వల్లి మొక్క. ఇది ఆయుర్వేదంలో మెధ్య రసాయనంగా పరిగణించబడుతుంది మరియు మెదడు నాడీ వ్యవస్థను బలపరుస్తుంది.",
        "ta":
            "நீர்பிரஹ்மி ஈரமான இடங்களில் வளரும் சிறிய மூலிகை. இது மூளை மற்றும் நரம்பு மண்டலத்தை பாதுகாக்கும் ரஸாயன மூலிகையாக கருதப்படுகிறது.",
        "kn":
            "ಬ್ರಾಹ್ಮಿ ತೇವ ಪ್ರದೇಶಗಳಲ್ಲಿ ಬೆಳೆಯುವ ಸಣ್ಣ ಸಸ್ಯವಾಗಿದ್ದು ಮೆದುಳು ಮತ್ತು ನರಮಂಡಲಕ್ಕೆ ಪುನರುಜ್ಜೀವಕ ಔಷಧಿಯಾಗಿದೆ.",
      },
      "uses": {
        "en":
            "Enhances memory retention, learning ability, focus and concentration in students and professionals. Helps manage anxiety, mental fatigue, insomnia and stress-related disorders by calming the nervous system. Traditionally used in epilepsy, ADHD symptoms and age-related cognitive decline. Supports speech development in children and improves clarity of thinking. Also promotes hair growth when used as oil and helps reduce dandruff and scalp inflammation. Useful in improving attention span and productivity during prolonged mental work.",
        "hi":
            "स्मरण शक्ति, ध्यान और मानसिक शांति बढ़ाता है तथा तनाव और अनिद्रा में सहायक है।",
        "te":
            "జ్ఞాపకశక్తి, ఏకాగ్రత పెంచి ఒత్తిడి మరియు నిద్రలేమి తగ్గిస్తుంది.",
        "ta": "நினைவாற்றல் மற்றும் கவனத்தை அதிகரித்து மனஅழுத்தம் குறைக்கிறது.",
        "kn": "ಸ್ಮರಣೆ ಮತ್ತು ಏಕಾಗ್ರತೆ ಹೆಚ್ಚಿಸಿ ಒತ್ತಡ ಕಡಿಮೆ ಮಾಡುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "In Ayurveda Brahmi is often administered as Brahmi Ghrita, syrup, powder or medicated oil. It balances Vata and Pitta doshas and cools the nervous system. Modern research shows it may improve synaptic transmission speed and support neurotransmitters such as serotonin and acetylcholine. Traditionally students consumed Brahmi before learning scriptures to improve retention. It is also used in meditation practices to improve mental calmness and awareness. Continuous use over weeks shows gradual but long-lasting improvement rather than instant stimulation.",
        "hi":
            "आयुर्वेद में ब्राह्मी घृत, सिरप और तेल के रूप में दी जाती है और वात-पित्त को संतुलित करती है।",
        "te":
            "బ్రాహ్మి ఘృతం, పొడి లేదా నూనె రూపంలో ఉపయోగించి వాత-పిత్త దోషాలను సమతుల్యం చేస్తుంది.",
        "ta":
            "பிரஹ்மி நெய் மற்றும் எண்ணெய் வடிவில் பயன்படுத்தி உடல் தாதுக்களை சமநிலைப்படுத்துகிறது.",
        "kn": "ಬ್ರಾಹ್ಮಿ ಘೃತ ಮತ್ತು ತೈಲ ರೂಪದಲ್ಲಿ ಬಳಸಿ ದೋಷ ಸಮತೋಲನ ಮಾಡುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Bacopa monnieri",
        "hi": "बाकोपा मोनियेरी",
        "te": "బాకోపా మొన్నియేరి",
        "ta": "பகோபா மொன்னியேரி",
        "kn": "ಬಾಕೋಪಾ ಮೊನ್ನಿಯೇರಿ",
      },
      "local_names": {
        "en":
            "Hindi: Brahmi, Telugu: Saraswati aku, Tamil: Neerbrahmi, Kannada: Brahmi, Malayalam: Nirbrahmi",
        "hi":
            "तेलुगु: सरस्वती आकु, हिंदी: ब्राह्मी, तमिल: நீர்பிரஹ்மி, कन्नड़: ಬ್ರಾಹ್ಮಿ",

        "te":
            "తెలుగు: సరస్వతి ఆకు, హిందీ: ब्राह्मी, తమిళం: நீர்பிரஹ்மி, కన్నಡ: ಬ್ರಾಹ್ಮಿ",

        "ta":
            "தெலுங்கு: சரஸ்வதி ஆக்கு, இந்தி: ब्राह्मी, தமிழ்: நீர்பிரஹ்மி, கன்னಡ: ಬ್ರಾಹ್ಮಿ",

        "kn":
            "ತೆಲುಗು: ಸರಸ್ವತಿ ಆಕು, ಹಿಂದಿ: ब्राह्मी, ತಮಿಳು: நீர்பிரஹ்மி, ಕನ್ನಡ: ಬ್ರಾಹ್ಮಿ",
      },
      "side_effects": {
        "en":
            "High doses may cause nausea, stomach cramps, increased bowel movements or mild sedation in sensitive individuals. Because of its calming action it may enhance the effect of sedative medications. Excess intake may lower heart rate slightly. Pregnant women and individuals taking thyroid or psychiatric medications should use only under medical supervision.",
        "hi": "अधिक मात्रा में लेने पर मतली या पेट में गड़बड़ी हो सकती है।",
        "te": "అధిక మోతాదులో తీసుకుంటే వాంతి లేదా కడుపు సమస్యలు రావచ్చు.",
        "ta": "அதிகம் எடுத்தால் வயிற்று கோளாறு அல்லது தூக்கம் அதிகரிக்கலாம்.",
        "kn": "ಹೆಚ್ಚು ಸೇವನೆ ಮಾಡಿದರೆ ಹೊಟ್ಟೆ ತೊಂದರೆ ಅಥವಾ ಮಂಕು ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Castor": {
      "name": {
        "en": "Castor Plant",
        "hi": "अरंडी",
        "te": "ఆముదం",
        "ta": "ஆமணக்கு",
        "kn": "ಹರಳೆ",
      },
      "description": {
        "en":
            "Castor is a fast-growing perennial plant widely cultivated in tropical and subtropical regions. It is known for its large palm-like leaves and seeds that yield castor oil, which has been used for medicinal, industrial, and cosmetic purposes for centuries.",
        "hi":
            "अरंडी एक तेजी से बढ़ने वाला पौधा है जो उष्णकटिबंधीय क्षेत्रों में उगाया जाता है। इसके बीजों से प्राप्त अरंडी का तेल औषधीय और औद्योगिक उपयोग में आता है।",
        "te":
            "ఆముదం వేగంగా పెరిగే మొక్క. దీని గింజల నుండి వచ్చే నూనెను వైద్య, పరిశ్రమ మరియు సౌందర్య అవసరాలకు ఉపయోగిస్తారు.",
        "ta":
            "ஆமணக்கு ஒரு வேகமாக வளரும் தாவரம். இதன் விதைகளில் இருந்து பெறப்படும் எண்ணெய் மருத்துவம் மற்றும் தொழில்துறையில் பயன்படுகிறது.",
        "kn":
            "ಹರಳೆ ವೇಗವಾಗಿ ಬೆಳೆಯುವ ಸಸ್ಯವಾಗಿದ್ದು, ಇದರ ಬೀಜಗಳಿಂದ ದೊರೆಯುವ ಎಣ್ಣೆ ಔಷಧೀಯ ಹಾಗೂ ಕೈಗಾರಿಕಾ ಬಳಕೆಯಲ್ಲಿದೆ.",
      },
      "uses": {
        "en":
            "Castor oil is used as a natural laxative, to reduce joint pain and inflammation, promote wound healing, and improve hair and skin health. Leaves are sometimes used in traditional remedies for swelling and fever.",
        "hi":
            "अरंडी का तेल कब्ज दूर करने, सूजन कम करने, घाव भरने और बालों व त्वचा के लिए उपयोगी है।",
        "te":
            "ఆముదం నూనె మలబద్ధకం తగ్గించడానికి, వాపు తగ్గించడానికి మరియు జుట్టు ఆరోగ్యానికి ఉపయోగపడుతుంది.",
        "ta":
            "ஆமணக்கு எண்ணெய் மலச்சிக்கல் நீக்கம், வலி குறைப்பு மற்றும் தோல்-முடி பராமரிப்பிற்கு பயன்படுகிறது.",
        "kn":
            "ಹರಳೆ ಎಣ್ಣೆಯನ್ನು ಮಲಬದ್ಧತೆ, ನೋವು-ಉರಿಯೂತ ಕಡಿಮೆ ಮಾಡುವುದು ಮತ್ತು ಕೂದಲು-ಚರ್ಮ ಆರೈಕೆಗೆ ಬಳಸುತ್ತಾರೆ.",
      },
      "more_info": {
        "en":
            "Castor oil contains ricinoleic acid, responsible for many of its therapeutic properties. The plant plays an important role in Ayurveda and folk medicine, but only processed oil is considered safe for use.",
        "hi":
            "अरंडी के तेल में रिसिनोलेइक एसिड होता है जो इसके औषधीय गुणों के लिए जिम्मेदार है। केवल शुद्ध किया हुआ तेल ही सुरक्षित माना जाता है।",
        "te":
            "ఆముదం నూనెలో రిసినోలిక్ ఆమ్లం ఉండటం వల్ల ఔషధ గుణాలు కలుగుతాయి. శుద్ధి చేసిన నూనెనే సురక్షితం.",
        "ta":
            "ஆமணக்கு எண்ணெயில் உள்ள ரிசினோலெயிக் அமிலம் அதன் மருத்துவ குணங்களுக்கு காரணமாகும்.",
        "kn":
            "ಹರಳೆ ಎಣ್ಣೆಯಲ್ಲಿ ಇರುವ ರಿಸಿನೋಲೆಯಿಕ್ ಆಮ್ಲವು ಔಷಧೀಯ ಗುಣಗಳಿಗೆ ಕಾರಣವಾಗಿದೆ.",
      },
      "scientific_name": {
        "en": "Ricinus communis",
        "hi": "रिकिनस कम्यूनिस",
        "te": "రిసినస్ కమ్యూనిస్",
        "ta": "ரிசினஸ் கம்யூனிஸ்",
        "kn": "ರಿಸಿನಸ್ ಕಮ್ಯೂನಿಸ್",
      },
      "local_names": {
        "en": "Hindi: Arandi, Telugu: Amudam, Tamil: Amanakku, Kannada: Harale",
        "hi": "तेलुगु: आमुदम, हिंदी: अरंडी, तमिल: ஆமணக்கு, कन्नड़: ಹರಳೆ",

        "te": "తెలుగు: ఆముదం, హిందీ: अरंडी, తమిళం: ஆமணக்கு, కన్నಡ: ಹರಳೆ",

        "ta": "தெலுங்கு: ஆமுதம், இந்தி: अरंडी, தமிழ்: ஆமணக்கு, கன்னಡ: ಹರಳೆ",

        "kn": "ತೆಲುಗು: ಆಮುದಂ, ಹಿಂದಿ: अरंडी, ತಮಿಳು: ஆமணக்கு, ಕನ್ನಡ: ಹರಳೆ",
      },
      "side_effects": {
        "en":
            "Raw castor seeds are extremely poisonous due to the presence of ricin and should never be consumed. Excessive use of castor oil may cause dehydration, cramps, or diarrhea.",
        "hi":
            "अरंडी के कच्चे बीज अत्यंत विषैले होते हैं। तेल का अधिक सेवन नुकसानदायक हो सकता है।",
        "te":
            "ఆముదం గింజలు తీవ్రమైన విషపూరితం. నూనెను అధికంగా వాడితే దుష్ప్రభావాలు కలుగుతాయి.",
        "ta":
            "ஆமணக்கு விதைகள் மிகவும் நச்சுத்தன்மை உடையவை. எண்ணெயை அதிகமாக பயன்படுத்தினால் பக்கவிளைவுகள் ஏற்படும்.",
        "kn":
            "ಹರಳೆ ಬೀಜಗಳು ಅತ್ಯಂತ ವಿಷಕಾರಿ. ಎಣ್ಣೆಯ ಅತಿಯಾದ ಬಳಕೆ ಅಸಹಜ ಪರಿಣಾಮಗಳಿಗೆ ಕಾರಣವಾಗಬಹುದು.",
      },
    },

    "Curry_Leaf": {
      "name": {
        "en": "Curry Leaf (Sweet Neem)",
        "hi": "करी पत्ता",
        "te": "కరివేపాకు",
        "ta": "கருவேப்பிலை",
        "kn": "ಕರಿಬೇವು",
      },
      "description": {
        "en":
            "Curry leaf (Murraya koenigii) is a fragrant evergreen leaf native to the Indian subcontinent and widely used in traditional cooking and medicine. The leaves are rich in alkaloids, flavonoids, iron, calcium, phosphorus, fiber and vitamins A, B, C and E. In Ayurveda it is considered a digestive stimulant and a Rasayana herb that nourishes body tissues. It possesses antioxidant, antimicrobial, anti-diabetic, hepatoprotective and anti-inflammatory properties. The bioactive compounds such as mahanimbine and carbazole alkaloids protect cells from oxidative damage and support metabolic health.",
        "hi":
            "करी पत्ता भारत में पाया जाने वाला सुगंधित सदाबहार पत्ता है जिसमें आयरन, कैल्शियम और विटामिन प्रचुर मात्रा में होते हैं तथा यह पाचन और चयापचय को सुधारता है।",
        "te":
            "కరివేపాకు భారతదేశానికి చెందిన సువాసనగల శాశ్వత ఆకు. ఇందులో ఐరన్, కాల్షియం, విటమిన్లు సమృద్ధిగా ఉండి జీర్ణక్రియ మరియు మెటాబాలిజాన్ని మెరుగుపరుస్తుంది.",
        "ta":
            "கருவேப்பிலை இந்தியாவை சேர்ந்த மணமுள்ள எப்போதும் பசுமையான இலை. இதில் இரும்பு, கால்சியம் மற்றும் வைட்டமின்கள் அதிகம் உள்ளதால் உடல் மாற்றுச்செயல்முறையை மேம்படுத்துகிறது.",
        "kn":
            "ಕರಿಬೇವು ಭಾರತ ಮೂಲದ ಸುಗಂಧಿತ ಸದಾಕಾಲ ಹಸಿರು ಎಲೆ ಆಗಿದ್ದು ಐರನ್, ಕ್ಯಾಲ್ಸಿಯಂ ಮತ್ತು ವಿಟಮಿನ್‌ಗಳಿಂದ ಸಮೃದ್ಧವಾಗಿದೆ.",
      },
      "uses": {
        "en":
            "Improves digestion by stimulating digestive enzymes and reducing bloating, acidity and nausea. Traditionally used to manage diabetes by regulating blood glucose levels and improving insulin activity. Strengthens hair roots, prevents premature greying and reduces dandruff when applied as oil or paste. Supports liver detoxification, improves appetite and helps treat diarrhea and dysentery. Also used to reduce cholesterol levels and support heart health.",
        "hi":
            "पाचन सुधारता है, मधुमेह नियंत्रित करने में सहायक और बालों को मजबूत बनाता है।",
        "te":
            "జీర్ణక్రియ మెరుగుపరచి మధుమేహ నియంత్రణలో సహాయపడుతుంది మరియు జుట్టును బలపరుస్తుంది.",
        "ta":
            "செரிமானம் மேம்படுத்து, நீரிழிவு கட்டுப்படுத்த உதவி செய்து முடி வலுப்படுத்துகிறது.",
        "kn":
            "ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಿಸಿ ಮಧುಮೇಹ ನಿಯಂತ್ರಣಕ್ಕೆ ಸಹಾಯಮಾಡಿ ಕೂದಲು ಬಲಪಡಿಸುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Fresh leaves are commonly tempered in oil at the beginning of cooking to release aromatic oils and enhance nutrient absorption. In traditional medicine curry leaf juice is consumed in the morning to improve metabolism and eye health. The leaves also contain natural iron making them useful in anemia management when combined with vitamin C sources. Regular intake supports weight management by improving fat metabolism and reducing lipid accumulation.",
        "hi":
            "इसे भोजन में तड़के के रूप में उपयोग किया जाता है और सुबह खाली पेट लेने से चयापचय और आंखों के स्वास्थ्य में सुधार होता है।",
        "te":
            "వంటల్లో తాలింపు కోసం ఉపయోగిస్తారు మరియు ఉదయం తీసుకుంటే మెటాబాలిజం మెరుగుపడుతుంది.",
        "ta":
            "சமையலில் தாளிப்பாக பயன்படுத்தி காலை எடுத்தால் உடல் மாற்றுச்செயல் மேம்படும்.",
        "kn":
            "ಅಡುಗೆಯಲ್ಲಿ ಒಗ್ಗರಣೆಗಾಗಿ ಬಳಸಲಾಗುತ್ತದೆ ಮತ್ತು ಬೆಳಿಗ್ಗೆ ಸೇವಿಸಿದರೆ ಮೆಟಾಬಾಲಿಸಂ ಉತ್ತಮವಾಗುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Murraya koenigii",
        "hi": "मुराया कोएनिगी",
        "te": "ముర్రాయా కోనిగీ",
        "ta": "முர்ராயா கோனிகி",
        "kn": "ಮುರ್ರಾಯಾ ಕೋನಿಗಿ",
      },
      "local_names": {
        "en":
            "Hindi: Kadi patta, Telugu: Karivepaku, Tamil: Karuveppilai, Kannada: Karibevu, Malayalam: Kariveppila",
        "hi":
            "तेलुगु: करिवेपाकु, हिंदी: करी पत्ता, तमिल: கருவேப்பிலை, कन्नड़: ಕರಿಬೇವು",

        "te":
            "తెలుగు: కరివేపాకు, హిందీ: करी पत्ता, తమిళం: கருவேப்பிலை, కన్నಡ: ಕರಿಬೇವು",

        "ta":
            "தெலுங்கு: கரிவேபாகு, இந்தி: करी पत्ता, தமிழ்: கருவேப்பிலை, கன்னಡ: ಕರಿಬೇವು",

        "kn":
            "ತೆಲುಗು: ಕರಿವೇಪಾಕು, ಹಿಂದಿ: करी पत्ता, ತಮಿಳು: கருவேப்பிலை, ಕನ್ನಡ: ಕರಿಬೇವು",
      },
      "side_effects": {
        "en":
            "Generally safe when consumed in food quantities. Very high medicinal doses may cause excessive lowering of blood sugar especially in diabetic patients on medication. Rarely may cause mild stomach upset in sensitive individuals. People with hypoglycemia or taking anti-diabetic drugs should monitor sugar levels when consuming concentrated extracts.",
        "hi": "अधिक मात्रा में लेने पर रक्त शर्करा बहुत कम हो सकती है।",
        "te": "అధిక మోతాదులో తీసుకుంటే రక్తంలో చక్కెర తగ్గవచ్చు.",
        "ta": "அதிகம் எடுத்தால் இரத்த சர்க்கரை குறையலாம்.",
        "kn": "ಹೆಚ್ಚು ಸೇವನೆ ಮಾಡಿದರೆ ರಕ್ತದ ಸಕ್ಕರೆ ಕಡಿಮೆಯಾಗಬಹುದು.",
      },
    },

    "Doddapatre": {
      "name": {
        "en": "Doddapatre (Indian Borage / Mexican Mint)",
        "hi": "पथरचूर",
        "te": "వాము ఆకు",
        "ta": "ஓமவல்லி",
        "kn": "ದೊಡ್ಡಪತ್ರೆ",
      },
      "description": {
        "en":
            "Doddapatre (Plectranthus amboinicus) is a thick-leaved aromatic medicinal herb belonging to the mint family. The leaves contain essential oils such as thymol and carvacrol that possess strong antimicrobial, antifungal and anti-inflammatory activity. Traditionally it is valued in Ayurveda and folk medicine for respiratory health, digestive support and immunity enhancement. The plant also contains antioxidants, vitamin C, calcium and iron which help protect body tissues from oxidative stress and support overall wellness.",
        "hi":
            "पथरचूर पुदीना कुल का सुगंधित औषधीय पौधा है जिसमें थाइमोल जैसे तेल पाए जाते हैं जो संक्रमण और सूजन कम करने में सहायक होते हैं।",
        "te":
            "వాము ఆకు పుదీనా కుటుంబానికి చెందిన సువాసనగల ఔషధ మొక్క. ఇందులో థైమాల్ వంటి తైలాలు ఉండి సంక్రమణలు మరియు వాపు తగ్గిస్తాయి.",
        "ta":
            "ஓமவல்லி புதினா குடும்பத்தை சேர்ந்த மணமுள்ள மூலிகை. இதில் தைமால் போன்ற எண்ணெய்கள் இருந்து கிருமி எதிர்ப்பு தன்மை அளிக்கிறது.",
        "kn":
            "ದೊಡ್ಡಪತ್ರೆ ಪುದೀನ ಕುಟುಂಬದ ಸುಗಂಧಿತ ಔಷಧೀಯ ಸಸ್ಯವಾಗಿದ್ದು ಥೈಮಾಲ್ ಇರುವುದರಿಂದ ಸೋಂಕು ಹಾಗೂ ಉರಿಯೂತ ಕಡಿಮೆ ಮಾಡುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Fresh leaf juice or decoction is commonly used to relieve cough, cold, asthma, throat irritation and bronchitis. Improves digestion by reducing gas, bloating and indigestion and stimulates appetite. Applied as paste to insect bites, minor burns and skin infections due to its antiseptic action. Warm leaf extracts are also traditionally given to children for colic and respiratory congestion.",
        "hi":
            "खांसी, दमा और पाचन समस्या में उपयोगी तथा त्वचा संक्रमण में लगाया जाता है।",
        "te":
            "దగ్గు, ఆస్తమా మరియు జీర్ణ సమస్యల్లో ఉపయోగించి చర్మ సంక్రమణలకు పూతగా వేస్తారు.",
        "ta":
            "இருமல், ஆஸ்துமா மற்றும் செரிமான பிரச்சினைகளில் பயன்படுத்தி தோல் நோய்களுக்கு தடவப்படுகிறது.",
        "kn":
            "ಕೆಮ್ಮು, ಆಸ್ತಮಾ ಮತ್ತು ಜೀರ್ಣ ಸಮಸ್ಯೆಗಳಲ್ಲಿ ಉಪಯೋಗಿಸಿ ಚರ್ಮದ ಸೋಂಕಿಗೆ ಲೇಪವಾಗಿ ಬಳಸುತ್ತಾರೆ.",
      },
      "more_info": {
        "en":
            "Leaves are often steamed or sautéed and consumed to reduce throat irritation and improve immunity. In traditional home remedies the leaves are boiled with pepper and honey as a natural cough syrup. The plant is easy to grow in pots and releases a strong oregano-like aroma when crushed, indicating presence of medicinal volatile oils.",
        "hi":
            "घरेलू उपचार में काढ़ा बनाकर खांसी में दिया जाता है और आसानी से घर में उगाया जा सकता है।",
        "te":
            "ఇంటి వైద్యంలో కషాయం చేసి దగ్గుకు ఇస్తారు మరియు ఇంట్లో సులభంగా పెంచవచ్చు.",
        "ta":
            "வீட்டு வைத்தியத்தில் கஷாயம் செய்து இருமலுக்கு கொடுக்கப்படுகிறது மற்றும் வீட்டில் எளிதில் வளர்க்கலாம்.",
        "kn":
            "ಮನೆಮದ್ದಿನಲ್ಲಿ ಕಷಾಯ ಮಾಡಿ ಕೆಮ್ಮಿಗೆ ಕೊಡುತ್ತಾರೆ ಮತ್ತು ಮನೆಯಲ್ಲಿ ಸುಲಭವಾಗಿ ಬೆಳೆಯುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Plectranthus amboinicus",
        "hi": "प्लेक्ट्रान्थस अम्बोइनिकस",
        "te": "ప్లెక్ట్రాంతస్ అంబోయినికస్",
        "ta": "ப்ளெக்ட்ரான்தஸ் அம்போயினிகஸ்",
        "kn": "ಪ್ಲೆಕ್ಟ್ರಾಂಥಸ್ ಅಂಬೊಯಿನಿಕಸ್",
      },
      "local_names": {
        "en":
            "Telugu: Vamu aaku, Kannada: Doddapatre, Hindi: Patharchur, Tamil: Omavalli, Malayalam: Panikoorka",
        "hi":
            "तेलुगु: वामु आकु, हिंदी: पथरचूर, तमिल: ஓமவல்லி, कन्नड़: ದೊಡ್ಡಪತ್ರೆ",

        "te":
            "తెలుగు: వాము ఆకు, హిందీ: पथरचूर, తమిళం: ஓமவல்லி, కన్నಡ: ದೊಡ್ಡಪತ್ರೆ",

        "ta":
            "தெலுங்கு: வாமு ஆக்கு, இந்தி: पथरचूर, தமிழ்: ஓமவல்லி, கன்னಡ: ದೊಡ್ಡಪತ್ರೆ",

        "kn":
            "ತೆಲುಗು: ವಾಮು ಆಕು, ಹಿಂದಿ: पथरचूर, ತಮಿಳು: ஓமவல்லி, ಕನ್ನಡ: ದೊಡ್ಡಪತ್ರೆ",
      },
      "side_effects": {
        "en":
            "Generally safe in small culinary or medicinal quantities. Excess consumption may cause stomach irritation, acidity or nausea due to strong essential oils. Very concentrated extracts may not be suitable for pregnant women and infants without medical guidance.",
        "hi": "अधिक मात्रा में लेने से पेट में जलन हो सकती है।",
        "te": "అధికంగా తీసుకుంటే కడుపు మంట కలగవచ్చు.",
        "ta": "அதிகமாக எடுத்தால் வயிற்று எரிச்சல் ஏற்படலாம்.",
        "kn": "ಹೆಚ್ಚು ಸೇವನೆ ಹೊಟ್ಟೆ ಉರಿಯೂತ ಉಂಟುಮಾಡಬಹುದು.",
      },
    },

    "Ekka": {
      "name": {
        "en": "Ekka (Crown Flower)",
        "hi": "आक",
        "te": "జిల్లేడు",
        "ta": "எருக்கு",
        "kn": "ಎಕ್ಕ",
      },
      "description": {
        "en":
            "Ekka is a hardy perennial shrub commonly found in dry and wasteland areas. It produces thick, milky latex and large leaves, and has been used in traditional medicine mainly for external therapeutic purposes.",
        "hi":
            "आक एक मजबूत झाड़ीदार पौधा है जो सूखे क्षेत्रों में उगता है। इसमें दूधिया रस होता है और इसका उपयोग पारंपरिक चिकित्सा में मुख्यतः बाहरी उपचार के लिए किया जाता है।",
        "te":
            "జిల్లేడు పొడి ప్రాంతాల్లో పెరిగే బలమైన పొద మొక్క. దీనిలో పాలు వంటి రసం ఉండి సంప్రదాయ వైద్యంలో ఎక్కువగా బయటి ఉపయోగాల కోసం వాడతారు.",
        "ta":
            "எருக்கு வறண்ட நிலங்களில் வளரும் வலுவான புதர். இதில் பால் போன்ற சாறு இருப்பதால் வெளிப்புற மருத்துவத்தில் அதிகம் பயன்படுத்தப்படுகிறது.",
        "kn":
            "ಎಕ್ಕ ಒಣ ಪ್ರದೇಶಗಳಲ್ಲಿ ಬೆಳೆಯುವ ಬಲವಾದ ಪೊದೆಯಾಗಿದ್ದು, ಹಾಲು ರಸದಂತಹ ಲ್ಯಾಟೆಕ್ಸ್ ಹೊಂದಿದೆ.",
      },
      "uses": {
        "en":
            "Traditionally used for treating skin infections, joint pain, swelling, and wounds. Warmed leaves are sometimes applied externally to relieve pain and inflammation.",
        "hi":
            "त्वचा संक्रमण, जोड़ों के दर्द, सूजन और घावों के उपचार में बाहरी रूप से उपयोग किया जाता है।",
        "te":
            "చర్మ సంక్రమణలు, సంధి నొప్పులు, వాపు మరియు గాయాల చికిత్సకు బయటి ఉపయోగం.",
        "ta":
            "தோல் நோய்கள், மூட்டு வலி மற்றும் வீக்கம் குறைக்க வெளிப்புறமாக பயன்படுகிறது.",
        "kn":
            "ಚರ್ಮ ಸೋಂಕು, ಸಂಧಿ ನೋವು ಮತ್ತು ಊತ ಕಡಿಮೆ ಮಾಡಲು ಹೊರಗಿನಿಂದ ಬಳಸುತ್ತಾರೆ.",
      },
      "more_info": {
        "en":
            "Ekka plays an important role in Ayurveda and folk medicine. The plant contains bioactive compounds with antimicrobial and anti-inflammatory properties, but it is not commonly recommended for internal consumption.",
        "hi":
            "आक आयुर्वेद और लोक चिकित्सा में महत्वपूर्ण है, लेकिन आंतरिक सेवन सामान्यतः अनुशंसित नहीं है।",
        "te":
            "జిల్లేడు ఆయుర్వేదం మరియు జానపద వైద్యంలో ముఖ్యమైనది, కానీ అంతర్గతంగా వాడటం సాధారణంగా సూచించరు.",
        "ta":
            "ஆயுர்வேதம் மற்றும் நாட்டுப்புற மருத்துவத்தில் எருக்கு முக்கியமானது, ஆனால் உள்பயன்பாடு தவிர்க்கப்படுகிறது.",
        "kn":
            "ಆಯುರ್ವೇದ ಮತ್ತು ಜನಪದ ವೈದ್ಯಕೆಯಲ್ಲಿ ಎಕ್ಕ ಮಹತ್ವದ ಸಸ್ಯವಾದರೂ ಒಳಗೆ ಸೇವಿಸುವುದು ಅಪಾಯಕಾರಿ.",
      },
      "scientific_name": {
        "en": "Calotropis gigantea",
        "hi": "कैलोट्रोपिस गिगेंटिया",
        "te": "కలోట్రోపిస్ గిగాంటియా",
        "ta": "கலோட்ரோபிஸ் ஜிகாண்டியா",
        "kn": "ಕ್ಯಾಲೋಟ್ರೋಪಿಸ್ ಗಿಗಾಂಟಿಯಾ",
      },
      "local_names": {
        "en": "Hindi: Aak, Telugu: Jilledu, Tamil: Erukku, Kannada: Ekka",
        "hi": "तेलुगु: जिल्लेडु, हिंदी: आक, तमिल: எருக்கு, कन्नड़: ಎಕ್ಕ",

        "te": "తెలుగు: జిల్లేడు, హిందీ: आक, తమిళం: எருக்கு, కన్నಡ: ಎಕ್ಕ",

        "ta": "தெலுங்கு: ஜில்லேடு, இந்தி: आक, தமிழ்: எருக்கு, கன்னಡ: ಎಕ್ಕ",

        "kn": "ತೆಲುಗು: ಜಿಲ್ಲೇಡು, ಹಿಂದಿ: आक, ತಮಿಳು: எருக்கு, ಕನ್ನಡ: ಎಕ್ಕ",
      },
      "side_effects": {
        "en":
            "The milky latex is toxic and may cause skin irritation, blisters, or eye damage if mishandled. Internal use without medical supervision can be dangerous.",
        "hi":
            "दूधिया रस विषैला होता है और त्वचा या आंखों को नुकसान पहुंचा सकता है।",
        "te": "పాలు వంటి రసం విషపూరితం; చర్మం లేదా కళ్లకు హాని కలిగించవచ్చు.",
        "ta":
            "பால் போன்ற சாறு நச்சுத்தன்மை உடையது; தோல் மற்றும் கண்களுக்கு சேதம் விளைவிக்கலாம்.",
        "kn": "ಹಾಲು ರಸ ವಿಷಕಾರಿ; ಚರ್ಮ ಮತ್ತು ಕಣ್ಣುಗಳಿಗೆ ಹಾನಿಕಾರಕ.",
      },
    },

    "Ganike": {
      "name": {
        "en": "Ganike (Marigold / African Marigold)",
        "hi": "गेंदा",
        "te": "బంతి",
        "ta": "சாமந்தி",
        "kn": "ಗಣಿಕೆ",
      },
      "description": {
        "en":
            "Ganike (Tagetes erecta) is a bright orange-yellow flowering medicinal plant belonging to the Asteraceae family. The flowers are rich in flavonoids, carotenoids (especially lutein), essential oils and triterpenes that provide strong antiseptic, antibacterial and anti-inflammatory activity. Traditionally the plant has been valued in Ayurveda and folk medicine for treating skin infections, eye disorders and wounds. Its antioxidant compounds help protect tissues from microbial growth and oxidative damage.",
        "hi":
            "गेंदा एस्टरेसी कुल का औषधीय फूल है जिसमें ल्यूटिन, फ्लेवोनॉयड और आवश्यक तेल पाए जाते हैं जो संक्रमण और सूजन कम करने में सहायक होते हैं।",
        "te":
            "బంతి ఆస్టరేసీ కుటుంబానికి చెందిన ఔషధ పుష్ప మొక్క. ఇందులో ల్యూటిన్, ఫ్లేవనాయిడ్లు మరియు తైలాలు ఉండి సంక్రమణలు మరియు వాపు తగ్గిస్తాయి.",
        "ta":
            "சாமந்தி அஸ்டரேசி குடும்பத்தை சேர்ந்த மருத்துவ மலர். இதில் லூட்டீன் மற்றும் தைலங்கள் இருந்து கிருமி எதிர்ப்பு தன்மை அளிக்கிறது.",
        "kn":
            "ಗಣಿಕೆ ಅಸ್ಟರೇಸಿ ಕುಟುಂಬದ ಔಷಧೀಯ ಹೂವಾಗಿದ್ದು ಲ್ಯೂಟಿನ್ ಮತ್ತು ತೈಲಗಳಿಂದ ಸೋಂಕು ಹಾಗೂ ಉರಿಯೂತ ಕಡಿಮೆ ಮಾಡುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Fresh flower paste is applied on cuts, burns and wounds to accelerate healing and prevent infection. Infusion of petals is used as eye wash in traditional medicine to soothe irritation and redness. Oil extracts are used in skin care to reduce acne, rashes and insect bites. The plant is also used in herbal teas for mild digestive relief and immunity support.",
        "hi": "घाव भरने, त्वचा संक्रमण, आंखों की जलन और कीट काटने में उपयोगी।",
        "te":
            "గాయాలు, చర్మ సంక్రమణలు, కంటి చికాకు మరియు పురుగు కాట్లలో ఉపయోగిస్తారు.",
        "ta": "காயம், தோல் தொற்று மற்றும் கண் எரிச்சலில் பயன்படுத்தப்படுகிறது.",
        "kn": "ಗಾಯ, ಚರ್ಮ ಸೋಂಕು ಮತ್ತು ಕಣ್ಣಿನ ಉರಿಯಲ್ಲಿ ಬಳಸುತ್ತಾರೆ.",
      },
      "more_info": {
        "en":
            "The flowers are widely used in religious rituals and decorations in India symbolizing purity and positivity. Lutein extracted from petals is commercially used for improving eye health and protecting vision from blue-light damage. The plant also acts as a natural insect repellent in gardens and agriculture due to its strong aroma.",
        "hi":
            "धार्मिक पूजा और सजावट में उपयोग तथा आंखों के स्वास्थ्य के लिए ल्यूटिन का स्रोत।",
        "te":
            "పూజలు మరియు అలంకరణలో ఉపయోగించి కంటి ఆరోగ్యానికి ల్యూటిన్ మూలంగా పనిచేస్తుంది.",
        "ta":
            "பூஜை மற்றும் அலங்காரத்தில் பயன்படுத்தி கண் ஆரோக்கியத்திற்கு உதவுகிறது.",
        "kn":
            "ಪೂಜೆ ಮತ್ತು ಅಲಂಕಾರದಲ್ಲಿ ಬಳಸಲಾಗುತ್ತದೆ ಮತ್ತು ಕಣ್ಣಿನ ಆರೋಗ್ಯಕ್ಕೆ ಉಪಕಾರಿ.",
      },
      "scientific_name": {
        "en": "Tagetes erecta",
        "hi": "टैजेटीस एरेक्टा",
        "te": "టాగెటిస్ ఎరెక్టా",
        "ta": "டேகிடிஸ் எரக்டா",
        "kn": "ಟ್ಯಾಜೇಟಿಸ್ ಎರಕ್ಟಾ",
      },
      "local_names": {
        "en":
            "Hindi: Genda, Kannada: Ganike, Telugu: Banthi, Tamil: Samanthi, Malayalam: Chendumalli",

        "hi": "तेलुगु: बंथि, हिंदी: गेंदा, तमिल: சாமந்தி, कन्नड़: ಗಣಿಕೆ",

        "te": "తెలుగు: బంతి, హిందీ: गेंदा, తమిళం: சாமந்தி, కన్నಡ: ಗಣಿಕೆ",

        "ta": "தெலுங்கு: பந்தி, இந்தி: गेंदा, தமிழ்: சாமந்தி, கன்னಡ: ಗಣಿಕೆ",

        "kn": "ತೆಲುಗು: ಬಂತಿ, ಹಿಂದಿ: गेंदा, ತಮಿಳು: சாமந்தி, ಕನ್ನಡ: ಗಣಿಕೆ",
      },
      "side_effects": {
        "en":
            "Direct contact with concentrated extracts may cause skin irritation or dermatitis in sensitive individuals. Pollen exposure may trigger mild allergies such as itching or redness in some people.",
        "hi": "कुछ लोगों में त्वचा एलर्जी या खुजली हो सकती है।",
        "te": "కొంతమందిలో చర్మ అలర్జీ లేదా దురద కలగవచ్చు.",
        "ta": "சிலருக்கு தோல் அலர்ஜி ஏற்படலாம்.",
        "kn": "ಕೆಲವರಲ್ಲಿ ಚರ್ಮ ಅಲರ್ಜಿ ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Guava": {
      "name": {
        "en": "Guava",
        "hi": "अमरूद",
        "te": "జామ",
        "ta": "கொய்யா",
        "kn": "ಸೀಬೆಹಣ್ಣು",
      },
      "description": {
        "en":
            "Guava is a tropical fruit-bearing plant widely grown in India and other warm regions. The fruit is highly nutritious, rich in vitamin C, dietary fiber, antioxidants, and essential minerals, making it beneficial for overall health.",
        "hi":
            "अमरूद एक उष्णकटिबंधीय फल है जो विटामिन C, फाइबर और एंटीऑक्सीडेंट से भरपूर होता है और स्वास्थ्य के लिए बहुत लाभकारी है।",
        "te":
            "జామ ఒక ఉష్ణమండల పండు. ఇందులో విటమిన్ C, ఫైబర్ మరియు యాంటీఆక్సిడెంట్లు అధికంగా ఉంటాయి.",
        "ta":
            "கொய்யா ஒரு உஷ்ண மண்டல பழம். இதில் வைட்டமின் C, நார்ச்சத்து மற்றும் ஆன்டி-ஆக்ஸிடென்ட்கள் அதிகம் உள்ளன.",
        "kn":
            "ಸೀಬೆಹಣ್ಣು ಉಷ್ಣವಲಯದ ಹಣ್ಣು ಆಗಿದ್ದು, ವಿಟಮಿನ್ C ಮತ್ತು ಫೈಬರ್ ತುಂಬಿದೆ.",
      },
      "uses": {
        "en":
            "Helps improve digestion, boosts immunity, supports heart health, regulates blood sugar levels, and promotes healthy skin due to its high vitamin and fiber content.",
        "hi":
            "पाचन सुधारता है, रोग प्रतिरोधक क्षमता बढ़ाता है, हृदय स्वास्थ्य और त्वचा के लिए लाभदायक है।",
        "te":
            "జీర్ణక్రియ మెరుగుపరుస్తుంది, రోగనిరోధక శక్తిని పెంచుతుంది మరియు గుండె ఆరోగ్యానికి మంచిది.",
        "ta":
            "செரிமானத்தை மேம்படுத்தும், நோய் எதிர்ப்பு சக்தியை அதிகரிக்கும், இதய ஆரோக்கியத்திற்கு உதவும்.",
        "kn":
            "ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಣೆ, ರೋಗನಿರೋಧಕ ಶಕ್ತಿ ಹೆಚ್ಚಳ ಮತ್ತು ಹೃದಯ ಆರೋಗ್ಯಕ್ಕೆ ಸಹಕಾರಿ.",
      },
      "more_info": {
        "en":
            "Guava fruits, leaves, and bark are used in traditional medicine. Guava leaf decoction is commonly used to manage diarrhea and oral health. The fruit is consumed fresh, cooked, or processed into juice, jam, and desserts.",
        "hi":
            "अमरूद के फल, पत्ते और छाल पारंपरिक चिकित्सा में उपयोग होते हैं। पत्तों का काढ़ा दस्त और दांतों की समस्याओं में उपयोगी है।",
        "te":
            "జామ పండ్లు, ఆకులు మరియు తొక్క సంప్రదాయ వైద్యంలో ఉపయోగిస్తారు. ఆకుల కషాయం విరేచనాలకు వాడతారు.",
        "ta":
            "கொய்யாவின் பழம், இலை, பட்டை ஆகியவை நாட்டுப்புற மருத்துவத்தில் பயன்படுகின்றன.",
        "kn":
            "ಸೀಬೆಹಣ್ಣಿನ ಹಣ್ಣು, ಎಲೆ ಮತ್ತು ತೊಗಟೆಯನ್ನು ಪರಂಪರাগত ವೈದ್ಯಕೆಯಲ್ಲಿ ಬಳಸುತ್ತಾರೆ.",
      },
      "scientific_name": {
        "en": "Psidium guajava",
        "hi": "सिडियम ग्वाजावा",
        "te": "సిడియం గ్వాజావా",
        "ta": "சிடியம் குவாஜாவா",
        "kn": "ಸಿಡಿಯಂ ಗುವಾಜಾವಾ",
      },
      "local_names": {
        "en": "Hindi: Amrood, Telugu: Jama, Tamil: Koyya, Kannada: Seebe Hannu",
        "hi": "तेलुगु: जाम, हिंदी: अमरूद, तमिल: கொய்யா, कन्नड़: ಸೀಬೆಹಣ್ಣು",

        "te": "తెలుగు: జామ, హిందీ: अमरूद, తమిళం: கொய்யா, కన్నಡ: ಸೀಬೆಹಣ್ಣು",

        "ta": "தெலுங்கு: ஜாம, இந்தி: अमरूद, தமிழ்: கொய்யா, கன்னಡ: ಸೀಬೆಹಣ್ಣು",

        "kn": "ತೆಲುಗು: ಜಾಮ, ಹಿಂದಿ: अमरूद, ತಮಿಳು: கொய்யா, ಕನ್ನಡ: ಸೀಬೆಹಣ್ಣು",
      },
      "side_effects": {
        "en":
            "Excessive consumption, especially of unripe guava, may cause constipation or bloating due to high fiber content. People with sensitive digestion should consume in moderation.",
        "hi":
            "अधिक मात्रा में सेवन, विशेषकर कच्चे अमरूद का, कब्ज या पेट फूलने का कारण बन सकता है।",
        "te": "అతి మోతాదులో, ముఖ్యంగా పచ్చి జామ తింటే మలబద్ధకం కలగవచ్చు.",
        "ta": "அதிகமாக அல்லது பச்சை கொய்யா சாப்பிட்டால் மலச்சிக்கல் ஏற்படலாம்.",
        "kn": "ಹೆಚ್ಚಾಗಿ ಅಥವಾ ಕಚ್ಚಾ ಸೀಬೆಹಣ್ಣು ತಿಂದರೆ ಮಲಬದ್ಧತೆ ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Geranium": {
      "name": {
        "en": "Geranium (Rose Geranium)",
        "hi": "जेरैनियम",
        "te": "జెరేనియం",
        "ta": "ஜெரானியம்",
        "kn": "ಜೆರಾನಿಯಂ",
      },
      "description": {
        "en":
            "Geranium (Pelargonium graveolens) is a fragrant medicinal shrub known for its rose-like aroma and therapeutic essential oil. The leaves and flowers contain citronellol, geraniol and linalool compounds which provide antibacterial, antifungal and anti-inflammatory properties. Traditionally used in herbal medicine and perfumery, the plant is valued for balancing skin health, calming nerves and promoting emotional well-being.",
        "hi":
            "जेरैनियम सुगंधित औषधीय पौधा है जिसमें जेरानियोल और सिट्रोनेलोल जैसे यौगिक होते हैं जो जीवाणुरोधी और सूजनरोधी गुण प्रदान करते हैं।",
        "te":
            "జెరేనియం సుగంధ ఔషధ మొక్క. ఇందులో జెరానియోల్ మరియు సిట్రోనెల్లోల్ ఉండి బ్యాక్టీరియా నిరోధక లక్షణాలు కలిగి ఉంటుంది.",
        "ta":
            "ஜெரானியம் மணம் நிறைந்த மருத்துவ மூலிகை; கிருமி எதிர்ப்பு மற்றும் அழற்சி குறைக்கும் தன்மை கொண்டது.",
        "kn":
            "ಜೆರಾನಿಯಂ ಸುಗಂಧ ಔಷಧೀಯ ಸಸ್ಯವಾಗಿದ್ದು ಬ್ಯಾಕ್ಟೀರಿಯಾ ವಿರೋಧಿ ಗುಣ ಹೊಂದಿದೆ.",
      },
      "uses": {
        "en":
            "Geranium oil is widely used in skin care to reduce acne, scars and excess oil production. It helps soothe eczema, minor wounds and insect bites. In aromatherapy it relieves anxiety, stress, mood swings and menstrual discomfort. The fragrance also acts as a natural mosquito repellent and improves relaxation and sleep quality.",
        "hi": "त्वचा देखभाल, घाव भरने, तनाव कम करने और कीट भगाने में उपयोगी।",
        "te":
            "చర్మ సంరక్షణ, గాయాలు, ఒత్తిడి తగ్గింపు మరియు దోమల నివారణలో ఉపయోగం.",
        "ta":
            "தோல் பராமரிப்பு, மனஅழுத்தம் குறைப்பு மற்றும் கொசு விரட்ட பயன்படும்.",
        "kn": "ಚರ್ಮ ಆರೈಕೆ, ಒತ್ತಡ ನಿವಾರಣೆ ಮತ್ತು ಕೀಟ ನಿವಾರಣೆಗೆ ಉಪಯುಕ್ತ.",
      },
      "more_info": {
        "en":
            "Geranium essential oil is commonly blended in cosmetics, soaps and perfumes due to its floral scent and preservative qualities. In traditional medicine it is believed to balance hormones and support women's health. The plant is also cultivated ornamentally and used in herbal steam inhalation to ease breathing discomfort.",
        "hi":
            "सौंदर्य प्रसाधन और इत्र में व्यापक उपयोग तथा हार्मोन संतुलन में सहायक माना जाता है।",
        "te":
            "సుగంధ ద్రవ్యాలు మరియు కాస్మెటిక్స్‌లో విస్తృత ఉపయోగం, హార్మోన్ సమతుల్యం కోసం ఉపయోగిస్తారు.",
        "ta": "அழகு சாதனங்கள் மற்றும் வாசனைத் திரவியங்களில் பயன்படுகிறது.",
        "kn": "ಸುಗಂಧ ದ್ರವ್ಯ ಮತ್ತು ಅಲಂಕಾರಿಕ ಬಳಕೆಗಳಲ್ಲಿ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Pelargonium graveolens",
        "hi": "पेलार्गोनियम ग्रेविओलेंस",
        "te": "పెలార్గోనియం గ్రావియోలెన్స్",
        "ta": "பெலார்கோனியம் கிரேவியோலென்ஸ்",
        "kn": "ಪೆಲಾರ್ಗೋನಿಯಂ ಗ್ರೇವಿಯೋಲೆನ್ಸ್",
      },
      "local_names": {
        "en":
            "Telugu: Jeriniyam, Hindi: Geranium, Tamil: Geranium, Kannada: Geranium",
        "hi":
            "तेलुगु: जेरैनियम, हिंदी: जेरैनियम, तमिल: ஜெரானியம், कन्नड़: ಜೆರಾನಿಯಂ",

        "te":
            "తెలుగు: జెరేనియం, హిందీ: जेरैनियम, తమిళం: ஜெரானியம், కన్నಡ: ಜೆರಾನಿಯಂ",

        "ta":
            "தெலுங்கு: ஜெரேனியம், இந்தி: जेरैनियम, தமிழ்: ஜெரானியம், கன்னಡ: ಜೆರಾನಿಯಂ",

        "kn":
            "ತೆಲುಗು: ಜೆರೇನಿಯಂ, ಹಿಂದಿ: जेरैनियम, ತಮಿಳು: ஜெரானியம், ಕನ್ನಡ: ಜೆರಾನಿಯಂ",
      },
      "side_effects": {
        "en":
            "Concentrated essential oil may cause skin irritation or redness in sensitive individuals. Excess inhalation may trigger headache or nausea in some people. Pregnant women should use cautiously due to possible hormonal effects.",
        "hi": "अधिक उपयोग से त्वचा जलन या सिरदर्द हो सकता है।",
        "te": "అధికంగా వాడితే చర్మ దురద లేదా తలనొప్పి రావచ్చు.",
        "ta": "அதிகம் பயன்படுத்தினால் தோல் எரிச்சல் அல்லது தலைவலி ஏற்படலாம்.",
        "kn": "ಹೆಚ್ಚು ಬಳಕೆ ಚರ್ಮ ಉರಿಯೂತ ಅಥವಾ ತಲೆನೋವು ಉಂಟುಮಾಡಬಹುದು.",
      },
    },
    "Henna": {
      "name": {
        "en": "Henna",
        "hi": "मेहंदी",
        "te": "గోరింట",
        "ta": "மருதாணி",
        "kn": "ಮೆಹೆಂದಿ",
      },
      "description": {
        "en":
            "Henna is a small shrub traditionally valued for its cooling, healing, and coloring properties. It has been used for centuries in tropical regions for medicinal, cosmetic, and cultural purposes, especially in skin and hair care.",
        "hi":
            "मेहंदी एक झाड़ीदार पौधा है जो अपने ठंडक देने वाले, औषधीय और रंग देने वाले गुणों के लिए प्रसिद्ध है। इसका उपयोग सदियों से औषधि और सौंदर्य के लिए किया जाता रहा है।",
        "te":
            "గోరింట ఒక చిన్న పొద మొక్క. ఇది చల్లదనం, ఔషధ గుణాలు మరియు రంగు లక్షణాల వల్ల ప్రాచీనకాలం నుంచే వాడుతున్నారు.",
        "ta":
            "மருதாணி ஒரு புதர் தாவரம். இதன் குளிர்ச்சியும் மருத்துவ குணங்களும் அழகு பயன்பாடுகளும் பழமையானவை.",
        "kn":
            "ಮೆಹೆಂದಿ ಒಂದು ಪೊದೆ ಸಸ್ಯವಾಗಿದ್ದು, ತಂಪು ನೀಡುವ ಮತ್ತು ಔಷಧೀಯ ಗುಣಗಳಿಗೆ ಪ್ರಸಿದ್ಧವಾಗಿದೆ.",
      },
      "uses": {
        "en":
            "Used to condition hair, strengthen hair roots, cool the body, heal minor skin wounds, and decorate hands and feet during cultural and religious occasions.",
        "hi":
            "बालों को मजबूत करने, शरीर को ठंडक देने, त्वचा के घाव भरने और सजावट के लिए उपयोग होता है।",
        "te":
            "జుట్టు బలపరచడానికి, శరీరానికి చల్లదనం ఇవ్వడానికి మరియు పండుగలలో అలంకరణకు ఉపయోగిస్తారు.",
        "ta":
            "முடி பராமரிப்பு, உடல் குளிர்ச்சி மற்றும் விழா அலங்காரத்திற்கு பயன்படுகிறது.",
        "kn":
            "ಕೂದಲು ಬಲಪಡಿಸಲು, ದೇಹ ತಂಪಾಗಿಸಲು ಮತ್ತು ಹಬ್ಬಗಳ ಅಲಂಕಾರಕ್ಕೆ ಬಳಸುತ್ತಾರೆ.",
      },
      "more_info": {
        "en":
            "Henna leaves contain a natural pigment called lawsone, which binds to keratin in skin and hair to produce a reddish-brown stain. It is widely used in Ayurveda and traditional home remedies for its antifungal and antibacterial properties.",
        "hi":
            "मेहंदी की पत्तियों में लॉसोन नामक प्राकृतिक रंग होता है जो त्वचा और बालों को रंग देता है। आयुर्वेद में इसके जीवाणुरोधी गुणों का वर्णन है।",
        "te":
            "గోరింట ఆకుల్లో లాసోన్ అనే సహజ వర్ణద్రవ్యం ఉంటుంది. ఇది చర్మం మరియు జుట్టుకు రంగు ఇస్తుంది.",
        "ta":
            "மருதாணி இலைகளில் லாசோன் என்ற இயற்கை நிறம் உள்ளது; இது தோல் மற்றும் முடிக்கு நிறமளிக்கிறது.",
        "kn":
            "ಮೆಹೆಂದಿ ಎಲೆಗಳಲ್ಲಿ ಲಾಸೋನ್ ಎಂಬ ನೈಸರ್ಗಿಕ ಬಣ್ಣವಿದ್ದು, ಚರ್ಮ ಮತ್ತು ಕೂದಲಿಗೆ ಬಣ್ಣ ನೀಡುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Lawsonia inermis",
        "hi": "लॉसोनिया इनर्मिस",
        "te": "లాసోనియా ఇనెర్మిస్",
        "ta": "லாஸோனியா இனெர்மிஸ்",
        "kn": "ಲಾಸೋನಿಯಾ ಇನರ್ಮಿಸ್",
      },
      "local_names": {
        "en":
            "Hindi: Mehndi, Telugu: Gorinta, Tamil: Maruthani, Kannada: Mehendi",
        "hi": "तेलुगु: गोरिंटा, हिंदी: मेहंदी, तमिल: மருதாணி, कन्नड़: ಮೆಹೆಂದಿ",

        "te": "తెలుగు: గోరింట, హిందీ: मेहंदी, తమిళం: மருதாணி, కన్నಡ: ಮೆಹೆಂದಿ",

        "ta":
            "தெலுங்கு: கோரிண்ட, இந்தி: मेहंदी, தமிழ்: மருதாணி, கன்னಡ: ಮೆಹೆಂದಿ",

        "kn": "ತೆಲುಗು: ಗೋರಿಂಟ, ಹಿಂದಿ: मेहंदी, ತಮಿಳು: மருதாணி, ಕನ್ನಡ: ಮೆಹೆಂದಿ",
      },
      "side_effects": {
        "en":
            "Some individuals may experience allergic skin reactions, especially with adulterated or chemical-based henna. A patch test is recommended before use, and natural henna is considered safer.",
        "hi":
            "कुछ लोगों में त्वचा एलर्जी हो सकती है, विशेषकर रासायनिक मेहंदी से। उपयोग से पहले परीक्षण करना चाहिए।",
        "te":
            "కెమికల్ కలిపిన గోరింట వాడితే చర్మ అలర్జీ రావచ్చు. ముందుగా పరీక్ష చేయడం మంచిది.",
        "ta": "இயற்கையற்ற மருதாணி பயன்படுத்தினால் தோல் அலர்ஜி ஏற்படலாம்.",
        "kn": "ರಾಸಾಯನಿಕ ಮಿಶ್ರಿತ ಮೆಹೆಂದಿಯಿಂದ ಚರ್ಮ ಅಲರ್ಜಿ ಸಂಭವಿಸಬಹುದು.",
      },
    },

    "Hibiscus": {
      "name": {
        "en": "Hibiscus",
        "hi": "गुड़हल",
        "te": "మందారం",
        "ta": "செம்பருத்தி",
        "kn": "ದಾಸವಾಳ",
      },
      "description": {
        "en":
            "Hibiscus (Hibiscus rosa-sinensis) is a tropical flowering medicinal plant widely used in Ayurveda and traditional medicine. Its flowers and leaves contain anthocyanins, flavonoids, vitamin C and natural acids that provide antioxidant, cooling and anti-inflammatory effects. The plant is especially valued for supporting cardiovascular health, skin nourishment and hair strengthening properties.",
        "hi":
            "गुड़हल एक उष्णकटिबंधीय औषधीय पौधा है जिसमें एंथोसायनिन, फ्लेवोनोइड और विटामिन C होते हैं जो एंटीऑक्सीडेंट और शीतल प्रभाव देते हैं।",
        "te":
            "మందారం ఒక ఉష్ణమండల ఔషధ మొక్క. ఇందులో యాంటోసైనిన్లు, ఫ్లేవనాయిడ్లు మరియు విటమిన్ C ఉండి శరీరానికి చల్లదనం మరియు రక్షణ ఇస్తుంది.",
        "ta":
            "செம்பருத்தி ஒரு மருத்துவ மலர்; இதில் ஆன்டி-ஆக்ஸிடென்ட் மற்றும் குளிர்ச்சி தரும் தன்மைகள் உள்ளன.",
        "kn": "ದಾಸವಾಳ ಉಷ್ಣವಲಯದ ಔಷಧೀಯ ಸಸ್ಯವಾಗಿದ್ದು ಆಂಟಿಆಕ್ಸಿಡೆಂಟ್ ಗುಣ ಹೊಂದಿದೆ.",
      },
      "uses": {
        "en":
            "Promotes hair growth, prevents dandruff and premature greying, supports heart health by helping regulate blood pressure and cholesterol, aids digestion and improves skin hydration. Hibiscus tea is consumed to cool the body and reduce fatigue.",
        "hi":
            "बालों की वृद्धि, रूसी नियंत्रण, हृदय स्वास्थ्य और पाचन में सहायक।",
        "te":
            "జుట్టు పెరుగుదల, చుండ్రు తగ్గింపు, గుండె ఆరోగ్యం మరియు జీర్ణక్రియకు ఉపయోగకరం.",
        "ta": "முடி வளர்ச்சி, இதய ஆரோக்கியம் மற்றும் செரிமானத்திற்கு உதவும்.",
        "kn": "ಕೂದಲು ಬೆಳವಣಿಗೆ, ಹೃದಯ ಆರೋಗ್ಯ ಮತ್ತು ಜೀರ್ಣಕ್ರಿಯೆಗೆ ಉಪಯುಕ್ತ.",
      },
      "more_info": {
        "en":
            "Flowers are commonly dried to prepare herbal tea and natural hair oil. In traditional remedies it is used as a natural conditioner and scalp coolant. The plant is also grown ornamentally in homes and temples and is associated with worship rituals in many cultures.",
        "hi": "हर्बल चाय, बाल तेल और पूजा में उपयोग होता है।",
        "te": "హెర్బల్ టీ, జుట్టు నూనె మరియు పూజల్లో ఉపయోగిస్తారు.",
        "ta": "மூலிகை தேநீர் மற்றும் முடி எண்ணெயில் பயன்படுத்தப்படுகிறது.",
        "kn": "ಹರ್ಬಲ್ ಟೀ ಮತ್ತು ಕೂದಲು ಎಣ್ಣೆಯಲ್ಲಿ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Hibiscus rosa-sinensis",
        "hi": "हिबिस्कस रोसा सिनेन्सिस",
        "te": "హిబిస్కస్ రోజా సైనెన్సిస్",
        "ta": "ஹிபிஸ்கஸ் ரோசா சினென்சிஸ்",
        "kn": "ಹಿಬಿಸ್ಕಸ್ ರೋಸಾ ಸಿನೆನ್ಸಿಸ್",
      },
      "local_names": {
        "en":
            "Telugu: Mandaram, Hindi: Gudhal, Tamil: Sembaruthi, Kannada: Dasavala",

        "hi":
            "तेलुगु: मंदारम, हिंदी: गुड़हल, तमिल: செம்பருத்தி, कन्नड़: ದಾಸವಾಳ",

        "te":
            "తెలుగు: మందారం, హిందీ: गुड़हल, తమిళం: செம்பருத்தி, కన్నಡ: ದಾಸವಾಳ",

        "ta":
            "தெலுங்கு: மந்தாரம், இந்தி: गुड़हल, தமிழ்: செம்பருத்தி, கன்னಡ: ದಾಸವಾಳ",

        "kn":
            "ತೆಲುಗು: ಮಂದಾರಂ, ಹಿಂದಿ: गुड़हल, ತಮಿಳು: செம்பருத்தி, ಕನ್ನಡ: ದಾಸವಾಳ",
      },
      "side_effects": {
        "en":
            "Excess consumption may lower blood pressure too much and may interact with diabetes or antihypertensive medicines. Some individuals may experience mild stomach upset or dizziness when taken in large quantities.",
        "hi":
            "अधिक सेवन से रक्तचाप अधिक कम हो सकता है और कुछ दवाओं के साथ प्रभाव बदल सकता है।",
        "te":
            "అధికంగా తీసుకుంటే రక్తపోటు ఎక్కువగా తగ్గవచ్చు మరియు కొన్ని మందులతో ప్రభావం మారవచ్చు.",
        "ta": "அதிகம் எடுத்தால் ரத்த அழுத்தம் குறைந்து மயக்கம் ஏற்படலாம்.",
        "kn": "ಹೆಚ್ಚು ಸೇವನೆ ರಕ್ತದ ಒತ್ತಡ ಕಡಿಮೆ ಮಾಡಬಹುದು.",
      },
    },
    "Honge": {
      "name": {
        "en": "Honge (Indian Beech)",
        "hi": "करंज",
        "te": "కనుగ",
        "ta": "புங்கம்",
        "kn": "ಹೊಂಗೆ",
      },
      "description": {
        "en":
            "Honge is a medium-sized evergreen tree commonly found in India. It is well known for its strong medicinal value, especially its antibacterial, antifungal, and anti-inflammatory properties. Almost all parts of the tree are used in traditional medicine.",
        "hi":
            "करंज भारत में पाया जाने वाला एक सदाबहार औषधीय वृक्ष है। इसमें जीवाणुरोधी, फंगलरोधी और सूजन कम करने वाले गुण होते हैं।",
        "te":
            "కనుగ మధ్యస్థ పరిమాణం గల శాశ్వత పచ్చని చెట్టు. దీనిలో యాంటీబ్యాక్టీరియల్ మరియు వాపు తగ్గించే గుణాలు ఉన్నాయి.",
        "ta":
            "புங்கம் இந்தியாவில் காணப்படும் நடுத்தர அளவுள்ள மரம். இதில் கிருமி எதிர்ப்பு மற்றும் அழற்சி குறைக்கும் தன்மைகள் உள்ளன.",
        "kn":
            "ಹೊಂಗೆ ಮಧ್ಯಮ ಗಾತ್ರದ ಸದಾಕಾಲ ಹಸಿರು ಮರವಾಗಿದ್ದು, ಔಷಧೀಯ ಗುಣಗಳಲ್ಲಿ ಸಮೃದ್ಧವಾಗಿದೆ.",
      },
      "uses": {
        "en":
            "Used in traditional medicine to treat skin diseases, wounds, ulcers, itching, and joint pain. The leaves and bark are also applied externally for inflammation and infections.",
        "hi":
            "त्वचा रोग, घाव, खुजली और जोड़ों के दर्द के उपचार में उपयोग किया जाता है।",
        "te":
            "చర్మ రోగాలు, గాయాలు, దురద మరియు సంధి నొప్పుల చికిత్సలో ఉపయోగిస్తారు.",
        "ta":
            "தோல் நோய்கள், காயங்கள், அரிப்பு மற்றும் மூட்டு வலிக்கு பயன்படுத்தப்படுகிறது.",
        "kn": "ಚರ್ಮ ರೋಗ, ಗಾಯಗಳು, ಕೊರೆತ ಮತ್ತು ಸಂಧಿ ನೋವಿಗೆ ಬಳಸುತ್ತಾರೆ.",
      },
      "more_info": {
        "en":
            "Oil extracted from the seeds, commonly known as karanja oil, is widely used in Ayurveda and folk medicine. The tree is also valued for soil improvement and is used in sustainable agriculture and biofuel production.",
        "hi":
            "बीजों से प्राप्त करंज तेल आयुर्वेद में प्रसिद्ध है। यह वृक्ष मिट्टी की उर्वरता बढ़ाने में भी सहायक है।",
        "te":
            "కనుగ గింజల నుండి వచ్చే నూనె ఆయుర్వేదంలో విస్తృతంగా వాడతారు. ఇది మట్టిని సారవంతం చేయడంలో కూడా ఉపయోగపడుతుంది.",
        "ta":
            "புங்கம் விதை எண்ணெய் ஆயுர்வேதத்தில் முக்கியமானது. இது மண்ணின் தரத்தை மேம்படுத்தவும் உதவுகிறது.",
        "kn":
            "ಹೊಂಗೆ ಬೀಜ ಎಣ್ಣೆಯನ್ನು ಆಯುರ್ವೇದದಲ್ಲಿ ವ್ಯಾಪಕವಾಗಿ ಬಳಸುತ್ತಾರೆ. ಇದು ಮಣ್ಣಿನ ಉರ್ವರತೆಯನ್ನು ಹೆಚ್ಚಿಸುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Pongamia pinnata",
        "hi": "पोंगामिया पिन्नाटा",
        "te": "పోంగామియా పిన్నాటా",
        "ta": "பொங்காமியா பின்னாட்டா",
        "kn": "ಪೊಂಗಾಮಿಯಾ ಪಿನ್ನಾಟಾ",
      },
      "local_names": {
        "en": "Hindi: Karanj, Telugu: Kanuga, Tamil: Pungam, Kannada: Honge",

        "hi": "तेलुगु: कनुग, हिंदी: करंज, तमिल: புங்கம், कन्नड़: ಹೊಂಗೆ",

        "te": "తెలుగు: కనుగ, హిందీ: करंज, తమిళం: புங்கம், కన్నಡ: ಹೊಂಗೆ",

        "ta": "தெலுங்கு: கனுக, இந்தி: करंज, தமிழ்: புங்கம், கன்னಡ: ಹೊಂಗೆ",

        "kn": "ತೆಲುಗು: ಕನುಗ, ಹಿಂದಿ: करंज, ತಮಿಳು: புங்கம், ಕನ್ನಡ: ಹೊಂಗೆ",
      },
      "side_effects": {
        "en":
            "Internal consumption of seed oil without medical supervision may cause nausea, vomiting, or digestive discomfort. External use is generally considered safe when used in moderation.",
        "hi":
            "बिना चिकित्सकीय सलाह के तेल का सेवन मतली या उल्टी का कारण बन सकता है।",
        "te":
            "వైద్య సలహా లేకుండా నూనెను తాగితే వాంతులు లేదా జీర్ణ సమస్యలు రావచ్చు.",
        "ta":
            "மருத்துவ ஆலோசனை இல்லாமல் எண்ணெய் உட்கொண்டால் வாந்தி அல்லது ஜீரண சிக்கல்கள் ஏற்படலாம்.",
        "kn":
            "ವೈದ್ಯ ಸಲಹೆಯಿಲ್ಲದೆ ಬೀಜ ಎಣ್ಣೆ ಸೇವಿಸಿದರೆ ಓಕರಿ ಅಥವಾ ಜೀರ್ಣ ಸಮಸ್ಯೆಗಳು ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Insulin": {
      "name": {
        "en": "Insulin Plant",
        "hi": "इंसुलिन पौधा",
        "te": "ఇన్సులిన్ మొక్క",
        "ta": "இன்சுலின் செடி",
        "kn": "ಇನ್ಸುಲಿನ್ ಗಿಡ",
      },
      "description": {
        "en":
            "Insulin Plant (Costus igneus) is a tropical medicinal herb known for its natural blood sugar regulating properties. The leaves contain corosolic acid, flavonoids, terpenoids and antioxidant compounds that help improve glucose metabolism and pancreatic function. It is widely used in traditional Ayurvedic and folk medicine for supporting diabetes management and metabolic balance.",
        "hi":
            "इंसुलिन पौधा एक उष्णकटिबंधीय औषधीय जड़ी है जिसमें कोरोसोलिक एसिड और एंटीऑक्सीडेंट होते हैं जो रक्त शर्करा नियंत्रण में सहायक होते हैं।",
        "te":
            "ఇన్సులిన్ మొక్క ఉష్ణమండల ఔషధ మొక్క. ఇందులో కొరోసోలిక్ యాసిడ్ మరియు యాంటీఆక్సిడెంట్లు ఉండి రక్తంలో చక్కెర నియంత్రణకు సహాయపడుతుంది.",
        "ta":
            "இன்சுலின் செடி இரத்த சர்க்கரையை கட்டுப்படுத்த உதவும் மருத்துவ மூலிகை.",
        "kn": "ಇನ್ಸುಲಿನ್ ಗಿಡ ರಕ್ತದ ಸಕ್ಕರೆ ನಿಯಂತ್ರಣಕ್ಕೆ ಸಹಾಯಕವಾದ ಔಷಧೀಯ ಸಸ್ಯ.",
      },
      "uses": {
        "en":
            "Supports diabetes control, improves insulin sensitivity, aids metabolism and digestion, and helps reduce fatigue associated with high blood sugar. Regular intake is traditionally believed to help maintain steady glucose levels and improve energy balance.",
        "hi": "मधुमेह नियंत्रण, इंसुलिन संवेदनशीलता और पाचन सुधार में उपयोगी।",
        "te":
            "మధుమేహ నియంత్రణ, ఇన్సులిన్ స్పందన మెరుగుదల మరియు జీర్ణక్రియకు సహాయపడుతుంది.",
        "ta": "சர்க்கரை நோய் கட்டுப்பாடு மற்றும் உடல் சக்தி மேம்பாடு.",
        "kn": "ಮಧುಮೇಹ ನಿಯಂತ್ರಣ ಮತ್ತು ಶಕ್ತಿ ಹೆಚ್ಚಿಸಲು ಸಹಾಯಕ.",
      },
      "more_info": {
        "en":
            "Leaves are usually chewed fresh in the morning or dried and consumed as powder or herbal tea. The plant grows well in warm humid climates and is commonly cultivated in home gardens as a natural supportive remedy for long-term glucose management.",
        "hi":
            "पत्तियां सुबह चबाई जाती हैं या चूर्ण और चाय के रूप में उपयोग होती हैं।",
        "te": "ఆకులను ఉదయం నమిలి లేదా పొడి, టీ రూపంలో వాడతారు.",
        "ta": "இலைகளை நேரடியாக அல்லது பொடியாக உட்கொள்கிறார்கள்.",
        "kn": "ಎಲೆಗಳನ್ನು ನೇರವಾಗಿ ಅಥವಾ ಪುಡಿಯಾಗಿ ಸೇವಿಸುತ್ತಾರೆ.",
      },
      "scientific_name": {
        "en": "Costus igneus",
        "hi": "कोस्टस इग्नियस",
        "te": "కోస్టస్ ఇగ్నియస్",
        "ta": "கோஸ்டஸ் இக்னியஸ்",
        "kn": "ಕೋಸ್ಟಸ್ ಇಗ್ನಿಯಸ್",
      },
      "local_names": {
        "en":
            "Telugu: Insulin mokka, Hindi: Insulin plant, Kannada: Insulin gida, Tamil: Insulin chedi",
        "hi": "इंसुलिन पौधा",
        "hi":
            "तेलुगु: इंसुलिन मोक्कु, हिंदी: इंसुलिन पौधा, तमिल: இன்சுலின் செடி, कन्नड़: ಇನ್ಸುಲಿನ್ ಗಿಡ",

        "te":
            "తెలుగు: ఇన్సులిన్ మొక్క, హిందీ: इंसुलिन पौधा, తమిళం: இன்சுலின் செடி, కన్నಡ: ಇನ್ಸುಲಿನ್ ಗಿಡ",

        "ta":
            "தெலுங்கு: இன்சுலின் மொக்கு, இந்தி: इंसुलिन पौधा, தமிழ்: இன்சுலின் செடி, கன்னಡ: ಇನ್ಸುಲಿನ್ ಗಿಡ",

        "kn":
            "ತೆಲುಗು: ಇನ್ಸುಲಿನ್ ಮೊಕ್ಕು, ಹಿಂದಿ: इंसुलिन पौधा, ತಮಿಳು: இன்சுலின் செடி, ಕನ್ನಡ: ಇನ್ಸುಲಿನ್ ಗಿಡ",
      },
      "side_effects": {
        "en":
            "Excess intake may cause hypoglycemia leading to dizziness, weakness or sweating, especially in people taking antidiabetic medicines. It should be consumed in moderation and with medical guidance for diabetic patients.",
        "hi": "अधिक सेवन से शुगर बहुत कम होकर चक्कर या कमजोरी हो सकती है।",
        "te":
            "అధికంగా తీసుకుంటే చక్కెర చాలా తగ్గి తల తిరుగుడు లేదా బలహీనత కలగవచ్చు.",
        "ta": "அதிகம் எடுத்தால் மயக்கம் அல்லது பலவீனம் ஏற்படலாம்.",
        "kn": "ಹೆಚ್ಚು ಸೇವನೆ ತಲೆ ಸುತ್ತು ಅಥವಾ ದುರ್ಬಲತೆ ಉಂಟುಮಾಡಬಹುದು.",
      },
    },

    "Jasmine": {
      "name": {
        "en": "Jasmine",
        "hi": "मोगरा",
        "te": "మల్లి",
        "ta": "மல்லிகை",
        "kn": "ಮಲ್ಲಿಗೆ",
      },
      "description": {
        "en":
            "Jasmine is a fragrant flowering plant widely cultivated for its beautiful white blossoms and soothing aroma. It is valued for its calming, mood-enhancing, and mild therapeutic properties and is commonly grown in gardens and farms across tropical regions.",
        "hi":
            "मोगरा एक सुगंधित फूलों वाला पौधा है, जो अपनी मन को शांत करने वाली खुशबू और औषधीय गुणों के लिए प्रसिद्ध है।",
        "te":
            "మల్లి సువాసన గల పుష్ప మొక్క. దీని సుగంధం మనసును ప్రశాంతంగా ఉంచుతుంది మరియు ఔషధ గుణాలు కలిగి ఉంటుంది.",
        "ta":
            "மல்லிகை மணமிக்க மலர்ச்செடி. இதன் வாசனை மனதை அமைதியாக்கும் தன்மை கொண்டது.",
        "kn": "ಮಲ್ಲಿಗೆ ಸುಗಂಧಭರಿತ ಹೂವಿನ ಸಸ್ಯವಾಗಿದ್ದು, ಮನಸ್ಸಿಗೆ ಶಾಂತಿ ನೀಡುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Used to reduce stress, promote relaxation, improve sleep quality, and uplift mood. Jasmine flowers are also used for hair adornment, garlands, and mild skin care preparations.",
        "hi":
            "तनाव कम करने, नींद में सुधार, मन को शांत करने और बालों की सजावट में उपयोग होता है।",
        "te":
            "ఒత్తిడి తగ్గించడానికి, నిద్ర మెరుగుపరచడానికి మరియు జుట్టు అలంకరణకు ఉపయోగిస్తారు.",
        "ta":
            "மன அழுத்தம் குறைக்க, தூக்கத்தை மேம்படுத்த மற்றும் முடி அலங்காரத்திற்கு பயன்படுகிறது.",
        "kn":
            "ಒತ್ತಡ ಕಡಿಮೆ ಮಾಡಲು, ನಿದ್ರೆ ಸುಧಾರಿಸಲು ಮತ್ತು ಕೂದಲು ಅಲಂಕಾರಕ್ಕೆ ಬಳಸುತ್ತಾರೆ.",
      },
      "more_info": {
        "en":
            "Jasmine flowers are widely used in perfumes, essential oils, and religious rituals. In traditional medicine, jasmine-infused oils are used for massage and relaxation due to their soothing aroma.",
        "hi": "मोगरा इत्र, तेल और पूजा-पाठ में व्यापक रूप से उपयोग होता है।",
        "te":
            "మల్లి పువ్వులు సువాసన ద్రవ్యాలు, తైలాలు మరియు పూజల్లో విస్తృతంగా వాడతారు.",
        "ta":
            "மல்லிகை மலர்கள் வாசனைப் பொருட்கள், எண்ணெய்கள் மற்றும் பூஜைகளில் பயன்படுத்தப்படுகின்றன.",
        "kn":
            "ಮಲ್ಲಿಗೆ ಹೂಗಳನ್ನು ಸುಗಂಧ ದ್ರವ್ಯ, ಎಣ್ಣೆ ಮತ್ತು ಪೂಜೆಯಲ್ಲಿ ಬಳಸುತ್ತಾರೆ.",
      },
      "scientific_name": {
        "en": "Jasminum sambac",
        "hi": "जैस्मिनम सम्बक",
        "te": "జాస్మినమ్ సాంబాక్",
        "ta": "ஜாஸ்மினம் சம்பாக்",
        "kn": "ಜಾಸ್ಮಿನಮ್ ಸಂಬಾಕ್",
      },
      "local_names": {
        "en": "Hindi: Mogra, Telugu: Malli, Tamil: Malligai, Kannada: Mallige",
        "hi": "तेलुगु: मल्लि, हिंदी: मोगरा, तमिल: மல்லிகை, कन्नड़: ಮಲ್ಲಿಗೆ",

        "te": "తెలుగు: మల్లి, హిందీ: मोगरा, తమిళం: மல்லிகை, కన్నಡ: ಮಲ್ಲಿಗೆ",

        "ta": "தெலுங்கு: மல்லி, இந்தி: मोगरा, தமிழ்: மல்லிகை, கன்னಡ: ಮಲ್ಲಿಗೆ",

        "kn": "ತೆಲುಗು: ಮಲ್ಲಿ, ಹಿಂದಿ: मोगरा, ತಮಿಳು: மல்லிகை, ಕನ್ನಡ: ಮಲ್ಲಿಗೆ",
      },
      "side_effects": {
        "en":
            "Strong or prolonged exposure to jasmine fragrance may trigger headaches, nausea, or allergies in sensitive individuals. Moderate use is generally safe.",
        "hi":
            "तेज या लंबे समय तक सुगंध से संवेदनशील लोगों में सिरदर्द या एलर्जी हो सकती है।",
        "te":
            "తీవ్రంగా లేదా ఎక్కువసేపు వాసన పీల్చితే కొందరిలో తలనొప్పి లేదా అలర్జీ రావచ్చు.",
        "ta":
            "அதிக நேரம் மணத்தை உணர்ந்தால் சிலருக்கு தலைவலி அல்லது அலர்ஜி ஏற்படலாம்.",
        "kn":
            "ತೀವ್ರ ವಾಸನೆಗೆ ದೀರ್ಘಕಾಲ ಒಡ್ಡಿದರೆ ಕೆಲವರಿಗೆ ತಲೆನೋವು ಅಥವಾ ಅಲರ್ಜಿ ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Lemon": {
      "name": {
        "en": "Lemon",
        "hi": "नींबू",
        "te": "నిమ్మకాయ",
        "ta": "எலுமிச்சை",
        "kn": "ನಿಂಬೆಹಣ್ಣು",
      },
      "description": {
        "en":
            "Lemon (Citrus limon) is a citrus fruit widely valued for its high vitamin C, citric acid and antioxidant content. It has antibacterial, detoxifying and alkalizing effects on the body and is commonly used in Ayurveda and natural remedies to support digestion, skin health and immunity.",
        "hi":
            "नींबू (Citrus limon) विटामिन C, साइट्रिक एसिड और एंटीऑक्सीडेंट से भरपूर खट्टा फल है जो शरीर को शुद्ध करने, पाचन सुधारने और प्रतिरक्षा बढ़ाने में सहायक होता है।",
        "te":
            "నిమ్మకాయ (Citrus limon) విటమిన్ C, సిట్రిక్ యాసిడ్ మరియు యాంటీఆక్సిడెంట్లు అధికంగా ఉన్న పండు. ఇది శరీరాన్ని శుద్ధి చేయడం, జీర్ణక్రియ మెరుగుపరచడం మరియు రోగనిరోధక శక్తి పెంచడంలో సహాయపడుతుంది.",
        "ta":
            "எலுமிச்சை (Citrus limon) வைட்டமின் C மற்றும் ஆன்டி-ஆக்ஸிடென்ட் நிறைந்த பழம். இது செரிமானம், தோல் ஆரோக்கியம் மற்றும் நோய் எதிர்ப்பு சக்தியை மேம்படுத்த உதவுகிறது.",
        "kn":
            "ನಿಂಬೆಹಣ್ಣು (Citrus limon) ವಿಟಮಿನ್ C ಮತ್ತು ಆಂಟಿಆಕ್ಸಿಡೆಂಟ್‌ಗಳಿಂದ ಸಮೃದ್ಧವಾಗಿದ್ದು ಜೀರ್ಣಕ್ರಿಯೆ ಮತ್ತು ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿಗೆ ಸಹಾಯಕ.",
      },
      "uses": {
        "en":
            "Boosts immunity, aids digestion, supports weight management, improves skin glow, relieves sore throat and helps hydration. Lemon water is commonly consumed to detoxify the body and improve metabolism.",
        "hi":
            "प्रतिरक्षा बढ़ाता, पाचन सुधारता, वजन नियंत्रण में मदद करता और त्वचा चमक बढ़ाता है। गले की खराश में भी उपयोगी।",
        "te":
            "రోగనిరోధక శక్తి పెంచుతుంది, జీర్ణక్రియ మెరుగుపరుస్తుంది, బరువు నియంత్రణలో సహాయపడుతుంది మరియు చర్మ కాంతిని పెంచుతుంది. గొంతు నొప్పిలో ఉపయోగకరం.",
        "ta":
            "நோய் எதிர்ப்பு சக்தி அதிகரித்து செரிமானம் மேம்படும், உடல் எடை கட்டுப்பாடு மற்றும் தோல் பிரகாசத்திற்கு உதவும்.",
        "kn":
            "ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿ ಹೆಚ್ಚಿಸಿ ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಿಸುತ್ತದೆ, ತೂಕ ನಿಯಂತ್ರಣ ಮತ್ತು ಚರ್ಮ ಕಾಂತಿ ಹೆಚ್ಚಿಸುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Used in beverages, pickles and cooking worldwide. The peel contains essential oils used in aromatherapy and cleaning products. In traditional remedies it is mixed with honey or warm water to relieve cold and fatigue.",
        "hi":
            "पेय, अचार और भोजन में व्यापक उपयोग. छिलके का तेल अरोमाथेरेपी और सफाई उत्पादों में भी प्रयोग होता है.",
        "te":
            "పానీయాలు, ఊరగాయలు మరియు వంటల్లో విస్తృతంగా వాడతారు. తొక్కలోని తైలాలు అరోమాథెరపీ మరియు శుభ్రపరిచే పదార్థాల్లో ఉపయోగిస్తారు.",
        "ta":
            "பானங்கள், ஊறுகாய் மற்றும் சமையலில் பயன்படும்; தோலில் உள்ள எண்ணெய் அரோமாதெரபியில் பயன்படுத்தப்படுகிறது.",
        "kn":
            "ಪಾನೀಯಗಳು, ಉಪ್ಪಿನಕಾಯಿ ಮತ್ತು ಅಡುಗೆಯಲ್ಲಿ ಬಳಕೆ; ಸಿಪ್ಪೆಯ ತೈಲ ಅರೋಮಾಥೆರಪಿಯಲ್ಲಿ ಉಪಯುಕ್ತ.",
      },
      "scientific_name": {
        "en": "Citrus limon",
        "hi": "सिट्रस लिमोन",
        "te": "సిట్రస్ లిమోన్",
        "ta": "சிட்ரஸ் லிமோன்",
        "kn": "ಸಿಟ್ರಸ್ ಲಿಮೋನ್",
      },
      "local_names": {
        "en":
            "Telugu: Nimmakaya, Hindi: Nimbu, Tamil: Elumichai, Kannada: Nimbehannu",

        "hi":
            "तेलुगु: निम्मकाय, हिंदी: नींबू, तमिल: எலுமிச்சை, कन्नड़: ನಿಂಬೆಹಣ್ಣು",

        "te":
            "తెలుగు: నిమ్మకాయ, హిందీ: नींबू, తమిళం: எலுமிச்சை, కన్నಡ: ನಿಂಬೆಹಣ್ಣು",

        "ta":
            "தெலுங்கு: நிம்மகாய, இந்தி: नींबू, தமிழ்: எலுமிச்சை, கன்னಡ: ನಿಂಬೆಹಣ್ಣು",

        "kn":
            "ತೆಲುಗು: ನಿಂಮಕಾಯ, ಹಿಂದಿ: नींबू, ತಮಿಳು: எலுமிச்சை, ಕನ್ನಡ: ನಿಂಬೆಹಣ್ಣು",
      },
      "side_effects": {
        "en":
            "Excess consumption may erode tooth enamel, cause acidity or stomach irritation. Direct application on sensitive skin may cause dryness or irritation due to citric acid.",
        "hi":
            "अधिक सेवन से दांतों की एनामेल क्षति, एसिडिटी या पेट में जलन हो सकती है। त्वचा पर लगाने से जलन हो सकती है।",
        "te":
            "అధికంగా తీసుకుంటే పళ్ల పైపొర దెబ్బతినడం, ఆమ్లత్వం లేదా కడుపు మంట కలగవచ్చు. చర్మంపై వేస్తే మంట కలగవచ్చు.",
        "ta":
            "அதிகம் எடுத்தால் பற்கள் சேதம், அமிலத்தன்மை அல்லது வயிற்று எரிச்சல் ஏற்படலாம்; தோலில் எரிச்சல் தரலாம்.",
        "kn":
            "ಹೆಚ್ಚು ಸೇವನೆ ಹಲ್ಲಿನ ಮೇಲ್ಚಿಪ್ಪು ಹಾನಿ, ಅಜೀರ್ಣ ಅಥವಾ ಹೊಟ್ಟೆ ಉರಿಯೂತ ಉಂಟುಮಾಡಬಹುದು.",
      },
    },

    "Lemon_grass": {
      "name": {
        "en": "Lemon Grass",
        "hi": "गंधत्रिणा",
        "te": "నిమ్మ గడ్డి",
        "ta": "வாசனை புல்",
        "kn": "ನಿಂಬೆ ಹುಲ್ಲು",
      },
      "description": {
        "en":
            "Lemon grass is a tall aromatic medicinal grass widely grown in tropical regions. It has a strong lemon-like fragrance and is rich in essential oils, making it valuable in traditional medicine, cooking, and wellness practices.",
        "hi":
            "लेमन ग्रास एक सुगंधित औषधीय घास है जो उष्णकटिबंधीय क्षेत्रों में उगाई जाती है। इसमें नींबू जैसी खुशबू होती है और यह औषधीय तेलों से भरपूर होती है।",
        "te":
            "నిమ్మ గడ్డి ఉష్ణమండల ప్రాంతాల్లో పెరిగే పొడవైన సుగంధ ఔషధ గడ్డి. దీనిలో నిమ్మ వాసన ఉండి ఔషధ తైలాలు అధికంగా ఉంటాయి.",
        "ta":
            "வாசனை புல் ஒரு உயரமான மணமிக்க மருத்துவ புல். இது வெப்பமண்டல பகுதிகளில் வளரும் மற்றும் எலுமிச்சை போன்ற வாசனை கொண்டது.",
        "kn":
            "ನಿಂಬೆ ಹುಲ್ಲು ಉಷ್ಣವಲಯ ಪ್ರದೇಶಗಳಲ್ಲಿ ಬೆಳೆಯುವ ಉದ್ದವಾದ ಸುಗಂಧ ಔಷಧೀಯ ಹುಲ್ಲು ಆಗಿದ್ದು, ನಿಂಬೆ ವಾಸನೆಯನ್ನು ಹೊಂದಿದೆ.",
      },
      "uses": {
        "en":
            "Helps improve digestion, reduce stress and anxiety, relieve cold and fever symptoms, support detoxification, and promote relaxation when consumed as tea or used as oil.",
        "hi":
            "पाचन सुधारता है, तनाव और चिंता कम करता है, सर्दी-बुखार में राहत देता है और शरीर को आराम पहुंचाता है।",
        "te":
            "జీర్ణక్రియ మెరుగుపరుస్తుంది, ఒత్తిడి తగ్గిస్తుంది, జలుబు మరియు జ్వర లక్షణాలను తగ్గిస్తుంది.",
        "ta":
            "செரிமானத்தை மேம்படுத்தும், மன அழுத்தத்தை குறைக்கும், சளி மற்றும் காய்ச்சலில் நிவாரணம் அளிக்கும்.",
        "kn":
            "ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಣೆ, ಒತ್ತಡ ಕಡಿತ, ಶೀತ ಮತ್ತು ಜ್ವರ ಲಕ್ಷಣ ನಿವಾರಣೆಗೆ ಸಹಕಾರಿ.",
      },
      "more_info": {
        "en":
            "Lemon grass is commonly used to prepare herbal tea, essential oil, and traditional remedies. Its oil has antibacterial and antifungal properties and is widely used in aromatherapy, massage, and natural insect repellents.",
        "hi":
            "लेमन ग्रास का उपयोग हर्बल चाय, आवश्यक तेल और घरेलू औषधियों में किया जाता है। इसका तेल जीवाणुरोधी गुणों के लिए जाना जाता है।",
        "te":
            "నిమ్మ గడ్డిని హెర్బల్ టీ, తైలాలు మరియు సంప్రదాయ వైద్యాలలో వాడతారు. దీనిలో బ్యాక్టీరియా మరియు ఫంగస్ నిరోధక గుణాలు ఉన్నాయి.",
        "ta":
            "வாசனை புல் மூலிகை தேநீர், எண்ணெய் மற்றும் பாரம்பரிய மருத்துவத்தில் பயன்படுகிறது. இதன் எண்ணெய் கிருமி எதிர்ப்பு தன்மை கொண்டது.",
        "kn":
            "ನಿಂಬೆ ಹುಲ್ಲನ್ನು ಹರ್ಬಲ್ ಟೀ, ಎಣ್ಣೆ ಮತ್ತು ಪರಂಪರাগত ಚಿಕಿತ್ಸೆಯಲ್ಲಿ ಬಳಸುತ್ತಾರೆ. ಇದಕ್ಕೆ ಬ್ಯಾಕ್ಟೀರಿಯಾ ವಿರೋಧಿ ಗುಣಗಳಿವೆ.",
      },
      "scientific_name": {
        "en": "Cymbopogon citratus",
        "hi": "सिम्बोपोगोन सिट्रेटस",
        "te": "సింబోపోగాన్ సిట్రాటస్",
        "ta": "சிம்போபோகன் சிட்ரேடஸ்",
        "kn": "ಸಿಂಬೋಪೋಗನ್ ಸಿಟ್ರೇಟಸ್",
      },
      "local_names": {
        "en":
            "Hindi: Gandhatrina, Telugu: Nimma Gaddi, Tamil: Vasanai Pullu, Kannada: Nimbe Hullu",
        "hi":
            "तेलुगु: निम्म गद्दी, हिंदी: गंधत्रिणा, तमिल: வாசனை புல், कन्नड़: ನಿಂಬೆ ಹುಲ್ಲು",

        "te":
            "తెలుగు: నిమ్మ గడ్డి, హిందీ: गंधत्रिणा, తమిళం: வாசனை புல், కన్నಡ: ನಿಂಬೆ ಹುಲ್ಲು",

        "ta":
            "தெலுங்கு: நிம்ம கడ్డి, இந்தி: गंधत्रिणा, தமிழ்: வாசனை புல், கன்னಡ: ನಿಂಬೆ ಹುಲ್ಲು",

        "kn":
            "ತೆಲುಗು: ನಿಂಮ ಗದ್ದಿ, ಹಿಂದಿ: गंधत्रिणा, ತಮಿಳು: வாசனை புல், ಕನ್ನಡ: ನಿಂಬೆ ಹುಲ್ಲು",
      },
      "side_effects": {
        "en":
            "Excessive consumption may cause dizziness, dry mouth, or stomach discomfort. Pregnant women and people with low blood pressure should use it cautiously.",
        "hi":
            "अधिक सेवन से चक्कर, मुंह सूखना या पेट में परेशानी हो सकती है। गर्भवती महिलाओं को सावधानी रखनी चाहिए।",
        "te":
            "అధికంగా వాడితే తల తిరుగుడు, నోరు ఎండిపోవడం లేదా కడుపు అసౌకర్యం కలగవచ్చు.",
        "ta":
            "அதிக அளவில் பயன்படுத்தினால் தலைசுற்றல் அல்லது வயிற்று 불편ம் ஏற்படலாம்.",
        "kn": "ಅತಿಯಾಗಿ ಸೇವಿಸಿದರೆ ತಲೆಸುತ್ತು ಅಥವಾ ಹೊಟ್ಟೆ ಅಸ್ವಸ್ಥತೆ ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Mango": {
      "name": {
        "en": "Mango",
        "hi": "आम",
        "te": "మామిడి",
        "ta": "மாம்பழம்",
        "kn": "ಮಾವು",
      },
      "description": {
        "en":
            "Mango (Mangifera indica) is a tropical fruit known as the 'King of Fruits'. It is rich in vitamins A, C, E, fiber and antioxidants that support eye health, digestion and immunity. In traditional medicine, different parts of the mango tree including leaves and bark are also used for therapeutic purposes.",
        "hi":
            "आम (Mangifera indica) को फलों का राजा कहा जाता है। यह विटामिन A, C, E, फाइबर और एंटीऑक्सीडेंट से भरपूर होता है जो आंखों, पाचन और प्रतिरक्षा के लिए लाभकारी है।",
        "te":
            "మామిడి (Mangifera indica) ను ఫలాల రాజు అంటారు. ఇది విటమిన్ A, C, E, ఫైబర్ మరియు యాంటీఆక్సిడెంట్లతో సమృద్ధిగా ఉండి కంటి ఆరోగ్యం, జీర్ణక్రియ మరియు రోగనిరోధక శక్తికి మంచిది.",
        "ta":
            "மாம்பழம் (Mangifera indica) 'பழங்களின் ராஜா' என அழைக்கப்படுகிறது. வைட்டமின் A, C, E மற்றும் நார்ச்சத்து அதிகமாக உள்ளதால் கண் ஆரோக்கியம், செரிமானம் மற்றும் நோய் எதிர்ப்பு சக்திக்கு உதவுகிறது.",
        "kn":
            "ಮಾವು (Mangifera indica) ಹಣ್ಣುಗಳ ರಾಜ ಎಂದು ಕರೆಯಲಾಗುತ್ತದೆ. ವಿಟಮಿನ್ A, C, E ಮತ್ತು ಫೈಬರ್ ಸಮೃದ್ಧವಾಗಿದ್ದು ಕಣ್ಣು, ಜೀರ್ಣಕ್ರಿಯೆ ಮತ್ತು ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿಗೆ ಸಹಾಯಕ.",
      },
      "uses": {
        "en":
            "Boosts immunity, improves eyesight, supports digestion, increases energy and helps in weight gain for underweight individuals. Mango leaves are traditionally used for managing blood sugar levels.",
        "hi":
            "प्रतिरक्षा बढ़ाता, आंखों की रोशनी सुधारता और ऊर्जा प्रदान करता है। आम के पत्ते शुगर नियंत्रण में उपयोगी माने जाते हैं।",
        "te":
            "రోగనిరోధక శక్తి పెంచుతుంది, చూపును మెరుగుపరుస్తుంది మరియు శక్తిని ఇస్తుంది. మామిడి ఆకులు చక్కెర నియంత్రణలో ఉపయోగిస్తారు.",
        "ta":
            "நோய் எதிர்ப்பு சக்தி, கண் பார்வை மற்றும் சக்தி அதிகரிக்க உதவும்; மாம்பழ இலைகள் சர்க்கரை கட்டுப்பாட்டில் பயன்படுகிறது.",
        "kn":
            "ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿ ಮತ್ತು ದೃಷ್ಟಿ ಹೆಚ್ಚಿಸಿ ಶಕ್ತಿಯನ್ನು ನೀಡುತ್ತದೆ; ಮಾವಿನ ಎಲೆಗಳು ಸಕ್ಕರೆ ನಿಯಂತ್ರಣದಲ್ಲಿ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Consumed fresh, dried, pickled or as juices, smoothies and desserts. Raw mango is used in traditional summer drinks to prevent heat stroke. Mango kernel and bark extracts are used in Ayurveda for digestive disorders.",
        "hi":
            "ताजा, अचार, जूस और मिठाइयों में उपयोग होता है। कच्चा आम लू से बचाव के लिए पेय में उपयोग किया जाता है।",
        "te":
            "తాజాగా, ఊరగాయ, జ్యూస్ మరియు స్వీట్స్ లో వాడతారు. మామిడి పచ్చడి వేసవిలో శరీరాన్ని చల్లగా ఉంచుతుంది.",
        "ta":
            "பழமாக, ஊறுகாய், ஜூஸ் மற்றும் இனிப்புகளில் பயன்படும்; காய் மாம்பழம் வெப்பநோய் தவிர்க்க உதவும்.",
        "kn":
            "ತಾಜಾ, ಉಪ್ಪಿನಕಾಯಿ, ಜ್ಯೂಸ್ ಮತ್ತು ಸಿಹಿ ಪದಾರ್ಥಗಳಲ್ಲಿ ಬಳಕೆ; ಕಾಯಿ ಮಾವು ಬೇಸಿಗೆಯಲ್ಲಿ ದೇಹ ತಂಪಾಗಿರಿಸುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Mangifera indica",
        "hi": "मैंगिफेरा इंडिका",
        "te": "మాంగిఫెరా ఇండికా",
        "ta": "மாங்கிபெரா இன்டிகா",
        "kn": "ಮ್ಯಾಂಗಿಫೆರಾ ಇಂಡಿಕಾ",
      },
      "local_names": {
        "en": "Hindi: Aam, Telugu: Mamidi, Tamil: Maambazham, Kannada: Maavu",
        "en": "Telugu: Mamidi, Hindi: Aam, Tamil: Maambazham, Kannada: Maavu",

        "hi": "तेलुगु: मामिडि, हिंदी: आम, तमिल: மாம்பழம், कन्नड़: ಮಾವು",

        "te": "తెలుగు: మామిడి, హిందీ: आम, తమిళం: மாம்பழம், కన్నಡ: ಮಾವು",

        "ta": "தெலுங்கு: மாமிடி, இந்தி: आम, தமிழ்: மாம்பழம், கன்னಡ: ಮಾವು",

        "kn": "ತೆಲುಗು: ಮಾಮಿಡಿ, ಹಿಂದಿ: आम, ತಮಿಳು: மாம்பழம், ಕನ್ನಡ: ಮಾವು",
      },
      "side_effects": {
        "en":
            "Excess consumption may cause acne, weight gain, high blood sugar or heat in the body. The sap near the peel may cause itching or rash in sensitive individuals.",
        "hi":
            "अधिक सेवन से मुंहासे, वजन बढ़ना या शुगर बढ़ सकती है। छिलके के पास का रस एलर्जी कर सकता है।",
        "te":
            "అధికంగా తింటే మొటిమలు, బరువు పెరగడం లేదా షుగర్ పెరగవచ్చు. తొక్క దగ్గర రసం చర్మ అలర్జీ కలిగిస్తుంది.",
        "ta":
            "அதிகம் சாப்பிட்டால் முகப்பரு, எடை அதிகரிப்பு அல்லது சர்க்கரை அதிகரிக்கலாம்; தோல் அரிப்பு ஏற்படலாம்.",
        "kn":
            "ಹೆಚ್ಚು ಸೇವನೆ ಮೊಡವೆ, ತೂಕ ಹೆಚ್ಚಳ ಅಥವಾ ಸಕ್ಕರೆ ಹೆಚ್ಚಳಕ್ಕೆ ಕಾರಣವಾಗಬಹುದು; ಸಿಪ್ಪೆ ರಸ ಅಲರ್ಜಿ ಉಂಟುಮಾಡಬಹುದು.",
      },
    },

    "Mint": {
      "name": {
        "en": "Mint",
        "hi": "पुदीना",
        "te": "పుదీనా",
        "ta": "புதினா",
        "kn": "ಪುದೀನಾ",
      },
      "description": {
        "en":
            "Mint is a fast-growing, cooling medicinal herb known for its refreshing aroma and taste. It is widely cultivated and used in culinary dishes, traditional medicine, and home remedies due to its soothing and digestive properties.",
        "hi":
            "पुदीना एक तेजी से बढ़ने वाली शीतल औषधीय पत्ती है, जो अपनी ताजगी भरी सुगंध और स्वाद के लिए जानी जाती है।",
        "te":
            "పుదీనా వేగంగా పెరిగే శీతల ఔషధ మొక్క. ఇది సువాసన మరియు రుచికి ప్రసిద్ధి చెందింది.",
        "ta":
            "புதினா ஒரு வேகமாக வளரும் குளிர்ச்சி தரும் மருத்துவ மூலிகை. இதன் மணமும் சுவையும் சிறப்பானது.",
        "kn":
            "ಪುದೀನಾ ವೇಗವಾಗಿ ಬೆಳೆಯುವ ತಂಪು ನೀಡುವ ಔಷಧೀಯ ಗಿಡವಾಗಿದ್ದು, ಅದರ ಸುವಾಸನೆ ಮತ್ತು ರುಚಿಗೆ ಪ್ರಸಿದ್ಧವಾಗಿದೆ.",
      },
      "uses": {
        "en":
            "Improves digestion, relieves nausea and vomiting, reduces headaches, freshens breath, and helps cool the body when consumed as juice or added to food.",
        "hi":
            "पाचन सुधारता है, मतली कम करता है, सिरदर्द में राहत देता है और शरीर को ठंडक पहुंचाता है।",
        "te":
            "జీర్ణక్రియను మెరుగుపరుస్తుంది, వాంతులు మరియు తలనొప్పిని తగ్గిస్తుంది.",
        "ta": "செரிமானத்தை மேம்படுத்தி, வாந்தி மற்றும் தலைவலியை குறைக்கும்.",
        "kn": "ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಣೆ, ವಾಂತಿ ಹಾಗೂ ತಲೆನೋವು ಕಡಿಮೆ ಮಾಡಲು ಸಹಕಾರಿ.",
      },
      "more_info": {
        "en":
            "Mint leaves are commonly used in chutneys, salads, teas, juices, and flavored drinks. Mint oil has antibacterial properties and is used in toothpaste, mouth fresheners, and herbal medicines.",
        "hi":
            "पुदीना चटनी, सलाद, चाय और पेय पदार्थों में उपयोग किया जाता है। इसका तेल दंत उत्पादों में भी इस्तेमाल होता है।",
        "te":
            "పుదీనా ఆకులను చట్నీలు, సలాడ్లు, టీలు మరియు పానీయాలలో ఉపయోగిస్తారు.",
        "ta":
            "புதினா இலைகள் சட்னி, சாலட், தேநீர் மற்றும் பானங்களில் பயன்படுகின்றன.",
        "kn":
            "ಪುದೀನಾ ಎಲೆಗಳನ್ನು ಚಟ್ನಿ, ಸಲಾಡ್, ಟೀ ಮತ್ತು ಪಾನೀಯಗಳಲ್ಲಿ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Mentha spicata",
        "hi": "मेंथा स्पिकाटा",
        "te": "మెంతా స్పికాటా",
        "ta": "மெந்தா ஸ்பிகாட்டா",
        "kn": "ಮೆಂಥಾ ಸ್ಪಿಕಾಟಾ",
      },
      "local_names": {
        "en": "Hindi: Pudina, Telugu: Pudina, Tamil: Pudina, Kannada: Pudina",
        "hi": "तेलुगु: पुदीना, हिंदी: पुदीना, तमिल: புதினா, कन्नड़: ಪುದೀನಾ",

        "te": "తెలుగు: పుదీనా, హిందీ: पुदीना, తమిళం: புதினா, కన్నಡ: ಪುದೀನಾ",

        "ta": "தெலுங்கு: புதினா, இந்தி: पुदीना, தமிழ்: புதினா, கன்னಡ: ಪುದೀನಾ",

        "kn": "ತೆಲುಗು: ಪುದೀನಾ, ಹಿಂದಿ: पुदीना, ತಮಿಳು: புதினா, ಕನ್ನಡ: ಪುದೀನಾ",
      },
      "side_effects": {
        "en":
            "Excessive consumption may worsen acid reflux, cause stomach irritation, or allergic reactions in sensitive individuals.",
        "hi": "अधिक सेवन से एसिडिटी, पेट में जलन या एलर्जी हो सकती है।",
        "te": "అధికంగా వాడితే అమ్లత్వం లేదా కడుపు అసౌకర్యం కలగవచ్చు.",
        "ta":
            "அதிகமாக பயன்படுத்தினால் அமிலத்தன்மை அல்லது வயிற்று எரிச்சல் ஏற்படலாம்.",
        "kn": "ಅತಿಯಾಗಿ ಸೇವಿಸಿದರೆ ಆಮ್ಲತೆ ಅಥವಾ ಹೊಟ್ಟೆ ಅಸ್ವಸ್ಥತೆ ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Nagadali": {
      "name": {
        "en": "Nagadali",
        "hi": "अडुलसा",
        "te": "అడ్డసరం",
        "ta": "அடத்தோடை",
        "kn": "ಅಡಸೋಗಿ",
      },
      "description": {
        "en":
            "Nagadali (Justicia adhatoda) is a well-known Ayurvedic medicinal shrub valued for its powerful action on the respiratory system. The leaves contain alkaloids like vasicine that act as bronchodilators and expectorants, helping clear mucus from airways.",
        "hi":
            "अडुलसा (Justicia adhatoda) एक प्रसिद्ध आयुर्वेदिक झाड़ी है जो श्वसन तंत्र पर प्रभाव डालती है। इसकी पत्तियों में वासिसिन नामक तत्व होता है जो कफ निकालने और सांस लेने में सहायता करता है।",
        "te":
            "అడ్డసరం (Justicia adhatoda) ఆయుర్వేదంలో ప్రసిద్ధి చెందిన ఔషధ మొక్క. ఇందులో వాసిసిన్ అనే పదార్థం ఉండి శ్వాసనాళాల్లో కఫాన్ని తొలగించి శ్వాసను సులభం చేస్తుంది.",
        "ta":
            "அடத்தோடை (Justicia adhatoda) ஆயுர்வேதத்தில் முக்கியமான மூலிகை. இதில் உள்ள வாசிசின் சுவாசக் குழாய்களை திறந்து கபத்தை வெளியேற்ற உதவுகிறது.",
        "kn":
            "ಅಡಸೋಗಿ (Justicia adhatoda) ಆಯುರ್ವೇದದಲ್ಲಿ ಪ್ರಸಿದ್ಧ ಔಷಧ ಸಸ್ಯ. ಇದರ ಎಲೆಗಳಲ್ಲಿ ಇರುವ ವಾಸಿಸಿನ್ ಶ್ಲೇಷ್ಮವನ್ನು ಹೊರಹಾಕಿ ಉಸಿರಾಟ ಸುಲಭಗೊಳಿಸುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Used for cough, asthma, bronchitis, cold, throat infections and breathing difficulty. Also helps reduce inflammation and acts as a mild antibacterial agent.",
        "hi":
            "खांसी, दमा, ब्रोंकाइटिस, सर्दी और गले के संक्रमण में उपयोगी। सूजन कम करता है और जीवाणुरोधी गुण रखता है।",
        "te":
            "దగ్గు, ఆస్తమా, బ్రాంకైటిస్, జలుబు మరియు గొంతు ఇన్ఫెక్షన్లలో ఉపయోగపడుతుంది. వాపును తగ్గించి బ్యాక్టీరియా నిరోధకంగా పనిచేస్తుంది.",
        "ta":
            "இருமல், ஆஸ்துமா, சளி, தொண்டை தொற்று மற்றும் மூச்சுத் திணறலில் பயன்படும்; அழற்சியை குறைக்கும் மற்றும் கிருமி எதிர்ப்பு குணம் உள்ளது.",
        "kn":
            "ಕೆಮ್ಮು, ಆಸ್ಥಮಾ, ಬ್ರಾಂಕೈಟಿಸ್ ಮತ್ತು ಗಂಟಲು ಸೋಂಕುಗಳಲ್ಲಿ ಉಪಯೋಗಿ; ಉರಿಯೂತ ಕಡಿಮೆ ಮಾಡಿ ಬ್ಯಾಕ್ಟೀರಿಯಾ ವಿರೋಧಿ ಗುಣ ಹೊಂದಿದೆ.",
      },
      "more_info": {
        "en":
            "Leaves are prepared as herbal tea, juice, syrup or decoction. Widely used in traditional cough syrups and steam inhalation remedies.",
        "hi":
            "पत्तियों का काढ़ा, रस और सिरप बनाया जाता है तथा पारंपरिक खांसी की दवा में उपयोग होता है।",
        "te":
            "ఆకులతో కషాయం, రసం మరియు సిరప్ తయారు చేసి దగ్గు మందులలో ఉపయోగిస్తారు.",
        "ta":
            "இலைகளால் கஷாயம், சாறு மற்றும் சிரப் தயாரித்து இருமல் மருந்தாக பயன்படுத்தப்படுகிறது.",
        "kn":
            "ಎಲೆಗಳಿಂದ ಕಷಾಯ, ರಸ ಮತ್ತು ಸಿರಪ್ ತಯಾರಿಸಿ ಕೆಮ್ಮಿನ ಔಷಧದಲ್ಲಿ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Justicia adhatoda",
        "hi": "जस्टिसिया अडहाटोडा",
        "te": "జస్టిసియా అధటోడా",
        "ta": "ஜஸ்டிசியா அதடோடா",
        "kn": "ಜಸ್ಟಿಸಿಯಾ ಅಧಟೋಡಾ",
      },
      "local_names": {
        "en":
            "Hindi: Adulsa, Telugu: Addasaram, Tamil: Adathodai, Kannada: Adusoge",

        "hi": "तेलुगु: अड्डसरम, हिंदी: अडुलसा, तमिल: அடத்தோடை, कन्नड़: ಅಡಸೋಗಿ",

        "te": "తెలుగు: అడ్డసరం, హిందీ: अडुलसा, తమిళం: அடத்தோடை, కన్నಡ: ಅಡಸೋಗಿ",

        "ta":
            "தெலுங்கு: அட்டசரம், இந்தி: अडुलसा, தமிழ்: அடத்தோடை, கன்னಡ: ಅಡಸೋಗಿ",

        "kn": "ತೆಲುಗು: ಅಡ್ಡಸರಂ, ಹಿಂದಿ: अडुलसा, ತಮಿಳು: அடத்தோடை, ಕನ್ನಡ: ಅಡಸೋಗಿ",
      },
      "side_effects": {
        "en":
            "Excess intake may cause vomiting, stomach upset or irritation. Not recommended in high doses during pregnancy.",
        "hi":
            "अधिक सेवन से उल्टी या पेट खराब हो सकता है, गर्भावस्था में अधिक मात्रा से बचें।",
        "te":
            "అధికంగా తీసుకుంటే వాంతులు లేదా కడుపు సమస్యలు రావచ్చు, గర్భిణీలు జాగ్రత్తగా వాడాలి.",
        "ta":
            "அதிக அளவு எடுத்தால் வாந்தி அல்லது வயிற்று பிரச்சனை ஏற்படலாம்; கர்ப்பிணிகள் கவனம் தேவை.",
        "kn":
            "ಹೆಚ್ಚು ಸೇವನೆ ವಾಂತಿ ಅಥವಾ ಹೊಟ್ಟೆ ತೊಂದರೆ ಉಂಟುಮಾಡಬಹುದು; ಗರ್ಭಿಣಿಯರು ಜಾಗ್ರತೆ ಅಗತ್ಯ.",
      },
    },

    "Neem": {
      "name": {
        "en": "Neem",
        "hi": "नीम",
        "te": "వేప",
        "ta": "வேம்பு",
        "kn": "ಬೆವು",
      },
      "description": {
        "en":
            "Neem is a powerful, evergreen medicinal tree widely used in traditional medicine systems for its antibacterial, antifungal, and antiviral properties. Almost every part of the tree has medicinal value.",
        "hi":
            "नीम एक शक्तिशाली सदाबहार औषधीय वृक्ष है, जिसका उपयोग पारंपरिक चिकित्सा में जीवाणुरोधी गुणों के लिए किया जाता है।",
        "te":
            "వేప ఒక శక్తివంతమైన ఎల్లప్పుడూ పచ్చగా ఉండే ఔషధ చెట్టు. దీనికి జీవాణు నిరోధక గుణాలు ఉన్నాయి.",
        "ta":
            "வேம்பு ஒரு சக்திவாய்ந்த எப்போதும் பச்சையாக இருக்கும் மருத்துவ மரமாகும். இதில் கிருமி எதிர்ப்பு தன்மைகள் உள்ளன.",
        "kn":
            "ಬೆವು ಶಕ್ತಿಶಾಲಿ ಸದಾ ಹಸಿರು ಔಷಧೀಯ ಮರವಾಗಿದ್ದು, ಬ್ಯಾಕ್ಟೀರಿಯಾ ಮತ್ತು ಶಿಲೀಂಧ್ರ ವಿರೋಧಿ ಗುಣಗಳನ್ನು ಹೊಂದಿದೆ.",
      },
      "uses": {
        "en":
            "Purifies blood, improves skin health, boosts immunity, helps treat acne, wounds, and infections, and supports oral hygiene.",
        "hi":
            "खून शुद्ध करता है, त्वचा स्वास्थ्य सुधारता है, रोग प्रतिरोधक क्षमता बढ़ाता है।",
        "te":
            "రక్తాన్ని శుద్ధి చేస్తుంది, చర్మ ఆరోగ్యాన్ని మెరుగుపరుస్తుంది మరియు రోగనిరోధక శక్తిని పెంచుతుంది.",
        "ta":
            "ரத்தத்தை சுத்தப்படுத்தி, தோல் ஆரோக்கியத்தை மேம்படுத்தி நோய் எதிர்ப்பு சக்தியை அதிகரிக்கிறது.",
        "kn":
            "ರಕ್ತ ಶುದ್ಧೀಕರಣ, ಚರ್ಮ ಆರೋಗ್ಯ ಸುಧಾರಣೆ ಮತ್ತು ರೋಗನಿರೋಧಕ ಶಕ್ತಿ ಹೆಚ್ಚಿಸಲು ಸಹಾಯಕ.",
      },
      "more_info": {
        "en":
            "Neem leaves, bark, seeds, and oil are used in herbal medicines, soaps, toothpaste, oils, and pesticides. Neem twigs are traditionally used as natural toothbrushes.",
        "hi":
            "नीम की पत्तियाँ, छाल, बीज और तेल औषधि, साबुन और दंत उत्पादों में उपयोग होते हैं।",
        "te":
            "వేప ఆకులు, బెరడు, గింజలు మరియు నూనెను ఔషధాలు, సబ్బులు మరియు టూత్‌పేస్ట్‌లలో ఉపయోగిస్తారు.",
        "ta":
            "வேம்பு இலை, பட்டை, விதை மற்றும் எண்ணெய் மருந்துகள், சோப்பு மற்றும் பல் பராமரிப்பு பொருட்களில் பயன்படுத்தப்படுகின்றன.",
        "kn":
            "ಬೆವು ಎಲೆ, ತೊಗಟೆ, ಬೀಜ ಮತ್ತು ಎಣ್ಣೆಯನ್ನು ಔಷಧ, ಸಾಬೂನು ಹಾಗೂ ದಂತ ಉತ್ಪನ್ನಗಳಲ್ಲಿ ಬಳಸುತ್ತಾರೆ.",
      },
      "scientific_name": {
        "en": "Azadirachta indica",
        "hi": "अजादिरख्ता इंडिका",
        "te": "అజాదిరక్త ఇండికా",
        "ta": "அசடிரக்டா இன்டிகா",
        "kn": "ಅಜಾದಿರಖ್ತ ಇಂಡಿಕಾ",
      },
      "local_names": {
        "en": "Hindi: Neem, Telugu: Vepa, Tamil: Vembu, Kannada: Bevu",
        "hi": "तेलुगु: वेप, हिंदी: नीम, तमिल: வேம்பு, कन्नड़: ಬೆವು",

        "te": "తెలుగు: వేప, హిందీ: नीम, తమిళం: வேம்பு, కన్నಡ: ಬೆವು",

        "ta": "தெலுங்கு: வேப, இந்தி: नीम, தமிழ்: வேம்பு, கன்னಡ: ಬೆವು",

        "kn": "ತೆಲುಗು: ವೇಪ, ಹಿಂದಿ: नीम, ತಮಿಳು: வேம்பு, ಕನ್ನಡ: ಬೆವು",
      },
      "side_effects": {
        "en":
            "Excessive intake may affect liver function, cause stomach irritation, or be unsafe during pregnancy and for young children.",
        "hi":
            "अधिक सेवन से लीवर पर असर, पेट की समस्या या गर्भावस्था में नुकसान हो सकता है।",
        "te": "అధికంగా తీసుకుంటే కాలేయానికి హాని లేదా కడుపు సమస్యలు రావచ్చు.",
        "ta":
            "அதிகமாக எடுத்தால் கல்லீரல் பாதிப்பு அல்லது வயிற்று கோளாறு ஏற்படலாம்.",
        "kn": "ಅತಿಯಾಗಿ ಸೇವಿಸಿದರೆ ಯಕೃತ್ ಹಾನಿ ಅಥವಾ ಹೊಟ್ಟೆ ತೊಂದರೆ ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Nithyapushpa": {
      "name": {
        "en": "Nithyapushpa",
        "hi": "सदाबहार",
        "te": "బిల్లగన్నేరు",
        "ta": "நித்தியபுஷ்பா",
        "kn": "ಸದಾಬಹಾರ",
      },
      "description": {
        "en":
            "Nithyapushpa (Catharanthus roseus) is an important medicinal flowering plant widely used in Ayurveda and modern medicine. It contains powerful alkaloids such as vincristine and vinblastine which influence blood cells and metabolism, and the plant is traditionally used for diabetes and wound care.",
        "hi":
            "सदाबहार (Catharanthus roseus) एक महत्वपूर्ण औषधीय पौधा है जिसका उपयोग आयुर्वेद और आधुनिक चिकित्सा में होता है। इसमें विनक्रिस्टीन और विनब्लास्टीन जैसे शक्तिशाली अल्कलॉइड पाए जाते हैं जो रक्त कोशिकाओं और चयापचय को प्रभावित करते हैं तथा मधुमेह और घावों में उपयोगी माने जाते हैं।",
        "te":
            "బిల్లగన్నేరు (Catharanthus roseus) ఆయుర్వేదం మరియు ఆధునిక వైద్యంలో ముఖ్యమైన ఔషధ మొక్క. ఇందులో విన్క్రిస్టిన్, విన్బ్లాస్టిన్ వంటి శక్తివంతమైన ఆల్కలాయిడ్లు ఉండి రక్తకణాలు మరియు చయాపచయంపై ప్రభావం చూపుతాయి; సంప్రదాయంగా మధుమేహం మరియు గాయాల చికిత్సలో వాడతారు.",
        "ta":
            "நித்தியபுஷ்பா (Catharanthus roseus) ஆயுர்வேதமும் நவீன மருத்துவத்திலும் பயன்படும் முக்கிய மூலிகை. இதில் உள்ள விங்கிரிஸ்டின் மற்றும் விங்க்பிளாஸ்டின் போன்ற ஆல்கலாய்டுகள் இரத்த அணுக்கள் மற்றும் மாற்றுச்சக்கரத்தில் தாக்கம் செலுத்தி சர்க்கரை நோய் மற்றும் காயங்களுக்கு பயன்படுத்தப்படுகிறது.",
        "kn":
            "ಸದಾಬಹಾರ (Catharanthus roseus) ಆಯುರ್ವೇದ ಹಾಗೂ ಆಧುನಿಕ ವೈದ್ಯಕೀಯದಲ್ಲಿ ಪ್ರಮುಖ ಔಷಧ ಸಸ್ಯ. ಇದರಲ್ಲಿ ವಿನ್ಕ್ರಿಸ್ಟಿನ್ ಮತ್ತು ವಿನ್ಬ್ಲಾಸ್ಟಿನ್ ಎಂಬ ಆಲ್ಕಲಾಯ್ಡ್‌ಗಳು ಇದ್ದು ರಕ್ತಕಣಗಳು ಮತ್ತು ಚಯಾಪಚಯವನ್ನು ಪ್ರಭಾವಿಸುತ್ತದೆ; ಮಧುಮೇಹ ಮತ್ತು ಗಾಯಗಳಿಗೆ ಬಳಕೆ ಇದೆ.",
      },
      "uses": {
        "en":
            "Traditionally used to help regulate blood sugar, support wound healing, reduce inflammation and assist certain cancer treatments in pharmaceutical medicine.",
        "hi":
            "रक्त शर्करा नियंत्रण, घाव भरने, सूजन कम करने और कैंसर उपचार में औषधीय उपयोग।",
        "te":
            "రక్తంలో చక్కెర నియంత్రణ, గాయాలు మాన్పడం, వాపు తగ్గించడం మరియు ఔషధ క్యాన్సర్ చికిత్సల్లో ఉపయోగం.",
        "ta":
            "சர்க்கரை கட்டுப்பாடு, காயம் ஆற்றல், அழற்சி குறைப்பு மற்றும் மருந்து தயாரிப்புகளில் புற்றுநோய் சிகிச்சை பயன்பாடு.",
        "kn":
            "ರಕ್ತದ ಸಕ್ಕರೆ ನಿಯಂತ್ರಣ, ಗಾಯ ಗುಣಪಡಿಸುವುದು, ಉರಿಯೂತ ಕಡಿಮೆ ಮಾಡುವುದು ಮತ್ತು ಕ್ಯಾನ್ಸರ್ ಔಷಧಗಳಲ್ಲಿ ಬಳಕೆ.",
      },
      "more_info": {
        "en":
            "Leaves, roots and flowers are used carefully in herbal preparations; pharmaceutical extracts from this plant are globally used in chemotherapy drugs.",
        "hi":
            "पत्तियां, जड़ और फूल सावधानी से औषधि में उपयोग किए जाते हैं तथा इसके अर्क कैंसर की दवाओं में उपयोग होते हैं।",
        "te":
            "ఆకులు, వేరు మరియు పువ్వులు జాగ్రత్తగా ఔషధాల్లో వాడతారు; ఈ మొక్క నుండి తీసిన పదార్థాలు క్యాన్సర్ మందుల్లో ఉపయోగిస్తారు.",
        "ta":
            "இலை, வேர் மற்றும் மலர்கள் கவனமாக மருந்துகளில் பயன்படுத்தப்படுகின்றன; இதன் சாறுகள் புற்றுநோய் மருந்துகளில் பயன்படுகின்றன.",
        "kn":
            "ಎಲೆ, ಬೇರು ಮತ್ತು ಹೂಗಳನ್ನು ಜಾಗ್ರತೆಯಿಂದ ಔಷಧದಲ್ಲಿ ಬಳಸಲಾಗುತ್ತದೆ; ಇದರ ಸಾರತತ್ತ್ವಗಳು ಕ್ಯಾನ್ಸರ್ ಔಷಧಗಳಲ್ಲಿ ಉಪಯೋಗವಾಗುತ್ತವೆ.",
      },
      "scientific_name": {
        "en": "Catharanthus roseus",
        "hi": "कैथरैंथस रोज़ियस",
        "te": "కాథరాంథస్ రోజియస్",
        "ta": "காதராந்தஸ் ரோசியஸ்",
        "kn": "ಕಾಥರಾಂಥಸ್ ರೋಸಿಯಸ್",
      },
      "local_names": {
        "en":
            "Hindi: Sadabahar, Telugu: Billaganneru, Tamil: Nithyapushpa, Kannada: Sadabahara",
        "hi":
            "तेलुगु: बिल्लगन्नेरु, हिंदी: सदाबहार, तमिल: நித்தியபுஷ்பா, कन्नड़: ಸದಾಬಹಾರ",

        "te":
            "తెలుగు: బిల్లగన్నేరు, హిందీ: सदाबहार, తమిళం: நித்தியபுஷ்பா, కన్నಡ: ಸದಾಬಹಾರ",

        "ta":
            "தெலுங்கு: பில்லகன்னேறு, இந்தி: सदाबहार, தமிழ்: நித்தியபுஷ்பா, கன்னಡ: ಸದಾಬಹಾರ",

        "kn":
            "ತೆಲುಗು: ಬಿಲ್ಲಗನ್ನೇರು, ಹಿಂದಿ: सदाबहार, ತಮಿಳು: நித்தியபுஷ்பா, ಕನ್ನಡ: ಸದಾಬಹಾರ",
      },
      "side_effects": {
        "en":
            "All parts of the plant are toxic if consumed directly in large amounts; improper use may cause nausea, low blood pressure and nerve issues.",
        "hi":
            "अधिक मात्रा में सेवन विषैला हो सकता है; उल्टी, लो ब्लड प्रेशर और नसों की समस्या हो सकती है।",
        "te":
            "అధికంగా తీసుకుంటే విషపూరితం; వాంతులు, తక్కువ రక్తపోటు మరియు నర సమస్యలు రావచ్చు.",
        "ta":
            "அதிக அளவு எடுத்தால் நச்சுத்தன்மை, வாந்தி, குறைந்த ரத்த அழுத்தம் மற்றும் நரம்பு பாதிப்பு ஏற்படலாம்.",
        "kn":
            "ಹೆಚ್ಚು ಸೇವನೆ ವಿಷಕಾರಿ; ವಾಂತಿ, ಕಡಿಮೆ ರಕ್ತದ ಒತ್ತಡ ಮತ್ತು ನರ ಸಮಸ್ಯೆಗಳು ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Nooni": {
      "name": {
        "en": "Nooni",
        "hi": "नोनी",
        "te": "తొగరు పండు",
        "ta": "நுணா",
        "kn": "ನೋನಿ",
      },
      "description": {
        "en":
            "Nooni is a tropical medicinal fruit traditionally used for its healing, antioxidant, and immune-boosting properties. The fruit, leaves, and roots are used in folk medicine.",
        "hi":
            "नोनी एक उष्णकटिबंधीय औषधीय फल है जिसका उपयोग पारंपरिक चिकित्सा में रोग निवारण के लिए किया जाता है।",
        "te":
            "నూని ఒక ఉష్ణ మండల ఔషధ పండు. దీనికి ఔషధ మరియు యాంటీఆక్సిడెంట్ గుణాలు ఉన్నాయి.",
        "ta":
            "நுணா ஒரு வெப்ப மண்டல மருத்துவப் பழமாகும். இது உடல் ஆரோக்கியத்தை மேம்படுத்த உதவுகிறது.",
        "kn":
            "ನೋನಿ ಉಷ್ಣವಲಯದ ಔಷಧೀಯ ಹಣ್ಣು ಆಗಿದ್ದು, ಆರೋಗ್ಯ ವರ್ಧಕ ಗುಣಗಳನ್ನು ಹೊಂದಿದೆ.",
      },
      "uses": {
        "en":
            "Used in herbal tonics to boost immunity, improve digestion, reduce inflammation, and support overall wellness.",
        "hi": "प्रतिरक्षा बढ़ाने, पाचन सुधारने और सूजन कम करने में सहायक।",
        "te":
            "రోగనిరోధక శక్తి పెంచడం, జీర్ణక్రియ మెరుగుపరచడం మరియు వాపు తగ్గించడంలో ఉపయోగపడుతుంది.",
        "ta":
            "நோய் எதிர்ப்பு சக்தியை உயர்த்தி, செரிமானத்தை மேம்படுத்தி, அழற்சியை குறைக்க உதவுகிறது.",
        "kn":
            "ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿ ಹೆಚ್ಚಿಸಿ, ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಿಸಿ, ಉರಿಯೂತ ಕಡಿಮೆ ಮಾಡುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Nooni fruit is commonly fermented or processed into juice. Leaves are applied externally for pain relief, and roots are used in traditional remedies.",
        "hi":
            "नोनी फल का जूस बनाया जाता है, पत्तियाँ बाहरी उपचार में और जड़ें औषधि में उपयोग होती हैं।",
        "te":
            "నూని పండును సాధారణంగా రసం తయారీలో వాడుతారు. ఆకులు నొప్పి తగ్గించేందుకు ఉపయోగిస్తారు.",
        "ta":
            "நுணா பழம் சாறாக பயன்படுத்தப்படுகிறது. இலைகள் வெளிப்புற வலிநிவாரணத்திற்கு பயன்படுகின்றன.",
        "kn":
            "ನೋನಿ ಹಣ್ಣನ್ನು ಸಾಮಾನ್ಯವಾಗಿ ರಸವಾಗಿ ಬಳಸುತ್ತಾರೆ. ಎಲೆಗಳು ನೋವು ನಿವಾರಣೆಗೆ ಉಪಯೋಗವಾಗುತ್ತವೆ.",
      },
      "scientific_name": {
        "en": "Morinda citrifolia",
        "hi": "मोरिंडा सिट्रिफोलिया",
        "te": "మోరిండా సిట్రిఫోలియా",
        "ta": "மோரிண்டா சிட்ரிஃபோலியா",
        "kn": "ಮೋರಿಂಡಾ ಸಿಟ್ರಿಫೋಲಿಯಾ",
      },
      "local_names": {
        "en": "Telugu: Thogaru Pandu, Hindi: Noni, Tamil: Nuna, Kannada: Noni",

        "hi": "तेलुगु: थोहरु पंडु, हिंदी: नोनी, तमिल: நுணா, कन्नड़: ನೋನಿ",

        "te": "తెలుగు: తొగరు పండు, హిందీ: नोनी, తమిళం: நுணா, కన్నಡ: ನೋನಿ",

        "ta": "தெலுங்கு: தொகரு பண்டு, இந்தி: नोनी, தமிழ்: நுணா, கன்னಡ: ನೋನಿ",

        "kn": "ತೆಲುಗು: ತೊಗರು ಪಂಡು, ಹಿಂದಿ: नोनी, ತಮಿಳು: நுணா, ಕನ್ನಡ: ನೋನಿ",
      },
      "side_effects": {
        "en":
            "Excess consumption may affect kidney function, cause nausea, or interact with medications due to high potassium content.",
        "hi": "अधिक सेवन से किडनी पर असर या मतली हो सकती है।",
        "te": "అధికంగా తీసుకుంటే మూత్రపిండాలకు హాని లేదా వాంతులు రావచ్చు.",
        "ta": "அதிகமாக எடுத்தால் சிறுநீரக பாதிப்பு அல்லது மயக்கம் ஏற்படலாம்.",
        "kn": "ಅತಿಯಾಗಿ ಸೇವಿಸಿದರೆ ಕಿಡ್ನಿ ಸಮಸ್ಯೆ ಅಥವಾ ವಾಕರಿಕೆ ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Pappaya": {
      "name": {
        "en": "Papaya",
        "hi": "पपीता",
        "te": "బొప్పాయి",
        "ta": "பப்பாளி",
        "kn": "ಪಪ್ಪಾಯಿ",
      },
      "description": {
        "en":
            "Papaya (Carica papaya) is a tropical fruit rich in papain enzyme, vitamins A, C, E, folate, fiber and antioxidants. It supports digestion, skin repair and immunity and is widely used in both nutrition and traditional medicine.",
        "hi":
            "पपीता (Carica papaya) एक उष्णकटिबंधीय फल है जिसमें पपेन एंजाइम, विटामिन A, C, E, फोलेट, फाइबर और एंटीऑक्सीडेंट प्रचुर मात्रा में होते हैं। यह पाचन, त्वचा और प्रतिरक्षा प्रणाली को मजबूत करता है।",
        "te":
            "బొప్పాయి (Carica papaya) ఉష్ణమండల పండు. ఇందులో పపైన్ ఎంజైమ్, విటమిన్ A, C, E, ఫోలేట్, ఫైబర్ మరియు యాంటీఆక్సిడెంట్లు సమృద్ధిగా ఉంటాయి. ఇది జీర్ణక్రియ, చర్మం మరియు రోగనిరోధక శక్తికి సహాయపడుతుంది.",
        "ta":
            "பப்பாளி (Carica papaya) ஒரு வெப்பமண்டலப் பழம். இதில் பபைன் என்சைம், வைட்டமின் A, C, E, நார்ச்சத்து மற்றும் ஆன்டி-ஆக்ஸிடென்ட்கள் நிறைந்துள்ளதால் செரிமானம் மற்றும் நோய் எதிர்ப்பு சக்தியை மேம்படுத்துகிறது.",
        "kn":
            "ಪಪ್ಪಾಯಿ (Carica papaya) ಉಷ್ಣವಲಯ ಹಣ್ಣು. ಇದರಲ್ಲಿ ಪಪೈನ್ ಎಂಜೈಮ್, ವಿಟಮಿನ್ A, C, E, ನಾರು ಮತ್ತು ಆಂಟಿಆಕ್ಸಿಡೆಂಟ್‌ಗಳು ಇದ್ದು ಜೀರ್ಣಕ್ರಿಯೆ ಮತ್ತು ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿಗೆ ಸಹಾಯಕ.",
      },
      "uses": {
        "en":
            "Improves digestion, relieves constipation, promotes glowing skin, helps in wound healing and supports immunity.",
        "hi":
            "पाचन सुधारता है, कब्ज दूर करता है, त्वचा निखारता है और प्रतिरक्षा बढ़ाता है।",
        "te":
            "జీర్ణక్రియ మెరుగుపరుస్తుంది, మలబద్ధకం తగ్గిస్తుంది, చర్మ కాంతి పెంచుతుంది మరియు రోగనిరోధక శక్తిని పెంచుతుంది.",
        "ta":
            "செரிமானம் மேம்படும், மலச்சிக்கல் குறையும், தோல் ஒளிவீச்சு அதிகரிக்கும் மற்றும் நோய் எதிர்ப்பு சக்தி உயரும்.",
        "kn":
            "ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಣೆ, ಮಲಬದ್ಧತೆ ಕಡಿಮೆ, ಚರ್ಮದ ಕಾಂತಿ ಹೆಚ್ಚಳ ಮತ್ತು ರೋಗನಿರೋಧಕ ಶಕ್ತಿ ಹೆಚ್ಚಿಸುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Both ripe fruit and leaves are used in traditional remedies; papaya leaf extract is popularly used for platelet support in dengue care in folk medicine.",
        "hi":
            "पका फल और पत्तियां पारंपरिक चिकित्सा में उपयोग होती हैं; डेंगू में प्लेटलेट बढ़ाने के लिए पपीते के पत्तों का रस लोक चिकित्सा में प्रयोग किया जाता है।",
        "te":
            "పండు మరియు ఆకులు సంప్రదాయ వైద్యంలో వాడతారు; డెంగ్యూ సమయంలో ప్లేట్లెట్స్ పెంచేందుకు బొప్పాయి ఆకుల రసం ఉపయోగిస్తారు.",
        "ta":
            "பழமும் இலைகளும் மருந்தாக பயன்படுத்தப்படுகின்றன; டெங்கு காலத்தில் தகடு எண்ணிக்கை அதிகரிக்க பப்பாளி இலை சாறு பயன்படுத்தப்படுகிறது.",
        "kn":
            "ಹಣ್ಣು ಮತ್ತು ಎಲೆಗಳನ್ನು ಮನೆಮದ್ದಾಗಿ ಬಳಸುತ್ತಾರೆ; ಡೆಂಗ್ಯೂ ಸಮಯದಲ್ಲಿ ಪ್ಲೇಟ್ಲೆಟ್ ಹೆಚ್ಚಿಸಲು ಪಪ್ಪಾಯಿ ಎಲೆ ರಸ ಬಳಕೆ ಇದೆ.",
      },
      "scientific_name": {
        "en": "Carica papaya",
        "hi": "कैरीका पपाया",
        "te": "కారికా పపాయ",
        "ta": "கரிக்கா பப்பாயா",
        "kn": "ಕಾರಿಕಾ ಪಪಾಯಾ",
      },
      "local_names": {
        "en":
            "Hindi: Papita, Telugu: Boppayi, Tamil: Pappali, Kannada: Pappayi",
        "hi": "तेलुगु: बोप्पायी, हिंदी: पपीता, तमिल: பப்பாளி, कन्नड़: ಪಪ್ಪಾಯಿ",

        "te": "తెలుగు: బొప్పాయి, హిందీ: पपीता, తమిళం: பப்பாளி, కన్నಡ: ಪಪ್ಪಾಯಿ",

        "ta":
            "தெலுங்கு: பொப்பாயி, இந்தி: पपीता, தமிழ்: பப்பாளி, கன்னಡ: ಪಪ್ಪಾಯಿ",

        "kn": "ತೆಲುಗು: ಬೊಪ್ಪಾಯಿ, ಹಿಂದಿ: पपीता, ತಮಿಳು: பப்பாளி, ಕನ್ನಡ: ಪಪ್ಪಾಯಿ",
      },
      "side_effects": {
        "en":
            "Unripe papaya latex may cause uterine contractions during pregnancy and excessive intake may cause stomach irritation in sensitive individuals.",
        "hi":
            "कच्चे पपीते का लेटेक्स गर्भावस्था में हानिकारक हो सकता है और अधिक सेवन से पेट में जलन हो सकती है।",
        "te":
            "ముడి బొప్పాయి గర్భధారణలో హానికరం; ఎక్కువగా తింటే కడుపు మంట కలగవచ్చు.",
        "ta":
            "மூலப்பழம் கர்ப்பத்தில் தீங்கு தரலாம்; அதிகமாக சாப்பிட்டால் வயிற்று எரிச்சல் ஏற்படும்.",
        "kn":
            "ಕಚ್ಚಾ ಪಪ್ಪಾಯಿ ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ಹಾನಿಕರ; ಹೆಚ್ಚು ಸೇವಿಸಿದರೆ ಹೊಟ್ಟೆ ಉರಿಯೂತ ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Pepper": {
      "name": {
        "en": "Black Pepper",
        "hi": "काली मिर्च",
        "te": "మిరియాలు",
        "ta": "மிளகு",
        "kn": "ಮೆಣಸು",
      },
      "description": {
        "en":
            "Black pepper is a widely used medicinal spice known for its warming effect, strong aroma, and health-boosting properties. It has been used in traditional medicine for centuries.",
        "hi":
            "काली मिर्च एक प्रसिद्ध औषधीय मसाला है जो अपने गरम प्रभाव और औषधीय गुणों के लिए जाना जाता है।",
        "te":
            "మిరియాలు వేడి గుణాలు కలిగిన ప్రసిద్ధ ఔషధ మసాలా, ఇది సంప్రదాయ వైద్యంలో విస్తృతంగా ఉపయోగిస్తారు.",
        "ta": "மிளகு வெப்பத் தன்மை கொண்ட ஒரு முக்கியமான மருத்துவ மசாலா ஆகும்.",
        "kn": "ಮೆಣಸು ಉಷ್ಣ ಗುಣ ಹೊಂದಿರುವ ಪ್ರಸಿದ್ಧ ಔಷಧೀಯ ಮಸಾಲೆಯಾಗಿದೆ.",
      },
      "uses": {
        "en":
            "Improves digestion, boosts metabolism, helps relieve cold and cough, and enhances nutrient absorption.",
        "hi": "पाचन सुधारता है, सर्दी-खांसी में लाभकारी और चयापचय बढ़ाता है।",
        "te":
            "జీర్ణక్రియను మెరుగుపరుస్తుంది, జలుబు-దగ్గు తగ్గించడంలో సహాయపడుతుంది.",
        "ta": "செரிமானத்தை மேம்படுத்தி, சளி மற்றும் இருமலை குறைக்க உதவுகிறது.",
        "kn": "ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಿಸಿ, ಜ್ವರ-ಕೆಮ್ಮು ಕಡಿಮೆ ಮಾಡಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Contains piperine, an active compound that enhances digestion and increases the effectiveness of other herbal medicines.",
        "hi":
            "इसमें पाइपेरिन नामक तत्व होता है जो औषधियों की प्रभावशीलता बढ़ाता है।",
        "te":
            "దీనిలో పైపెరిన్ అనే పదార్థం ఉంటుంది, ఇది ఔషధాల ప్రభావాన్ని పెంచుతుంది.",
        "ta": "பைபரின் என்ற செயலில் ஈடுபடும் பொருள் இதில் உள்ளது.",
        "kn":
            "ಇದರಲ್ಲಿ ಪೈಪರಿನ್ ಎಂಬ ಸಂಯೋಗವಿದ್ದು, ಔಷಧೀಯ ಶಕ್ತಿಯನ್ನು ಹೆಚ್ಚಿಸುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Piper nigrum",
        "hi": "पाइपर निग्रम",
        "te": "పైపర్ నిగ్రం",
        "ta": "பைப்பர் நிக்ரம்",
        "kn": "ಪೈಪರ್ ನೈಗ್ರಮ್",
      },
      "local_names": {
        "en":
            "Hindi: Kali mirch, Telugu: Miriyalu, Tamil: Milagu, Kannada: Menasu",
        "hi": "तेलुगु: मिरियालु, हिंदी: काली मिर्च, तमिल: மிளகு, कन्नड़: ಮೆಣಸು",

        "te": "తెలుగు: మిరియాలు, హిందీ: काली मिर्च, తమిళం: மிளகு, కన్నಡ: ಮೆಣಸು",

        "ta":
            "தெலுங்கு: மிரியாலு, இந்தி: काली मिर्च, தமிழ்: மிளகு, கன்னಡ: ಮೆಣಸು",

        "kn": "ತೆಲುಗು: ಮಿರಿಯಾಲು, ಹಿಂದಿ: काली मिर्च, ತಮಿಳು: மிளகு, ಕನ್ನಡ: ಮೆಣಸು",
      },
      "side_effects": {
        "en":
            "Excess consumption may irritate the stomach lining, cause acidity, or worsen ulcers.",
        "hi": "अधिक सेवन से पेट में जलन या एसिडिटी हो सकती है।",
        "te": "అధికంగా తీసుకుంటే కడుపు మంట లేదా ఆమ్లత్వం పెరుగుతుంది.",
        "ta":
            "அதிகமாக எடுத்தால் வயிற்று எரிச்சல் அல்லது அமிலத்தன்மை ஏற்படலாம்.",
        "kn": "ಅತಿಯಾಗಿ ಸೇವಿಸಿದರೆ ಹೊಟ್ಟೆ ಉರಿ ಅಥವಾ ಆಮ್ಲತೆ ಉಂಟಾಗಬಹುದು.",
      },
    },

    "Pomegranate": {
      "name": {
        "en": "Pomegranate",
        "hi": "अनार",
        "te": "దానిమ్మ",
        "ta": "மாதுளை",
        "kn": "ದಾಳಿಂಬೆ",
      },
      "description": {
        "en":
            "Pomegranate (Punica granatum) is a nutrient-rich fruit containing antioxidants like punicalagins, anthocyanins, vitamin C, vitamin K, potassium and dietary fiber. The fruit, peel and flowers are widely used in traditional medicine for heart health, digestion support, inflammation reduction and blood purification.",
        "hi":
            "अनार (Punica granatum) एक पोषक तत्वों से भरपूर फल है जिसमें पुनीकालागिन, एंथोसायनिन, विटामिन C, विटामिन K, पोटैशियम और फाइबर पाए जाते हैं। फल, छिलका और फूल पारंपरिक चिकित्सा में हृदय स्वास्थ्य, पाचन सुधार, सूजन कम करने और रक्त शुद्धिकरण के लिए उपयोग किए जाते हैं।",
        "te":
            "దానిమ్మ (Punica granatum) పోషకాలతో సమృద్ధిగా ఉండే పండు. ఇందులో పునికలాజిన్స్, ఆంథోసయానిన్స్, విటమిన్ C, విటమిన్ K, పొటాషియం మరియు ఫైబర్ ఉన్నాయి. పండు, తొక్క మరియు పువ్వులు సంప్రదాయ వైద్యంలో గుండె ఆరోగ్యం, జీర్ణక్రియ మెరుగుదల, వాపు తగ్గింపు మరియు రక్త శుద్ధికి ఉపయోగిస్తారు.",
        "ta":
            "மாதுளை (Punica granatum) சத்துக்கள் நிறைந்த பழம். இதில் புனிகலாஜின், ஆன்தோசயனின், வைட்டமின் C, வைட்டமின் K, பொட்டாசியம் மற்றும் நார்ச்சத்து உள்ளது. பழம், தோல் மற்றும் பூ பாரம்பரிய மருத்துவத்தில் இதய ஆரோக்கியம், செரிமானம், அழற்சி குறைப்பு மற்றும் இரத்த சுத்திகரிப்புக்கு பயன்படுகிறது.",
        "kn":
            "ದಾಳಿಂಬೆ (Punica granatum) ಪೋಷಕಾಂಶಗಳ ಸಮೃದ್ಧ ಹಣ್ಣು. ಇದರಲ್ಲಿ ಪುನಿಕಲಾಜಿನ್, ಆಂಥೋಸಯಾನಿನ್, ವಿಟಮಿನ್ C, ವಿಟಮಿನ್ K, ಪೊಟ್ಯಾಸಿಯಮ್ ಮತ್ತು ನಾರು ಇರುತ್ತದೆ. ಹಣ್ಣು, ತೊಳೆ ಮತ್ತು ಹೂವುಗಳನ್ನು ಹೃದಯ ಆರೋಗ್ಯ, ಜೀರ್ಣಕ್ರಿಯೆ ಮತ್ತು ರಕ್ತ ಶುದ್ಧೀಕರಣಕ್ಕೆ ಬಳಸುತ್ತಾರೆ.",
      },
      "uses": {
        "en":
            "Improves hemoglobin levels, supports heart health, aids digestion, reduces inflammation, boosts immunity and promotes healthy skin.",
        "hi":
            "हीमोग्लोबिन बढ़ाता है, हृदय स्वास्थ्य सुधारता है, पाचन में सहायक, सूजन कम करता है, प्रतिरक्षा बढ़ाता है और त्वचा को स्वस्थ बनाता है।",
        "te":
            "హీమోగ్లోబిన్ పెంచుతుంది, గుండె ఆరోగ్యానికి సహాయపడుతుంది, జీర్ణక్రియ మెరుగుపరుస్తుంది, వాపు తగ్గిస్తుంది, రోగనిరోధక శక్తి పెంచుతుంది మరియు చర్మాన్ని ఆరోగ్యంగా ఉంచుతుంది.",
        "ta":
            "ஹீமோகுளோபின் அதிகரிக்கும், இதய ஆரோக்கியம் மேம்படும், செரிமானத்திற்கு உதவும், அழற்சி குறைக்கும், நோய் எதிர்ப்பு சக்தி உயர்த்தும் மற்றும் தோல் ஆரோக்கியம் மேம்படும்.",
        "kn":
            "ಹಿಮೋಗ್ಲೋಬಿನ್ ಹೆಚ್ಚಿಸುತ್ತದೆ, ಹೃದಯ ಆರೋಗ್ಯ ಸುಧಾರಿಸುತ್ತದೆ, ಜೀರ್ಣಕ್ರಿಯೆಗೆ ಸಹಾಯ, ಉರಿಯೂತ ಕಡಿಮೆ ಮಾಡುತ್ತದೆ, ರೋಗನಿರೋಧಕ ಶಕ್ತಿ ಹೆಚ್ಚಿಸುತ್ತದೆ ಮತ್ತು ಚರ್ಮ ಆರೋಗ್ಯ ಸುಧಾರಿಸುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Pomegranate juice is often recommended during anemia recovery. Peel powder is traditionally used for diarrhea and oral health, while seed oil is used in skincare for anti-aging benefits.",
        "hi":
            "एनीमिया में अनार का रस उपयोगी माना जाता है। छिलके का चूर्ण दस्त और मुख स्वास्थ्य के लिए तथा बीज का तेल त्वचा की देखभाल में उपयोग किया जाता है।",
        "te":
            "అనీమియాలో దానిమ్మ రసం ఉపయోగకరం. తొక్క పొడి విరేచనాలు మరియు నోటి ఆరోగ్యానికి, గింజల నూనె చర్మ సంరక్షణకు ఉపయోగిస్తారు.",
        "ta":
            "அனீமியாவில் மாதுளை சாறு பயன்படுத்தப்படுகிறது. தோல் பொடி வயிற்றுப்போக்கு மற்றும் வாய் ஆரோக்கியத்திற்கு, விதை எண்ணெய் தோல் பராமரிப்பிற்கு பயன்படுகிறது.",
        "kn":
            "ಅನೀಮಿಯಾದಲ್ಲಿ ದಾಳಿಂಬೆ ರಸ ಉಪಯುಕ್ತ. ತೊಳೆ ಪುಡಿ ಅತಿಸಾರ ಮತ್ತು ಬಾಯಿ ಆರೋಗ್ಯಕ್ಕೆ, ಬೀಜದ ಎಣ್ಣೆ ಚರ್ಮ ಸಂರಕ್ಷಣೆಗೆ ಬಳಸುತ್ತಾರೆ.",
      },
      "scientific_name": {
        "en": "Punica granatum",
        "hi": "प्यूनिका ग्रेनाटम",
        "te": "ప్యూనికా గ్రానాటమ్",
        "ta": "ப்யூனிகா கிரானாட்டம்",
        "kn": "ಪ್ಯುನಿಕಾ ಗ್ರಾನಾಟಮ್",
      },
      "local_names": {
        "en": "Hindi: Anar, Telugu: Danimma, Tamil: Mathulai, Kannada: Dalimbe",
        "hi": "तेलुगु: दानिम्म, हिंदी: अनार, तमिल: மாதுளை, कन्नड़: ದಾಳಿಂಬೆ",

        "te": "తెలుగు: దానిమ్మ, హిందీ: अनार, తమిళం: மாதுளை, కన్నడ: ದಾಳಿಂಬೆ",

        "ta": "தெலுங்கு: தானிம்ம, இந்தி: अनार, தமிழ்: மாதுளை, கன்னಡ: ದಾಳಿಂಬೆ",

        "kn": "ತೆಲುಗು: ದಾನಿಮ್ಮ, ಹಿಂದಿ: अनार, ತಮಿಳು: மாதுளை, ಕನ್ನಡ: ದಾಳಿಂಬೆ",
      },
      "side_effects": {
        "en":
            "Excess intake may cause digestive discomfort in sensitive individuals and may interact with certain blood pressure medications.",
        "hi":
            "अधिक सेवन से कुछ लोगों में पाचन समस्या हो सकती है और यह रक्तचाप की दवाओं के साथ प्रतिक्रिया कर सकता है।",
        "te":
            "అధికంగా తీసుకుంటే కొంతమందిలో జీర్ణ సమస్యలు రావచ్చు మరియు రక్తపోటు మందులతో ప్రతిక్రియ కలిగించవచ్చు.",
        "ta":
            "அதிகமாக உட்கொண்டால் செரிமான பிரச்சனை மற்றும் இரத்த அழுத்த மருந்துகளுடன் தொடர்பு ஏற்படலாம்.",
        "kn":
            "ಹೆಚ್ಚು ಸೇವನೆ ಜೀರ್ಣ ಸಮಸ್ಯೆ ಉಂಟುಮಾಡಬಹುದು ಮತ್ತು ರಕ್ತದೊತ್ತಡ ಔಷಧಿಗಳೊಂದಿಗೆ ಪ್ರತಿಕ್ರಿಯಿಸಬಹುದು.",
      },
    },

    "Raktachandini": {
      "name": {
        "en": "Red Sandalwood",
        "hi": "लाल चंदन",
        "te": "ఎర్ర చందనం",
        "ta": "செங்கச்சந்தனம்",
        "kn": "ರಕ್ತ ಚಂದನ",
      },
      "description": {
        "en":
            "Red sandalwood is a rare and valuable medicinal wood known for its cooling, anti-inflammatory, and skin-healing properties. It has been used in traditional medicine and rituals for centuries.",
        "hi":
            "लाल चंदन एक दुर्लभ और मूल्यवान औषधीय लकड़ी है जो ठंडक और सूजन कम करने वाले गुणों के लिए प्रसिद्ध है।",
        "te":
            "ఎర్ర చందనం శీతల లక్షణాలు కలిగిన విలువైన ఔషధ కలప, ఇది సంప్రదాయ వైద్యంలో ఎంతో కాలంగా ఉపయోగిస్తున్నారు.",
        "ta":
            "செங்கச்சந்தனம் குளிர்ச்சி மற்றும் அழற்சி குறைக்கும் தன்மை கொண்ட அரிய மருத்துவ மரமாகும்.",
        "kn":
            "ರಕ್ತ ಚಂದನ ಶೀತಲ ಮತ್ತು ಉರಿಯೂತ ಕಡಿಮೆ ಮಾಡುವ ಗುಣಗಳಿರುವ ಅಪರೂಪದ ಔಷಧೀಯ ಮರವಾಗಿದೆ.",
      },
      "uses": {
        "en":
            "Used in skin care to treat acne, rashes, pigmentation, and in traditional remedies for fever and inflammation.",
        "hi": "त्वचा रोग, मुंहासे, जलन और बुखार में उपयोग किया जाता है।",
        "te": "మొటిమలు, చర్మ మచ్చలు, జ్వరం మరియు వాపు చికిత్సలో ఉపయోగిస్తారు.",
        "ta":
            "முகப்பரு, தோல் அரிப்பு, காய்ச்சல் மற்றும் அழற்சி சிகிச்சையில் பயன்படும்.",
        "kn":
            "ಮೊಡವೆ, ಚರ್ಮದ ತೊಂದರೆಗಳು, ಜ್ವರ ಮತ್ತು ಉರಿಯೂತ ಚಿಕಿತ್ಸೆಗಾಗಿ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "The powdered heartwood is commonly used as a paste for cooling the body, improving complexion, and in Ayurvedic and Siddha medicine preparations.",
        "hi":
            "इसकी लकड़ी का चूर्ण शरीर को ठंडक देने और त्वचा निखारने के लिए प्रयोग होता है।",
        "te":
            "దీని గుండె కలప పొడిని శరీర శీతలీకరణ మరియు చర్మ కాంతి కోసం ఉపయోగిస్తారు.",
        "ta":
            "உடலை குளிர்விக்கவும், தோல் நிறத்தை மேம்படுத்தவும் இதன் தூள் பயன்படுத்தப்படுகிறது.",
        "kn": "ದೇಹ ಶೀತೀಕರಣ ಮತ್ತು ಚರ್ಮ ಕಾಂತಿಯಿಗಾಗಿ ಇದರ ಪುಡಿ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Pterocarpus santalinus",
        "hi": "प्टेरोकार्पस सैंटालिनस",
        "te": "ప్టెరోకార్పస్ సాంటాలినస్",
        "ta": "ப்டெரோகர்பஸ் சாண்டாலினஸ்",
        "kn": "ಪ್ಟೆರೋಕಾರ್ಪಸ್ ಸ್ಯಾಂಟಾಲಿನಸ್",
      },
      "local_names": {
        "en":
            "Hindi: Lal chandan, Telugu: Erra chandanam, Tamil: Senga chandanam, Kannada: Rakta chandana",
        "hi":
            "तेलुगु: एर्र चंदनम, हिंदी: लाल चंदन, तमिल: செங்கச்சந்தனம், कन्नड़: ರಕ್ತ ಚಂದನ",

        "te":
            "తెలుగు: ఎర్ర చందనం, హిందీ: लाल चंदन, తమిళం: செங்கச்சந்தனம், కన్నಡ: ರಕ್ತ ಚಂದನ",

        "ta":
            "தெலுங்கு: எர்ர சந்தனம், இந்தி: लाल चंदन, தமிழ்: செங்கச்சந்தனம், கன்னಡ: ರಕ್ತ ಚಂದನ",

        "kn":
            "ತೆಲುಗು: ಎರ್ರ ಚಂದನಂ, ಹಿಂದಿ: लाल चंदन, ತಮಿಳು: செங்கச்சந்தனம், ಕನ್ನಡ: ರಕ್ತ ಚಂದನ",
      },
      "side_effects": {
        "en":
            "Excessive use or inhalation of fine powder may cause respiratory irritation; internal use should be only under medical guidance.",
        "hi": "अधिक उपयोग या धूल सांस में जाने से समस्या हो सकती है।",
        "te": "అధిక వినియోగం లేదా పొడి శ్వాసలోకి వెళ్లితే ఇబ్బంది కలగవచ్చు.",
        "ta": "அதிகப் பயன்பாடு அல்லது தூசி சுவாசத்தில் பாதிப்பை ஏற்படுத்தலாம்.",
        "kn": "ಅತಿಯಾದ ಬಳಕೆ ಅಥವಾ ಪುಡಿ ಉಸಿರಾಟಕ್ಕೆ ತೊಂದರೆ ಉಂಟುಮಾಡಬಹುದು.",
      },
    },

    "Rose": {
      "name": {
        "en": "Rose",
        "hi": "गुलाब",
        "te": "రోజా",
        "ta": "ரோஜா",
        "kn": "ಗುಲಾಬಿ",
      },
      "description": {
        "en":
            "Rose (Rosa indica) is a fragrant flowering plant rich in natural oils, flavonoids, anthocyanins, vitamin C and antioxidants. Petals contain soothing, anti-inflammatory and cooling compounds that help calm skin irritation, regulate body heat and support emotional relaxation in traditional medicine systems like Ayurveda and Unani.",
        "hi":
            "गुलाब (Rosa indica) एक सुगंधित पुष्पीय पौधा है जिसमें प्राकृतिक तेल, फ्लेवोनॉयड्स, एंथोसाइनिन, विटामिन C और एंटीऑक्सीडेंट पाए जाते हैं। इसकी पंखुड़ियों में शीतल, सूजनरोधी गुण होते हैं जो त्वचा की जलन कम करते हैं, शरीर की गर्मी संतुलित करते हैं और आयुर्वेद तथा यूनानी चिकित्सा में मानसिक शांति प्रदान करते हैं।",
        "te":
            "రోజా (Rosa indica) సహజ తైలాలు, ఫ్లేవనాయిడ్లు, ఆంథోసయానిన్లు, విటమిన్ C మరియు యాంటీఆక్సిడెంట్లు కలిగిన సువాసన పుష్ప మొక్క. దీని రేకులు చల్లదనం, వాపు తగ్గింపు మరియు చర్మ శాంతి లక్షణాలు కలిగి ఉండి ఆయుర్వేదం మరియు యునాని వైద్యంలో శరీర ఉష్ణోగ్రత నియంత్రణకు మరియు మానసిక ప్రశాంతతకు ఉపయోగిస్తారు.",
        "ta":
            "ரோஜா (Rosa indica) இயற்கை எண்ணெய்கள், ஃப்ளேவனாய்டுகள், அந்தோசயனின், வைட்டமின் C மற்றும் ஆன்டி-ஆக்ஸிடென்ட்கள் நிறைந்த மணமுள்ள மலர் செடி. இதன் இதழ்கள் குளிர்ச்சி மற்றும் அழற்சி எதிர்ப்பு தன்மை கொண்டவை; தோல் எரிச்சலை குறைத்து உடல் சூட்டை சமநிலைப்படுத்தி ஆயுர்வேத மற்றும் யுனானி மருத்துவத்தில் மன அமைதிக்குப் பயன்படுகிறது.",
        "kn":
            "ಗುಲಾಬಿ (Rosa indica) ಸಹಜ ತೈಲಗಳು, ಫ್ಲೇವನಾಯ್ಡ್ಸ್, ಆಂಥೋಸಯಾನಿನ್ಸ್, ವಿಟಮಿನ್ C ಮತ್ತು ಆಂಟಿಆಕ್ಸಿಡೆಂಟ್‌ಗಳಿಂದ ಸಮೃದ್ಧ ಸುಗಂಧ ಹೂವು. ಇದರ ದಳಗಳು ಶೀತಲ ಮತ್ತು ಉರಿಯೂತ ನಿವಾರಕ ಗುಣಗಳನ್ನು ಹೊಂದಿದ್ದು ಚರ್ಮದ ಕೆದರಿಕೆ ಕಡಿಮೆ ಮಾಡುತ್ತವೆ, ದೇಹದ ಉಷ್ಣತೆ ಸಮತೋಲನಗೊಳಿಸುತ್ತವೆ ಮತ್ತು ಆಯುರ್ವೇದ ಹಾಗೂ ಯುನಾನಿ ಚಿಕಿತ್ಸೆಯಲ್ಲಿ ಮನಶಾಂತಿಗೆ ಸಹಾಯ ಮಾಡುತ್ತವೆ.",
      },
      "uses": {
        "en":
            "Hydrates and tones skin, reduces acne redness, cools the body during heat conditions, supports digestion, relieves mild headache and improves mood through aroma therapy.",
        "hi":
            "त्वचा को नम और टोन करता है, मुंहासों की लालिमा कम करता है, गर्मी में शरीर को ठंडक देता है, पाचन में सहायक है, हल्के सिरदर्द में राहत देता है और सुगंध द्वारा मन को शांत करता है।",
        "te":
            "చర్మాన్ని తేమగా ఉంచి టోన్ చేస్తుంది, మొటిమల ఎర్రదనాన్ని తగ్గిస్తుంది, వేసవిలో శరీరాన్ని చల్లగా ఉంచుతుంది, జీర్ణక్రియకు సహాయపడుతుంది, తలనొప్పి తగ్గిస్తుంది మరియు వాసన ద్వారా మానసిక ప్రశాంతత ఇస్తుంది.",
        "ta":
            "தோலை ஈரப்பதமாக வைத்துப் பராமரிக்கும், முகப்பரு சிவப்பை குறைக்கும், உடல் சூட்டை தணிக்கும், செரிமானத்திற்கு உதவும், லேசான தலைவலியை குறைக்கும் மற்றும் மணத்தின் மூலம் மன அமைதியை அளிக்கும்.",
        "kn":
            "ಚರ್ಮವನ್ನು ತೇವಗೊಳಿಸಿ ಟೋನ್ ಮಾಡುತ್ತದೆ, ಮೊಡವೆ ಕೆಂಪು ಕಡಿಮೆ ಮಾಡುತ್ತದೆ, ಬೇಸಿಗೆಯಲ್ಲಿ ದೇಹ ತಂಪಾಗಿರಲು ಸಹಾಯ, ಜೀರ್ಣಕ್ರಿಯೆಗೆ ಉಪಕಾರಿ, ಸಣ್ಣ ತಲೆನೋವು ಕಡಿಮೆ ಮಾಡುತ್ತದೆ ಮತ್ತು ಸುಗಂಧದಿಂದ ಮನಶಾಂತಿ ನೀಡುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Rose water is widely used as an eye cleanser, face toner and cooling drink. Dried petals are used in herbal teas, gulkand and digestive preparations. The essential oil is valued in aromatherapy for stress relief and emotional balance.",
        "hi":
            "गुलाब जल आंखों की सफाई, फेस टोनर और शीतल पेय के रूप में उपयोग होता है। सूखी पंखुड़ियां चाय, गुलकंद और पाचन औषधि में प्रयुक्त होती हैं। इसका तेल तनाव कम करने और मानसिक संतुलन के लिए अरोमाथेरेपी में महत्वपूर्ण है।",
        "te":
            "రోజా నీరు కంటి శుభ్రత, ఫేస్ టోనర్ మరియు చల్లని పానీయంగా ఉపయోగిస్తారు. ఎండిన రేకులు టీ, గుల్కండ్ మరియు జీర్ణ మందుల్లో వాడతారు. తైలము ఒత్తిడి తగ్గించేందుకు అరోమాథెరపీలో ఉపయోగిస్తారు.",
        "ta":
            "ரோஜா தண்ணீர் கண் சுத்திகரிப்பு, முக டோனர் மற்றும் குளிர்பானமாக பயன்படுகிறது. உலர்ந்த இதழ்கள் டீ, குல்கந்த் மற்றும் செரிமான மருந்துகளில் பயன்படுத்தப்படுகின்றன. எண்ணெய் மன அழுத்தத்தை குறைக்க அரோமாதெரபியில் பயன்படுகிறது.",
        "kn":
            "ಗುಲಾಬಿ ನೀರು ಕಣ್ಣಿನ ಶುದ್ಧೀಕರಣ, ಮುಖ ಟೋನರ್ ಮತ್ತು ತಂಪು ಪಾನೀಯವಾಗಿ ಬಳಸುತ್ತಾರೆ. ಒಣ ದಳಗಳನ್ನು ಟೀ, ಗುಲ್ಕಂದ್ ಮತ್ತು ಜೀರ್ಣ ಔಷಧಿಗಳಲ್ಲಿ ಬಳಸುತ್ತಾರೆ. ತೈಲವನ್ನು ಒತ್ತಡ ನಿವಾರಣೆಗೆ ಅರೋಮಾಥೆರಪಿಯಲ್ಲಿ ಉಪಯೋಗಿಸುತ್ತಾರೆ.",
      },
      "scientific_name": {
        "en": "Rosa indica",
        "hi": "रोसा इंडिका",
        "te": "రోసా ఇండికా",
        "ta": "ரோசா இன்டிகா",
        "kn": "ರೋಸಾ ಇಂಡಿಕಾ",
      },
      "local_names": {
        "en": "Hindi: Gulab, Telugu: Roja, Tamil: Roja, Kannada: Gulabi",
        "hi": "तेलुगु: रोजा, हिंदी: गुलाब, तमिल: ரோஜா, कन्नड़: ಗುಲಾಬಿ",

        "te": "తెలుగు: రోజా, హిందీ: गुलाब, తమిళం: ரோஜா, కన్నಡ: ಗುಲಾಬಿ",

        "ta": "தெலுங்கு: ரோஜா, இந்தி: गुलाब, தமிழ்: ரோஜா, கன்னಡ: ಗುಲಾಬಿ",

        "kn": "ತೆಲುಗು: ರೋಜಾ, ಹಿಂದಿ: गुलाब, ತಮಿಳು: ரோஜா, ಕನ್ನಡ: ಗುಲಾಬಿ",
      },
      "side_effects": {
        "en":
            "Highly concentrated rose oil may cause irritation in sensitive skin; contaminated rose water may cause eye irritation if not pure.",
        "hi":
            "अधिक सघन गुलाब तेल संवेदनशील त्वचा में जलन कर सकता है; अशुद्ध गुलाब जल आंखों में जलन पैदा कर सकता है।",
        "te":
            "అధిక సాంద్రత ఉన్న రోజా తైలము సున్నితమైన చర్మంలో రాపిడి కలిగించవచ్చు; అపరిశుభ్రమైన రోజా నీరు కళ్లకు ఇబ్బంది కలిగిస్తుంది.",
        "ta":
            "அதிக செறிவுள்ள ரோஜா எண்ணெய் உணர்வெழுச்சி தோலில் எரிச்சல் தரலாம்; தூய்மையற்ற ரோஜா நீர் கண் எரிச்சலை ஏற்படுத்தலாம்.",
        "kn":
            "ಅತಿಯಾಗಿ ಸಾಂದ್ರ ಗುಲಾಬಿ ತೈಲ ಸಂವೇದನಾಶೀಲ ಚರ್ಮದಲ್ಲಿ ಕೆದರಿಕೆ ಉಂಟುಮಾಡಬಹುದು; ಅಶುದ್ಧ ಗುಲಾಬಿ ನೀರು ಕಣ್ಣಿಗೆ ಕೆರಳಿಕೆ ತರಬಹುದು.",
      },
    },

    "Sapota": {
      "name": {
        "en": "Sapota",
        "hi": "चीकू",
        "te": "సపోటా",
        "ta": "சப்போட்டா",
        "kn": "ಚಿಕ್ಕು",
      },
      "description": {
        "en":
            "Sapota is a sweet, soft, and highly nutritious tropical fruit rich in natural sugars, dietary fiber, vitamins, and minerals that support overall health.",
        "hi":
            "चीकू एक मीठा और पौष्टिक उष्णकटिबंधीय फल है जिसमें प्राकृतिक शर्करा, फाइबर और विटामिन प्रचुर मात्रा में होते हैं।",
        "te":
            "సపోటా సహజ చక్కెరలు, ఫైబర్ మరియు విటమిన్లు కలిగిన పోషకమైన ఉష్ణమండల పండు.",
        "ta":
            "சப்போட்டா இயற்கை சர்க்கரை, நார் மற்றும் சத்துக்கள் நிறைந்த ஊட்டச்சத்து மிகுந்த பழமாகும்.",
        "kn":
            "ಚಿಕ್ಕು ಸಹಜ ಸಕ್ಕರೆ, ನಾರು ಮತ್ತು ಪೋಷಕಾಂಶಗಳಿಂದ ಸಮೃದ್ಧವಾದ ಉಷ್ಣವಲಯದ ಹಣ್ಣಾಗಿದೆ.",
      },
      "uses": {
        "en":
            "Provides instant energy, improves digestion, prevents constipation, and supports bone and muscle health.",
        "hi": "तुरंत ऊर्जा देता है, पाचन सुधारता है और कब्ज से बचाता है।",
        "te":
            "తక్షణ శక్తినిస్తుంది, జీర్ణక్రియను మెరుగుపరుస్తుంది మరియు మలబద్ధకం నివారిస్తుంది.",
        "ta":
            "உடனடி ஆற்றல் வழங்கி, செரிமானத்தை மேம்படுத்தி மலச்சிக்கலைத் தடுக்க உதவுகிறது.",
        "kn":
            "ತಕ್ಷಣ ಶಕ್ತಿ ನೀಡುತ್ತದೆ, ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಿಸಿ ಮಲಬದ್ಧತೆ ತಡೆಯುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Rich in antioxidants like polyphenols and vitamin C; commonly consumed fresh, in milkshakes, smoothies, desserts, and baby foods.",
        "hi":
            "एंटीऑक्सीडेंट और विटामिन C से भरपूर, दूध शेक और मिठाइयों में उपयोग होता है।",
        "te":
            "యాంటీఆక్సిడెంట్లు మరియు విటమిన్ C సమృద్ధిగా ఉండి, మిల్క్‌షేక్‌లు మరియు స్వీట్లలో వాడతారు.",
        "ta":
            "ஆன்டி ஆக்ஸிடென்ட்கள் மற்றும் வைட்டமின் C நிறைந்தது; மில்க்‌ஷேக் மற்றும் இனிப்புகளில் பயன்படுத்தப்படுகிறது.",
        "kn":
            "ಆಂಟಿಆಕ್ಸಿಡೆಂಟ್ ಮತ್ತು ವಿಟಮಿನ್ C ಸಮೃದ್ಧವಾಗಿದ್ದು, ಮಿಲ್ಕ್‌ಶೇಕ್ ಮತ್ತು ಡೆಸರ್ಟ್‌ಗಳಲ್ಲಿ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "scientific_name": {
        "en": "Manilkara zapota",
        "hi": "मेनिलकारा ज़पोटा",
        "te": "మానిల్కరా జపోటా",
        "ta": "மனில்கரா சபோட்டா",
        "kn": "ಮನಿಲ್ಕರಾ ಜಪೋಟಾ",
      },
      "local_names": {
        "en": "Hindi: Chikoo, Telugu: Sapota, Tamil: Sapota, Kannada: Chikku",
        "hi": "तेलुगु: सपोटा, हिंदी: चीकू, तमिल: சப்போட்டா, कन्नड़: ಚಿಕ್ಕು",

        "te": "తెలుగు: సపోటా, హిందీ: चीकू, తమిళం: சப்போட்டா, కన్నಡ: ಚಿಕ್ಕು",

        "ta": "தெலுங்கு: சபோட்டா, இந்தி: चीकू, தமிழ்: சப்போட்டா, கன்னಡ: ಚಿಕ್ಕು",

        "kn": "ತೆಲುಗು: ಸಪೋಟಾ, ಹಿಂದಿ: चीकू, ತಮಿಳು: சப்போட்டா, ಕನ್ನಡ: ಚಿಕ್ಕು",
      },
      "side_effects": {
        "en":
            "Unripe sapota contains latex which may cause throat irritation, mouth itching, or digestive discomfort if consumed.",
        "hi": "कच्चे चीकू में लेटेक्स होता है जिससे गले में जलन हो सकती है।",
        "te":
            "ముడి సపోటాలో లాటెక్స్ ఉండి గొంతు మంట లేదా జీర్ణ సమస్యలు కలిగించవచ్చు.",
        "ta":
            "முழுமையாக பழுக்காத சப்போட்டா தொண்டை எரிச்சல் அல்லது செரிமான கோளாறு ஏற்படுத்தலாம்.",
        "kn":
            "ಪೂರ್ಣವಾಗಿ ಹಣ್ಣಾಗದ ಚಿಕ್ಕು ಗಂಟಲು ಕೆರಡು ಅಥವಾ ಜೀರ್ಣ ತೊಂದರೆ ಉಂಟುಮಾಡಬಹುದು.",
      },
    },

    "Tulasi": {
      "name": {
        "en": "Tulasi",
        "hi": "तुलसी",
        "te": "తులసి",
        "ta": "துளசி",
        "kn": "ತುಳಸಿ",
      },
      "description": {
        "en":
            "Tulasi (Ocimum tenuiflorum) is a sacred aromatic medicinal herb widely used in Ayurveda. The leaves contain eugenol, ursolic acid, rosmarinic acid and powerful antioxidants that help fight infections, inflammation and environmental stress. It is considered an adaptogenic herb that supports respiratory health, metabolism and overall immunity.",
        "hi":
            "तुलसी (Ocimum tenuiflorum) एक पवित्र सुगंधित औषधीय पौधा है जिसका आयुर्वेद में व्यापक उपयोग होता है। इसकी पत्तियों में यूजेनॉल, उर्सोलिक एसिड, रोसमेरिनिक एसिड और शक्तिशाली एंटीऑक्सीडेंट होते हैं जो संक्रमण और सूजन से रक्षा करते हैं। यह एक एडैप्टोजेनिक जड़ी-बूटी मानी जाती है जो श्वसन स्वास्थ्य, चयापचय और प्रतिरक्षा को मजबूत करती है।",
        "te":
            "తులసి (Ocimum tenuiflorum) పవిత్ర సుగంధ ఔషధ మొక్కగా ఆయుర్వేదంలో విస్తృతంగా ఉపయోగిస్తారు. దీని ఆకుల్లో యూజినాల్, ఉర్సోలిక్ ఆమ్లం, రోస్మెరినిక్ ఆమ్లం మరియు శక్తివంతమైన యాంటీఆక్సిడెంట్లు ఉండి సంక్రమణలు, వాపు మరియు కాలుష్య ప్రభావాల నుండి రక్షిస్తాయి. ఇది అడాప్టోజెనిక్ మొక్కగా శ్వాసకోశ ఆరోగ్యం, మెటబాలిజం మరియు రోగనిరోధక శక్తిని పెంచుతుంది.",
        "ta":
            "துளசி (Ocimum tenuiflorum) ஆயுர்வேதத்தில் முக்கியமான புனித மணமுள்ள மூலிகை. இதன் இலைகளில் யூஜினால், உர்சோலிக் அமிலம், ரோஸ்மெரினிக் அமிலம் மற்றும் சக்திவாய்ந்த ஆன்டி-ஆக்ஸிடென்ட்கள் உள்ளன; அவை தொற்று மற்றும் அழற்சியிலிருந்து பாதுகாக்கும். இது அடாப்டோஜெனிக் மூலிகையாக சுவாச ஆரோக்கியம் மற்றும் நோய் எதிர்ப்பு சக்தியை மேம்படுத்துகிறது.",
        "kn":
            "ತುಳಸಿ (Ocimum tenuiflorum) ಆಯುರ್ವೇದದಲ್ಲಿ ಬಹಳ ಪ್ರಸಿದ್ಧವಾದ ಪವಿತ್ರ ಸುಗಂಧ ಔಷಧೀಯ ಗಿಡ. ಇದರ ಎಲೆಗಳಲ್ಲಿ ಯೂಜೆನಾಲ್, ಉರ್ಸೋಲಿಕ್ ಆಮ್ಲ, ರೋಸ್ಮೆರಿನಿಕ್ ಆಮ್ಲ ಮತ್ತು ಶಕ್ತಿಶಾಲಿ ಆಂಟಿಆಕ್ಸಿಡೆಂಟ್‌ಗಳು ಇದ್ದು ಸೋಂಕು ಹಾಗೂ ಉರಿಯೂತದಿಂದ ರಕ್ಷಿಸುತ್ತವೆ. ಇದು ಅಡಾಪ್ಟೋಜೆನಿಕ್ ಸಸ್ಯವಾಗಿ ಶ್ವಾಸಕೋಶ ಆರೋಗ್ಯ ಮತ್ತು ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿಯನ್ನು ಹೆಚ್ಚಿಸುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Relieves cough, cold and sore throat, boosts immunity, supports digestion, reduces stress and anxiety, helps regulate blood sugar and improves respiratory function.",
        "hi":
            "खांसी-जुकाम और गले की खराश में राहत, प्रतिरक्षा बढ़ाती है, पाचन सुधारती है, तनाव कम करती है, रक्त शर्करा संतुलित करने और श्वसन क्रिया सुधारने में सहायक है।",
        "te":
            "దగ్గు, జలుబు మరియు గొంతు నొప్పి తగ్గిస్తుంది, రోగనిరోధక శక్తి పెంచుతుంది, జీర్ణక confirmingషణ మెరుగుపరుస్తుంది, ఒత్తిడి తగ్గిస్తుంది, రక్తంలో చక్కెర నియంత్రణకు మరియు శ్వాసకోశ పనితీరుకు సహాయపడుతుంది.",
        "ta":
            "இருமல் மற்றும் சளி குறைக்கும், நோய் எதிர்ப்பு சக்தி அதிகரிக்கும், செரிமானம் மேம்படும், மன அழுத்தம் குறையும், ரத்த சர்க்கரை சமநிலைப்படுத்தவும் சுவாச செயல்பாட்டை மேம்படுத்தவும் உதவும்.",
        "kn":
            "ಕೆಮ್ಮು ಮತ್ತು ಶೀತ ನಿವಾರಣೆ, ರೋಗ ನಿರೋಧಕ ಶಕ್ತಿ ಹೆಚ್ಚಿಸುವುದು, ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಣೆ, ಒತ್ತಡ ಕಡಿಮೆ, ರಕ್ತ ಸಕ್ಕರೆ ಸಮತೋಲನ ಹಾಗೂ ಉಸಿರಾಟ ಕ್ರಿಯೆ ಸುಧಾರಣೆಗೆ ಸಹಾಯಕ.",
      },
      "more_info": {
        "en":
            "Tulasi leaves are consumed fresh, dried or as herbal tea and kadha. The plant is worshipped daily in many Indian homes and believed to purify air due to antimicrobial volatile oils. It is also used in steam inhalation, herbal oils and immunity tonics.",
        "hi":
            "तुलसी की पत्तियां ताजी, सूखी या काढ़े और चाय के रूप में ली जाती हैं। कई भारतीय घरों में इसकी पूजा की जाती है और इसके सुगंधित तेल वायु को शुद्ध करने वाले माने जाते हैं। भाप, तेल और रोग प्रतिरोधक टॉनिक में भी उपयोग होता है।",
        "te":
            "తులసి ఆకులను తాజాగా, ఎండబెట్టి లేదా కషాయం, టీ రూపంలో తీసుకుంటారు. అనేక భారతీయ ఇళ్లలో దీన్ని పూజిస్తారు మరియు దాని వాసన గాలిని శుభ్రపరుస్తుందని నమ్మకం. ఆవిరి పీల్చడం, ఆయిల్ మరియు ఇమ్యూనిటీ టానిక్స్ లో ఉపయోగిస్తారు.",
        "ta":
            "துளசி இலைகள் பச்சையாக, உலர்த்தி அல்லது கஷாயம் மற்றும் தேநீராக பயன்படுத்தப்படுகின்றன. இந்திய வீடுகளில் தினசரி பூஜையில் பயன்படுத்தப்படுகிறது மற்றும் அதன் வாசனை காற்றை சுத்தப்படுத்தும் என நம்பப்படுகிறது. நீராவி மற்றும் மூலிகை எண்ணெய்களிலும் பயன்படும்.",
        "kn":
            "ತುಳಸಿ ಎಲೆಗಳನ್ನು ತಾಜಾ, ಒಣಗಿಸಿ ಅಥವಾ ಕಷಾಯ ಮತ್ತು ಟೀ ರೂಪದಲ್ಲಿ ಸೇವಿಸುತ್ತಾರೆ. ಭಾರತೀಯ ಮನೆಗಳಲ್ಲಿ ಪೂಜೆಯಲ್ಲಿ ಬಳಸಲಾಗುತ್ತದೆ ಮತ್ತು ಇದರ ಸುಗಂಧ ತೈಲ ಗಾಳಿಯನ್ನು ಶುದ್ಧಗೊಳಿಸುತ್ತದೆ ಎಂದು ನಂಬಲಾಗಿದೆ. ಆವಿರ್ ಚಿಕಿತ್ಸೆ ಹಾಗೂ ಔಷಧೀಯ ತೈಲಗಳಲ್ಲಿ ಉಪಯೋಗಿಸುತ್ತಾರೆ.",
      },
      "scientific_name": {
        "en": "Ocimum tenuiflorum",
        "hi": "ओसिमम टेनुइफ्लोरम",
        "te": "ఒసిమమ్ టెనుఇఫ్లోరమ్",
        "ta": "ஒசிமம் டெனுஇப்ளோரம்",
        "kn": "ಒಸಿಮಮ್ ಟೆನುಇಫ್ಲೋರಮ್",
      },
      "local_names": {
        "en": "Hindi: Tulsi, Telugu: Tulasi, Tamil: Thulasi, Kannada: Tulasi",
        "hi": "तेलुगु: तुलसि, हिंदी: तुलसी, तमिल: துளசி, कन्नड़: ತುಳಸಿ",

        "te": "తెలుగు: తులసి, హిందీ: तुलसी, తమిళం: துளசி, కన్నಡ: ತುಳಸಿ",

        "ta": "தெலுங்கு: துலசி, இந்தி: तुलसी, தமிழ்: துளசி, கன்னಡ: ತುಳಸಿ",

        "kn": "ತೆಲುಗು: ತುಲಸಿ, ಹಿಂದಿ: तुलसी, ತಮಿಳು: துளசி, ಕನ್ನಡ: ತುಳಸಿ",
      },
      "side_effects": {
        "en":
            "Excess consumption may thin blood and lower blood sugar excessively; may not be suitable before surgery or during pregnancy in medicinal doses.",
        "hi":
            "अधिक सेवन से रक्त पतला और शुगर कम हो सकती है; शल्यक्रिया से पहले या गर्भावस्था में औषधीय मात्रा में सावधानी आवश्यक है।",
        "te":
            "అధికంగా తీసుకుంటే రక్తం పలుచన అవ్వడం మరియు చక్కెర అధికంగా తగ్గడం జరుగవచ్చు; శస్త్రచికిత్స ముందు లేదా గర్భధారణలో జాగ్రత్త అవసరం.",
        "ta":
            "அதிக அளவு எடுத்தால் இரத்தம் மெல்லியதாகவும் சர்க்கரை அளவு குறையவும் வாய்ப்பு உள்ளது; அறுவை சிகிச்சைக்கு முன் அல்லது கர்ப்ப காலத்தில் கவனம் தேவை.",
        "kn":
            "ಹೆಚ್ಚಾಗಿ ಸೇವಿಸಿದರೆ ರಕ್ತ ತೆಳು ಹಾಗೂ ಸಕ್ಕರೆ ಮಟ್ಟ ಕಡಿಮೆಯಾಗಬಹುದು; ಶಸ್ತ್ರಚಿಕಿತ್ಸೆ ಮೊದಲು ಅಥವಾ ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ಜಾಗ್ರತೆ ಅಗತ್ಯ.",
      },
    },

    "Wood_sorel": {
      "name": {
        "en": "Wood Sorel",
        "hi": "चेंगरी",
        "te": "పులిచింత",
        "ta": "புளியாரை",
        "kn": "ಹುಳಿ ಸೊಪ್ಪು",
      },
      "description": {
        "en":
            "Wood sorrel is a small sour-tasting medicinal herb commonly found in gardens and fields. It is known for its cooling, detoxifying, and digestive-support properties in traditional medicine.",
        "hi":
            "चेंगरी एक खट्टा स्वाद वाला छोटा औषधीय पौधा है जो ठंडक और पाचन सुधारने के गुणों के लिए जाना जाता है।",
        "te":
            "పులిచింత పులుపు రుచితో కూడిన చిన్న ఔషధ మొక్క, ఇది శరీరానికి చల్లదనం మరియు జీర్ణ సహాయాన్ని అందిస్తుంది.",
        "ta":
            "புளியாரை புளிப்பு சுவை கொண்ட சிறிய மருத்துவ செடியாகும், இது உடலை குளிர்வித்து செரிமானத்திற்கு உதவுகிறது.",
        "kn":
            "ಹುಳಿ ಸೊಪ್ಪು ಹುಳಿ ರುಚಿಯುಳ್ಳ ಸಣ್ಣ ಔಷಧೀಯ ಗಿಡವಾಗಿದ್ದು, ದೇಹಕ್ಕೆ ತಂಪು ಮತ್ತು ಜೀರ್ಣಕ್ಕೆ ಸಹಾಯ ಮಾಡುತ್ತದೆ.",
      },
      "uses": {
        "en":
            "Used to improve digestion, reduce body heat, relieve thirst, and manage mild stomach disorders.",
        "hi":
            "पाचन सुधारने, शरीर की गर्मी कम करने और पेट की समस्या में उपयोगी।",
        "te":
            "జీర్ణక్రియ మెరుగుపరచడానికి, శరీర వేడి తగ్గించడానికి మరియు కడుపు సమస్యలకు ఉపయోగిస్తారు.",
        "ta":
            "செரிமானத்தை மேம்படுத்த, உடல் சூட்டை குறைக்க மற்றும் வயிற்று கோளாறுகளில் பயன்படுத்தப்படுகிறது.",
        "kn":
            "ಜೀರ್ಣಕ್ರಿಯೆ ಸುಧಾರಣೆ, ದೇಹದ ಉಷ್ಣ ಕಡಿಮೆ ಮಾಡುವುದು ಮತ್ತು ಹೊಟ್ಟೆ ತೊಂದರೆಗಳಿಗೆ ಬಳಸಲಾಗುತ್ತದೆ.",
      },
      "more_info": {
        "en":
            "Rich in vitamin C, antioxidants, and natural oxalic acid; leaves are sometimes used in small amounts in traditional dishes and herbal preparations.",
        "hi":
            "विटामिन C, एंटीऑक्सीडेंट और प्राकृतिक ऑक्सैलिक एसिड से भरपूर होता है।",
        "te":
            "విటమిన్ C, యాంటీఆక్సిడెంట్లు మరియు సహజ ఆక్సాలిక్ ఆమ్లం ఇందులో ఉంటాయి.",
        "ta":
            "வைட்டமின் C, ஆன்டி ஆக்ஸிடென்ட்கள் மற்றும் இயற்கை ஆக்சாலிக் அமிலம் நிறைந்தது.",
        "kn":
            "ವಿಟಮಿನ್ C, ಆಂಟಿಆಕ್ಸಿಡೆಂಟ್ ಮತ್ತು ಸಹಜ ಆಕ್ಸಾಲಿಕ್ ಆಮ್ಲದಿಂದ ಸಮೃದ್ಧವಾಗಿದೆ.",
      },
      "scientific_name": {
        "en": "Oxalis corniculata",
        "hi": "ऑक्सालिस कॉर्निकुलाटा",
        "te": "ఆక్సాలిస్ కార్నిక్యులాటా",
        "ta": "ஆக்சாலிஸ் கார்னிகுலாட்டா",
        "kn": "ಆಕ್ಸಾಲಿಸ್ ಕಾರ್ನಿಕುಲಾಟಾ",
      },
      "local_names": {
        "en":
            "Hindi: Changeri, Telugu: Pulichinta, Tamil: Puliyarai, Kannada: Huli soppu",
        "hi":
            "तेलुगु: पुलिचिंत, हिंदी: चेंगरी, तमिल: புளியாரை, कन्नड़: ಹುಳಿ ಸೊಪ್ಪು",

        "te":
            "తెలుగు: పులిచింత, హిందీ: चेंगरी, తమిళం: புளியாரை, కన్నಡ: ಹುಳಿ ಸೊಪ್ಪು",

        "ta":
            "தெலுங்கு: புலிசிந்த, இந்தி: चेंगरी, தமிழ்: புளியாரை, கன்னಡ: ಹುಳಿ ಸೊಪ್ಪು",

        "kn":
            "ತೆಲುಗು: ಪುಲಿಚಿಂಟ, ಹಿಂದಿ: चेंगरी, ತಮಿಳು: புளியாரை, ಕನ್ನಡ: ಹುಳಿ ಸೊಪ್ಪು",
      },
      "side_effects": {
        "en":
            "Excessive consumption may increase oxalate levels in the body, potentially contributing to kidney stone formation.",
        "hi":
            "अधिक सेवन से ऑक्सालेट बढ़ सकता है और किडनी स्टोन का खतरा हो सकता है।",
        "te":
            "అధికంగా తీసుకుంటే ఆక్సాలేట్ స్థాయిలు పెరిగి కిడ్నీ రాళ్ల ప్రమాదం ఉండవచ్చు.",
        "ta":
            "அதிகமாக எடுத்தால் ஆக்சாலேட் அளவு அதிகரித்து சிறுநீரக கல் அபாயம் ஏற்படலாம்.",
        "kn":
            "ಅತಿಯಾಗಿ ಸೇವಿಸಿದರೆ ಆಕ್ಸಾಲೇಟ್ ಹೆಚ್ಚಾಗಿ ಕಿಡ್ನಿ ಕಲ್ಲಿನ ಅಪಾಯ ಉಂಟಾಗಬಹುದು.",
      },
    },

    "unknown": {
      "name": {
        "en": "Plant Not Identified",
        "hi": "पौधा पहचान में नहीं आया",
        "te": "మొక్క గుర్తించబడలేదు",
        "ta": "தாவரம் அடையாளம் காணப்படவில்லை",
        "kn": "ಸಸ್ಯವನ್ನು ಗುರುತಿಸಲಾಗಿಲ್ಲ",
      },
      "description": {
        "en":
            "No plant was detected in the image. Please upload a clear photo showing the leaf, stem, or full plant in good lighting and focus.",
        "hi":
            "छवि में कोई पौधा पहचान में नहीं आया। कृपया अच्छी रोशनी और स्पष्टता के साथ पत्ती, तना या पूरा पौधा दिखाने वाली फोटो अपलोड करें।",
        "te":
            "చిత్రంలో ఎలాంటి మొక్క గుర్తించబడలేదు. మంచి వెలుతురు మరియు స్పష్టతతో ఆకు, కొమ్మ లేదా పూర్తి మొక్క కనిపించే ఫోటోను అప్లోడ్ చేయండి.",
        "ta":
            "படத்தில் எந்த தாவரமும் அடையாளம் காணப்படவில்லை. நல்ல ஒளி மற்றும் தெளிவுடன் இலை, தண்டு அல்லது முழு தாவரம் தெளிவாக தெரியும் படத்தை பதிவேற்றவும்.",
        "kn":
            "ಚಿತ್ರದಲ್ಲಿ ಯಾವುದೇ ಸಸ್ಯ ಗುರುತಿಸಲಾಗಿಲ್ಲ. ಉತ್ತಮ ಬೆಳಕು ಮತ್ತು ಸ್ಪಷ್ಟತೆಯೊಂದಿಗೆ ಎಲೆ, ಕಾಂಡಿ ಅಥವಾ ಸಂಪೂರ್ಣ ಸಸ್ಯ ಕಾಣುವ ಫೋಟೋವನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ.",
      },
      "tips": {
        "en":
            "Avoid blurry images, dark backgrounds, or partially visible leaves. Capture the leaf from close distance and natural daylight.",
        "hi":
            "धुंधली, अंधेरी या अधूरी पत्ती वाली फोटो से बचें। पास से और प्राकृतिक रोशनी में फोटो लें।",
        "te":
            "మసకబారిన, చీకటి లేదా భాగంగా కనిపించే ఆకులతో ఉన్న చిత్రాలను తీసుకోకండి. దగ్గరగా మరియు సహజ కాంతిలో ఫోటో తీసుకోండి.",
        "ta":
            "மங்கலான அல்லது பகுதி இலை படங்களை தவிர்க்கவும். அருகில் இருந்து இயற்கை வெளிச்சத்தில் படம் எடுக்கவும்.",
        "kn":
            "ಮಸುಕಾದ ಅಥವಾ ಭಾಗಶಃ ಕಾಣುವ ಎಲೆಗಳ ಚಿತ್ರಗಳನ್ನು ತಪ್ಪಿಸಿ. ಹತ್ತಿರದಿಂದ ಮತ್ತು ನೈಸರ್ಗಿಕ ಬೆಳಕಿನಲ್ಲಿ ಚಿತ್ರ ತೆಗೆಯಿರಿ.",
      },
      "chatbot": {
        "en":
            "I couldn't identify a specific plant from your message. Try telling me the plant name, leaf shape, flower color, or its use.",
        "hi":
            "मैं आपके संदेश से पौधे की पहचान नहीं कर सका। पौधे का नाम, पत्ती का आकार, फूल का रंग या उपयोग बताने का प्रयास करें।",
        "te":
            "మీ సందేశం ఆధారంగా మొక్కను గుర్తించలేకపోయాను. మొక్క పేరు, ఆకుల ఆకారం, పువ్వు రంగు లేదా ఉపయోగం చెప్పండి.",
        "ta":
            "உங்கள் செய்தியிலிருந்து தாவரத்தை அடையாளம் காண முடியவில்லை. தாவரத்தின் பெயர், இலை வடிவம், பூ நிறம் அல்லது பயன்பாட்டை சொல்லுங்கள்.",
        "kn":
            "ನಿಮ್ಮ ಸಂದೇಶದಿಂದ ಸಸ್ಯವನ್ನು ಗುರುತಿಸಲಾಗಲಿಲ್ಲ. ಸಸ್ಯದ ಹೆಸರು, ಎಲೆ ಆಕಾರ, ಹೂ ಬಣ್ಣ ಅಥವಾ ಬಳಕೆಯನ್ನು ಹೇಳಿ.",
      },
    },
  };
  String getText(dynamic field, String lang) {
    if (field is Map) {
      return field[lang] ?? field['en'] ?? "";
    }
    return field?.toString() ?? "";
  }

  @override
  void initState() {
    super.initState();
    _loadLabels();
    print("\n\n\n\n voice name \n\n\n\n ");
    VoiceService.printVoices();
  }

  Future<void> _loadLabels() async {
    final labelsString = await rootBundle.loadString('assets/labels.txt');
    setState(() {
      _labels = labelsString
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // SEARCH
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchScreen(plantInfo: _plantInfo)),
      );
    } else if (index == 2) {
      // SPEAK
      if (_plantName != null && _plantName != 'Unknown Plant') {
        final lang = context.read<LanguageService>().currentLanguage;

        VoiceService.speak(_plantName!, _plantInfo, lang);
      }
    } else if (index == 3) {
      // FAVORITES
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoritesScreen()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AboutScreen()),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>().currentLanguage;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Identifier'),
        actions: [
          Consumer<LanguageService>(
            builder: (context, langService, _) {
              return DropdownButton<String>(
                value: langService.currentLanguage,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: "en", child: Text("English")),
                  DropdownMenuItem(value: "hi", child: Text("हिंदी")),
                  DropdownMenuItem(value: "te", child: Text("తెలుగు")),
                  DropdownMenuItem(value: "ta", child: Text("தமிழ்")),
                  DropdownMenuItem(value: "kn", child: Text("ಕನ್ನಡ")),
                ],
                onChanged: (value) {
                  langService.changeLanguage(value!);
                },
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final info = _plantInfo[_plantName!];
              if (_plantName == null) return;
              Share.share(
                "${getText(info?['name'], lang)}\n\n${getText(info?['description'], lang)}",
              );
            },
          ),
        ],
      ),
      // ⭐ ADD HERE
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.smart_toy),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatbotScreen(plantInfo: _plantInfo),
            ),
          );
        },
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    if (_imagePath != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final XFile? image = await _picker
                                        .pickImage(source: ImageSource.gallery);
                                    if (image != null) {
                                      setState(() {
                                        _imagePath = image.path;
                                        _plantName = null;
                                        _plantDescription = null;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Choose from Device'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) =>
                                          const CaptureGuidanceDialog(),
                                    );

                                    final XFile? image = await _picker
                                        .pickImage(source: ImageSource.camera);
                                    if (image != null) {
                                      setState(() {
                                        _imagePath = image.path;
                                        _plantName = null;
                                        _plantDescription = null;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Capture Image'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _imagePath == null || _isIdentifying
                                ? null
                                : () async {
                                    setState(() {
                                      _isIdentifying = true;
                                    });
                                    try {
                                      final tflite = TFLiteService();
                                      final result = await tflite.runInference(
                                        File(_imagePath!),
                                      );
                                      final predictedIdx =
                                          result['index'] as int;
                                      final confidence =
                                          result['confidence'] as double;
                                      final probs =
                                          result['probabilities']
                                              as List<double>;
                                      final top3 = PredictionUtils.getTopK(
                                        probs,
                                        _labels,
                                        3,
                                      );

                                      print('Labels:  _labels');
                                      print('Predicted index: $predictedIdx');
                                      print(
                                        'Label at index: ${_labels.isNotEmpty && predictedIdx >= 0 && predictedIdx < _labels.length ? _labels[predictedIdx] : "Out of bounds"}',
                                      );
                                      print('Confidence: ${confidence * 100}%');

                                      String plantName = 'Unknown Plant';
                                      if (confidence >= _confidenceThreshold &&
                                          _labels.isNotEmpty &&
                                          predictedIdx >= 0 &&
                                          predictedIdx < _labels.length) {
                                        plantName = _labels[predictedIdx];
                                      } else {
                                        plantName = 'Unknown Plant';
                                      }
                                      final plantDesc =
                                          _plantInfo[plantName] ??
                                          'No details available for this plant.';
                                      final fav = await FavoritesService()
                                          .isFavorite(
                                            plantName,
                                            _imagePath ?? "",
                                          );

                                      setState(() {
                                        _plantName = plantName;
                                        _confidence = confidence;
                                        _top3 = top3;
                                        _isFavorite = fav;
                                        _isIdentifying = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        _plantName = 'Error';
                                        _plantDescription =
                                            'Failed to identify plant. Please try again with a different image.';
                                        _confidence = null;
                                        _isIdentifying = false;
                                      });
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isIdentifying)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  const Icon(Icons.search),
                                const SizedBox(width: 8),
                                Text(
                                  _isIdentifying
                                      ? 'Identifying...'
                                      : 'Identify Plant',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_plantName != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: 250, // Adjust as needed
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: Builder(
                                builder: (context) {
                                  final info = _plantInfo[_plantName!];
                                  final isUnknown =
                                      _plantName == 'Unknown Plant' ||
                                      _plantName == 'unknown';
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    getText(
                                                          info?['name'],
                                                          lang,
                                                        ).isNotEmpty
                                                        ? getText(
                                                            info?['name'],
                                                            lang,
                                                          )
                                                        : _plantName!,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.titleLarge,
                                                  ),
                                                ),

                                                // ⭐ FAVORITE HEART
                                                Consumer<FavoritesService>(
                                                  builder: (context, fav, _) {
                                                    final isFav =
                                                        _imagePath != null &&
                                                        _plantName != null &&
                                                        fav.isFavorite(
                                                          _plantName!,
                                                          _imagePath!,
                                                        );

                                                    return IconButton(
                                                      icon: Icon(
                                                        isFav
                                                            ? Icons.favorite
                                                            : Icons
                                                                  .favorite_border,
                                                        color: isFav
                                                            ? Colors.red
                                                            : Colors.grey,
                                                      ),
                                                      onPressed: () {
                                                        if (_plantName ==
                                                                null ||
                                                            _imagePath == null)
                                                          return;

                                                        final plant = FavoritePlant(
                                                          name: _plantName!,
                                                          description:
                                                              _plantDescription ??
                                                              "",
                                                          imagePath:
                                                              _imagePath!,
                                                        );

                                                        context
                                                            .read<
                                                              FavoritesService
                                                            >()
                                                            .toggleFavorite(
                                                              plant,
                                                            );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ), // ⭐ ALWAYS show confidence (for both plant & unknown)
                                      if (_confidence != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%",
                                              ),
                                              Text(
                                                PredictionUtils.confidenceMessage(
                                                  _confidence!,
                                                ),
                                                style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      // ⭐ Top-3 predictions
                                      if (_plantName == 'Unknown Plant' &&
                                          _top3.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Possible plants:",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              // Text(
                                              //   PredictionUtils.confidenceMessage(
                                              //     _confidence!,
                                              //   ),
                                              //   style: const TextStyle(
                                              //     fontStyle: FontStyle.italic,
                                              //   ),
                                              // ),
                                              const SizedBox(height: 6),

                                              ..._top3.map(
                                                (e) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 2,
                                                      ),
                                                  child: Text(
                                                    "${e['label']} • ${(e['confidence'] * 100).toStringAsFixed(1)}%",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      if (info?['scientific_name'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            '${_heading("scientific", lang)} ${getText(info?['scientific_name'], lang)}\n',
                                          ),
                                        ),

                                      Text(
                                        getText(info?['description'], lang),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      if (isUnknown && info?['tips'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10.0,
                                          ),
                                          child: Text(
                                            "💡Tips: ${_heading("tips", lang)} ${getText(info?['tips'], lang)}",
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),

                                      if (info?['uses'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            '\n${_heading("uses", lang)} ${getText(info?['uses'], lang)}\n',
                                          ),
                                        ),

                                      if (info?['more_info'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            '${_heading("more", lang)} ${getText(info?['more_info'], lang)}\n',
                                          ),
                                        ),

                                      if (info?['local_names'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            '${_heading("local", lang)} ${getText(info?['local_names'], lang)}\n',
                                          ),
                                        ),

                                      if (info?['side_effects'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            '${_heading("side", lang)} ${getText(info?['side_effects'], lang)}\n',
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFEDE7F6), // ⭐ light lavender
        selectedItemColor: const Color(0xFF673AB7), // ⭐ deep purple
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Speak'),

          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.favorite),
                if (_favoriteCount > 0)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$_favoriteCount',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
