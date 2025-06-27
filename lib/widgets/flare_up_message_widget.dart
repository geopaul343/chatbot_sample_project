import 'package:flutter/material.dart';

class FlareUpMessageWidget extends StatelessWidget {
  final String message;
  final bool isEmergency;

  const FlareUpMessageWidget({
    super.key,
    required this.message,
    required this.isEmergency,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isEmergency ? Colors.red.shade700 : Colors.orange.shade700;
    final icon = isEmergency ? Icons.warning_amber_rounded : Icons.info_outline;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
