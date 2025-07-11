import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_event.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_state.dart';
import 'package:laennec_ai_assistant/screens/voice_chat_screen.dart';

Widget buildTextComposer(BuildContext context, ChatState state) {
  final bool isQuestionnaireComplete = state.isQuestionnaireComplete;
  final bool isAITyping = state.isTyping;
  final bool expectingCustomInput = state.expectingCustomInput;
  final bool isEnabled =
      (isQuestionnaireComplete || expectingCustomInput) && !isAITyping;
  final TextEditingController controller = TextEditingController();

  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 360;
  final isLargeScreen = screenWidth > 400;

  String getHintText() {
    if (expectingCustomInput) {
      return "Please enter your reason...";
    } else if (!isQuestionnaireComplete) {
      return "Laennec AI";
    } else if (isAITyping) {
      return "AI is thinking...";
    } else {
      return "Ask me anything...";
    }
  }

  return Container(
    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 8.0),
    decoration: BoxDecoration(
      color:
          isAITyping
              ? Colors.black.withOpacity(0.1)
              : Colors.black.withOpacity(0.2),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.02),
          child: IconButton(
            iconSize: isSmallScreen ? 20 : (isLargeScreen ? 28 : 24),
            icon: Icon(
              Icons.mic,
              color: isEnabled ? Colors.white : Colors.grey.withOpacity(0.5),
            ),
            onPressed:
                isEnabled
                    ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const VoiceChatScreen();
                          },
                        ),
                      );
                    }
                    : null,
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: isEnabled,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
              fontSize: isSmallScreen ? 14 : (isLargeScreen ? 18 : 16),
            ),
            decoration: InputDecoration(
              hintText: getHintText(),
              hintStyle: TextStyle(
                color:
                    isEnabled
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.3),
                fontSize: isSmallScreen ? 14 : (isLargeScreen ? 18 : 16),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: isSmallScreen ? 12.0 : 16.0,
              ),
              alignLabelWithHint: true,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.02),
          child: IconButton(
            iconSize: isSmallScreen ? 20 : (isLargeScreen ? 28 : 24),
            icon: Icon(
              Icons.send,
              color: isEnabled ? Colors.white : Colors.grey.withOpacity(0.5),
            ),
            onPressed:
                isEnabled
                    ? () {
                      if (controller.text.trim().isNotEmpty) {
                        context.read<ChatBloc>().add(
                          MessageSent(controller.text),
                        );
                        controller.clear();
                      }
                    }
                    : null,
          ),
        ),
      ],
    ),
  );
}
