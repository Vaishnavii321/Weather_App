import 'package:flutter/material.dart';

class AdditinaolInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditinaolInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon, 
          size:35,
        ),
        const SizedBox(height: 8),
        Text(label),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}