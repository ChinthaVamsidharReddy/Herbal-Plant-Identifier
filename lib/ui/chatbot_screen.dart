import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';
import '../widgets/chat_bubble.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class ChatbotScreen extends StatefulWidget {
  final Map<String, Map<String, dynamic>> plantInfo;

  const ChatbotScreen({super.key, required this.plantInfo});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  final List<Map<String, String>> messages = [];
  late ChatbotService chatbot;
  bool _isSending = false;

  Future<void> _configureVoice() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = context.read<LanguageService>().currentLanguage;
      chatbot = ChatbotService(widget.plantInfo, lang);
    });

    _configureVoice();
  }

  Future<void> sendMessage() async {
    if (_isSending) return; // ⭐ guard

    String query = _controller.text.trim();
    if (query.isEmpty) return;

    _isSending = true;

    setState(() {
      messages.add({"role": "user", "text": query});
    });

    String response = chatbot.generateResponse(query);

    setState(() {
      messages.add({"role": "bot", "text": response});
    });

    _controller.clear();

    _isSending = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, langService, _) {

        chatbot = ChatbotService(widget.plantInfo, langService.currentLanguage);

        return Scaffold(
          appBar: AppBar(title: const Text("HerbAI Chatbot")),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    bool isUser = messages[i]["role"] == "user";
                    return ChatBubble(
                      text: messages[i]["text"]!,
                      isUser: isUser,
                      onSpeak: isUser
                          ? null
                          : () async {
                              await _tts.stop();
                              await _configureVoice();
                              await _tts.setLanguage(langService.currentLanguage == "en"? "en-US": "${langService.currentLanguage}-IN");
                              await _tts.speak(messages[i]["text"]!);
                            },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Ask about plants...",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}