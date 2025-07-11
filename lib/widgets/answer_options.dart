import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_event.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_state.dart';
import 'package:laennec_ai_assistant/widgets/puffscount_anwer.dart';

Widget buildAnswerOptions(BuildContext context, ChatState state) {
  if (!state.showAnswerOptions) {
    return const SizedBox.shrink();
  }

  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 360;
  final isLargeScreen = screenWidth > 400;

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
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 8.0,
      ).copyWith(left: screenWidth * 0.1, right: screenWidth * 0.04),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: 8.0,
      ),
      constraints: BoxConstraints(
        maxHeight: isSmallScreen ? 270 : (isLargeScreen ? 370 : 320),
        maxWidth: screenWidth * 0.85,
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
                final isSelected = answer.text == state.selectedAnswer;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        () => context.read<ChatBloc>().add(
                          AnswerSubmitted(answer.text),
                        ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 8.0 : 10.0,
                        horizontal: 8.0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.white : Colors.white70,
                            size:
                                isSmallScreen ? 20 : (isLargeScreen ? 24 : 22),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Text(
                              answer.text,
                              style: TextStyle(
                                fontSize:
                                    isSmallScreen
                                        ? 14
                                        : (isLargeScreen ? 18 : 16),
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
