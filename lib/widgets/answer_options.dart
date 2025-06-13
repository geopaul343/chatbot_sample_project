import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_bloc.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_event.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_state.dart';
import 'package:laennec_ai_health_assistant/widgets/puffscount_anwer.dart';
import 'package:numberpicker/numberpicker.dart';

Widget buildAnswerOptions(BuildContext context, ChatState state) {
  if (!state.showAnswerOptions) {
    return const SizedBox.shrink();
  }

  // Special case for puffs question (index 2)
  if (state.currentQuestionIndex == 2) {
    // If an answer is already selected, don't show any options
    if (state.selectedAnswer != null && state.selectedAnswer!.isNotEmpty) {
      return const SizedBox.shrink();
    }
    return buildPuffsPicker(context, state);
  }

  // Regular answer options for other questions
  return Align(
    alignment: Alignment.centerRight,
    child: Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ).copyWith(left: 40.0, right: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      constraints: const BoxConstraints(
        maxHeight: 300, // Limit height to prevent overflow
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              state.answers.map((answer) {
                final isSelected = answer == state.selectedAnswer;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        () => context.read<ChatBloc>().add(
                          AnswerSubmitted(answer),
                        ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 8.0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.white : Colors.white70,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              answer,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    ),
  );
}
