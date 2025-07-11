import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/services.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_bloc.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_event.dart';
import 'package:laennec_ai_assistant/bloc/chat_bloc/chat_state.dart';

Widget buildPuffsPicker(BuildContext context, ChatState state) {
  int currentValue = int.tryParse(state.selectedAnswer ?? "1") ?? 1;

  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final isSmallScreen = screenWidth < 360;
  final isLargeScreen = screenWidth > 400;

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
      child: SizedBox(
        width:
            isSmallScreen
                ? screenWidth * 0.4
                : (isLargeScreen ? screenWidth * 0.5 : screenWidth * 0.45),
        height: isSmallScreen ? 100 : (isLargeScreen ? 140 : 120),
        child: ListWheelScrollView(
          itemExtent: isSmallScreen ? 35 : (isLargeScreen ? 45 : 40),
          diameterRatio: 1.5,
          magnification: 1.2,
          useMagnifier: true,
          children: List.generate(25, (index) {
            final number = index + 1;
            return GestureDetector(
              onTap: () {
                context.read<ChatBloc>().add(
                  AnswerSubmitted(number.toString()),
                );
              },
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    color:
                        number == currentValue ? Colors.white : Colors.white70,
                    fontSize:
                        isSmallScreen
                            ? (number == currentValue ? 20 : 16)
                            : isLargeScreen
                            ? (number == currentValue ? 28 : 22)
                            : (number == currentValue ? 24 : 18),
                    fontWeight:
                        number == currentValue
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}
