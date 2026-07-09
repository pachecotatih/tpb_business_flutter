import 'package:flutter/material.dart';

class ArrowIcon extends StatelessWidget {
  final IconData icon;
  final Color color1;
  final Color color2;
  const ArrowIcon({
    super.key,
    required this.icon,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color1,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Icon(icon, color: color2, size: 16),
    );
  }
}
