import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_gpt_flutter/models/chat_message.dart';
import 'package:chat_gpt_flutter/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SpeechToText speechToText = SpeechToText();
  var isListening = false;
  var text = 'Hold the mic and start speaking';
  double confidence = 1.0;
  var scrollController = ScrollController();

  final List<ChatMessage> messages = [];

  scrollMethod() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 75.0,
        animate: isListening,
        duration: const Duration(milliseconds: 2000),
        glowColor: Colors.green,
        repeat: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details) async {
            if (!isListening) {
              var available = await speechToText.initialize();
              if (available) {
                setState(
                  () {
                    isListening = true;
                    speechToText.listen(
                      onResult: (result) {
                        setState(
                          () {
                            text = result.recognizedWords;
                          },
                        );
                      },
                    );
                  },
                );
              }
            }
          },
          onTapUp: (details) async {
            setState(
              () {
                isListening = false;
              },
            );
            speechToText.stop();
            messages.add(
              ChatMessage(
                text: text,
                type: ChatMessageType.user,
              ),
            );
            var msg = await ApiServices.sendMessage(message: text);

            setState(() {
              messages.add(
                ChatMessage(
                  text: msg,
                  type: ChatMessageType.bot,
                ),
              );
            });
          },
          child: const CircleAvatar(
            backgroundColor: Colors.green,
            radius: 35,
            child: Icon(
              Icons.mic,
              color: Colors.white,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Voice Assistant',
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Text(
                text,
              ),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var chat = messages[index];
                      return chatBubble(chatText: chat.text, type: chat.type);
                    },
                    itemCount: messages.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget chatBubble({required String? chatText, required ChatMessageType? type}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(
          type == ChatMessageType.bot ? Icons.chat : Icons.person,
          color: Colors.white,
        ),
      ),
      const SizedBox(
        width: 12,
      ),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          child: Text(chatText!),
        ),
      ),
    ],
  );
}
