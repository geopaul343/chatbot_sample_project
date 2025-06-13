
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_bloc.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_event.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_state.dart';


import 'package:http/http.dart' as http;
import 'package:laennec_ai_health_assistant/widgets/answer_options.dart';
import 'package:laennec_ai_health_assistant/widgets/buildtext_composer.dart';

// ChatScreen widget to display a chatbot interface
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc()..add(LoadQuestionnaire()),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text(
          "Laennec AI  Health Assistant",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade900,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state.messages.isNotEmpty) {
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    padding: const EdgeInsets.only(bottom: 8.0),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      return BubbleNormal(
                        text: msg.msg,
                        isSender: msg.isSender,
                        color:
                            msg.isSender
                                ? Colors.white
                                : Colors.indigo.shade700,
                        textStyle: TextStyle(
                          color: msg.isSender ? Colors.black87 : Colors.white,
                          fontSize: 16,
                        ),
                        tail: true,
                        sent: msg.isSender,
                      );
                    },
                  ),
                ),
                if (state.isTyping)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      bottom: 8.0,
                      top: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DefaultTextStyle(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontFamily: 'Ag-Book',
                          ),
                          child: Row(
                            children: [
                              Text("Typing"),
                              AnimatedTextKit(
                                animatedTexts: [
                                  TyperAnimatedText(
                                    '...',
                                    speed: const Duration(milliseconds: 100),
                                  ),
                                ],
                                isRepeatingAnimation: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                buildAnswerOptions(context, state),
                buildTextComposer(context, state),
              ],
            );
          },
        ),
      ),
    );
  }
}
