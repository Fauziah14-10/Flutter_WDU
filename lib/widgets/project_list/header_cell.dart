import 'package:flutter/material.dart';

class HeaderCell extends StatelessWidget {
  final IconData icon;
  final String label;

  const HeaderCell({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}