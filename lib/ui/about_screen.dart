import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'privacy_policy_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = "";
  final int _epochs = 50;
  final int _plantClasses = 40;
  final double _valAccuracy = 0.91;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _version = "${info.version} (${info.buildNumber})";
    });
  }

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception("Could not launch $url");
    }
  }

  Widget _infoBox({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(title: const Text("About HerbAI")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// LOGO + VERSION
            _infoBox(
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png", height: 90),
                  const SizedBox(height: 12),
                  const Text(
                    "HerbAI",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("Version $_version"),
                ],
              ),
            ),

            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "About the App",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "HerbAI is an offline AI-powered herbal plant identification "
                    "application designed to recognize medicinal plants using image recognition. "
                    "It provides detailed plant information including scientific name, "
                    "local names, uses, and potential side effects.",
                  ),
                ],
              ),
            ),

            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Why We Built HerbAI",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Many medicinal plants are difficult to identify correctly. "
                    "HerbAI was built to make plant identification accessible, "
                    "accurate, and fully offline, especially for rural and low-connectivity areas.",
                  ),
                ],
              ),
            ),

            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "How to Use",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("1. Capture or upload a plant image."),
                  Text("2. Click 'Identify Plant'."),
                  Text("3. View AI prediction with confidence score."),
                  Text("4. Explore detailed plant information."),
                  Text("5. Add to Favorites for quick access."),
                  Text("6. Use voice feature to hear plant details."),
                ],
              ),
            ),

            /// MODEL STATS
            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Model Performance",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("• Training Epochs: $_epochs"),
                  Text("• Plant Classes: $_plantClasses"),
                  Text(
                    "• Validation Accuracy: ${(_valAccuracy * 100).toStringAsFixed(1)}%",
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Model runs fully offline using TensorFlow Lite.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Key Features",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("• Offline AI Identification"),
                  Text("• Top-3 Predictions"),
                  Text("• Confidence Level Explanation"),
                  Text("• Voice Assistant (Text-to-Speech)"),
                  Text("• Favorites with Offline Storage"),
                  Text("• Advanced Search"),
                  Text("• Chatbot Assistant"),
                  Text("• Privacy-Focused Design"),
                ],
              ),
            ),
            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Multi-Language Support",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "HerbAI supports 5 different languages to make plant knowledge "
                    "accessible to a wider audience.",
                  ),
                  SizedBox(height: 6),
                  Text("• English"),
                  Text("• Hindi (हिंदी)"),
                  Text("• Telugu (తెలుగు)"),
                  Text("• Tamil (தமிழ்)"),
                  Text("• Kannada (ಕನ್ನಡ)"),
                  SizedBox(height: 6),
                  Text(
                    "All plant information, chatbot responses, and headings dynamically "
                    "adapt based on the user’s selected language.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "AI Voice Assistant",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "HerbAI includes a built-in multilingual voice assistant powered "
                    "by Text-to-Speech technology.",
                  ),
                  SizedBox(height: 6),
                  Text("• Speaks plant information in selected language"),
                  Text("• Supports 5 languages"),
                  Text("• Adjustable speech speed and clarity"),
                  Text("• Works completely offline"),
                  SizedBox(height: 6),
                  Text(
                    "Voice feature enhances accessibility for users with reading difficulties "
                    "and improves user engagement.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "AI Chatbot Assistant",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "HerbAI includes an intelligent offline chatbot that allows users "
                    "to ask questions about medicinal plants.",
                  ),
                  SizedBox(height: 6),
                  Text("• Understands plant names and related queries"),
                  Text("• Multilingual responses"),
                  Text("• Smart similarity-based search"),
                  Text("• Section-wise structured answers"),
                  SizedBox(height: 6),
                  Text(
                    "The chatbot enhances user interaction and makes plant "
                    "information more conversational and user-friendly.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Favorites & Offline Storage",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Users can save identified plants to a personalized Favorites section.",
                  ),
                  SizedBox(height: 6),
                  Text("• Stores plant name and image locally"),
                  Text("• Offline persistent storage"),
                  Text("• Quick access to saved plants"),
                  Text("• Favorite toggle with visual indicator"),
                  SizedBox(height: 6),
                  Text(
                    "All favorite data is stored securely on the device "
                    "without any cloud dependency.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Sharing Capability",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "HerbAI allows users to share plant information instantly "
                    "with friends, researchers, or family.",
                  ),
                  SizedBox(height: 6),
                  Text("• Share plant name and description"),
                  Text("• Works via WhatsApp, Email, and other apps"),
                  Text("• Promotes herbal awareness"),
                  SizedBox(height: 6),
                  Text(
                    "This feature helps spread knowledge about medicinal plants "
                    "across communities.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Privacy & Offline Security",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("HerbAI is built with a privacy-first architecture."),
                  SizedBox(height: 6),
                  Text("• No user data collected"),
                  Text("• No cloud storage required"),
                  Text("• Fully offline AI inference"),
                  Text("• Secure local data handling"),
                  SizedBox(height: 6),
                  Text(
                    "All plant identification and chatbot processing "
                    "happens directly on the user’s device.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Technical Architecture",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("• Flutter Frontend"),
                  Text("• TensorFlow Lite Model"),
                  Text("• SharedPreferences for Local Storage"),
                  Text("• Image Preprocessing (224x224 normalization)"),
                  Text("• Offline Inference Engine"),
                ],
              ),
            ),

            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Limitations",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Accuracy depends on image clarity and lighting conditions. "
                    "The model may not recognize plants outside the trained dataset.",
                  ),
                ],
              ),
            ),

            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Future Enhancements",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("• Support for more plant species"),
                  Text("• Disease detection module"),
                  Text("• AI model performance improvements"),
                  Text("• Plant care recommendations"),
                ],
              ),
            ),

            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Developer Vision",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "HerbAI aims to bridge AI technology with traditional herbal knowledge, "
                    "making medicinal plant awareness accessible globally without "
                    "requiring internet connectivity.",
                  ),
                ],
              ),
            ),

            /// DEVELOPER SECTION
            _infoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Developer",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Chintha Vamsidhar Reddy\n"
                    "Kollapaneni Pranadeep\n"
                    "Chinimilli Dhanush\n"
                    "Badugu Avinash",
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _launch(
                          "https://github.com/ChinthaVamsidharReddy/",
                        ),
                        icon: const Icon(Icons.code),
                        label: const Text("GitHub"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _launch(
                          "https://www.linkedin.com/in/c-vamsidharreddy/",
                        ),
                        icon: const Icon(Icons.business),
                        label: const Text("LinkedIn"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _launch("mailto:vamsidharreddy831@gmail.com"),
                        icon: const Icon(Icons.email),
                        label: const Text("Email"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _launch("https://wa.me/918317655125"),
                        icon: const Icon(Icons.chat),
                        label: const Text("WhatsApp"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// PRIVACY POLICY
            _infoBox(
              child: ListTile(
                title: const Text("Privacy Policy"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
