import 'package:flutter/material.dart';

class CallActionButton extends StatelessWidget {
  const CallActionButton({
    super.key,
    required this.onPressed,
    this.label = 'Call Customer',
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.phone_in_talk),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2FD07A),
        foregroundColor: Colors.black,
      ),
    );
  }
}
