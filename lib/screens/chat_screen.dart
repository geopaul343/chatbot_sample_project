import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:laennec_ai_assistant/bloc/chat_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_event.dart';
import 'package:laennec_ai_assistant/bloc/chat_state.dart';
import 'package:laennec_ai_assistant/model/message.dart';
import 'package:laennec_ai_assistant/questions/screen_questions.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:laennec_ai_assistant/bloc/chat_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_event.dart';
import 'package:laennec_ai_assistant/bloc/chat_state.dart';
import 'package:laennec_ai_assistant/model/message.dart';
import 'package:laennec_ai_assistant/questions/screen_questions.dart';
import 'package:laennec_ai_assistant/screens/drawer_screen.dart';
import 'package:laennec_ai_assistant/screens/medical_disclaimer_screen.dart';
import 'package:laennec_ai_assistant/utils/first_launch_checker.dart';
import 'package:laennec_ai_assistant/widgets/answer_options.dart';
import 'package:laennec_ai_assistant/widgets/buildtext_composer.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 400;

    return Scaffold(
      drawer: const DrawerScreen(),
      appBar: AppBar(
        toolbarHeight: isSmallScreen ? 60 : 70,
        title: Text(
          "Laennec AI Assistant",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 16 : (isLargeScreen ? 20 : 18),
          ),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade900,
        elevation: 0,
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const VoiceChatScreen(),
          //       ),
          //     );
          //   },
          //   icon: const Icon(Icons.mic, color: Colors.white),
          //   tooltip: 'Voice Chat',
          // ),
        ],
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
                    padding: EdgeInsets.only(
                      bottom: 8.0,
                      left: screenWidth * 0.02,
                      right: screenWidth * 0.02,
                    ),
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
                          fontSize:
                              isSmallScreen ? 14 : (isLargeScreen ? 18 : 16),
                        ),
                        tail: true,
                        sent: msg.isSender,
                      );
                    },
                  ),
                ),
                if (state.isTyping)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 0,
                      bottom: 8.0,
                      top: 8.0,
                      right: screenWidth * 0.7,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: isSmallScreen ? 8.0 : 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade700,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            '• • •',
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  isSmallScreen
                                      ? 13.0
                                      : (isLargeScreen ? 17.0 : 15.0),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4.0,
                            ),
                            speed: const Duration(milliseconds: 100),
                          ),
                        ],
                        isRepeatingAnimation: true,
                        repeatForever: true,
                      ),
                    ),
                  ),
                buildAnswerOptions(context, state),
                buildTextComposer(context, state),
                SizedBox(height: 25),
              ],
            );
          },
        ),
      ),
    );
  }
}
