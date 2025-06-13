
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_bloc.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_event.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

Widget buildTextComposer(BuildContext context, ChatState state) {
  final bool isEnabled = state.isQuestionnaireComplete;
  final TextEditingController controller = TextEditingController();
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.2),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: isEnabled,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: isEnabled ? "Ask me anything..." : "Laennec ai ",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              alignLabelWithHint: true,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send, color: isEnabled ? Colors.white : Colors.grey),
          onPressed:
              isEnabled
                  ? () {
                    context.read<ChatBloc>().add(MessageSent(controller.text));
                    controller.clear();
                  }
                  : null,
        ),
      ],
    ),
  );
}
