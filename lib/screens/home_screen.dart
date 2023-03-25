import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_gpt_flutter/configs/app.dart';
import 'package:chat_gpt_flutter/configs/configs.dart';
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
  TextEditingController textEditingController = TextEditingController();
  SpeechToText speechToText = SpeechToText();
  var isListening = false;
  var text = 'Hold the Button and Start Speaking';
  double confidence = 1.0;
  var scrollController = ScrollController();

  final List<ChatMessage> messages = [];
  String textChat = '';

  scrollMethod() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 60.0,
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
          'Voice Assistant Chat GPT',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: Space.all(1),
          child: Column(
            children: [
              Text(
                text,
                style: AppText.b1,
              ),
              Space.y!,
              Expanded(
                child: Container(
                  padding: Space.all(0.5),
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
      Space.x!,
      Expanded(
        child: Container(
          margin: Space.v,
          padding: Space.all(),
          decoration: BoxDecoration(
            color: type == ChatMessageType.bot ? Colors.green : Colors.blue,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          child: Text(
            chatText!.trim(),
            style: AppText.b2!.copyWith(color: Colors.black),
          ),
        ),
      ),
    ],
  );
}
