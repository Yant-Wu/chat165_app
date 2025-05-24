import 'package:flutter/material.dart';

class FunctionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color; // This is the iconColor
  
  const FunctionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // ADD: To ensure column takes minimum space
      children: [
        Container(
          width: 56, // MODIFY: Consistent with HomeScreen
          height: 56, // MODIFY: Consistent with HomeScreen
          decoration: BoxDecoration(
            color: color.withOpacity(0.15), // MODIFY: Subtle background using icon color
            borderRadius: BorderRadius.circular(16), // MODIFY: Rounded rectangle
          ),
          child: Icon(
            icon,
            size: 28, // MODIFY: Consistent with HomeScreen
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87, // MODIFY: Darker text for light background
            fontWeight: FontWeight.w500, // MODIFY: Medium weight
            fontSize: 13, // ADD: Consistent with HomeScreen
          ),
        ),
      ],
    );
  }
}