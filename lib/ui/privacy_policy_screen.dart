import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "HerbAI does not collect, store, or share any personal data.\n\n"
          "All plant identification processing happens offline on your device.\n\n"
          "No internet connection is required.\n\n"
          "This app is for educational purposes only.",
        ),
      ),
    );
  }
}
