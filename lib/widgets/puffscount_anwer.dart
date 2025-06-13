

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_bloc.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_event.dart';
import 'package:laennec_ai_health_assistant/bloc/chat_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';







Widget buildPuffsPicker(BuildContext context, ChatState state) {
  int currentValue = int.tryParse(state.selectedAnswer ?? "1") ?? 1;

  return Align(
    alignment: Alignment.centerRight,
    child: Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ).copyWith(left: 40.0, right: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
        width: 180,
        height: 120,
        child: ListWheelScrollView(
          itemExtent: 40,
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
                    fontSize: number == currentValue ? 24 : 18,
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
