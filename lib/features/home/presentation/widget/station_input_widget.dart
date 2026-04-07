import 'package:flutter/material.dart';

class StationInputWidget extends StatelessWidget {
  final String label;
  final String stationName;
  final Color dotColor;
  final VoidCallback? onTap;

  const StationInputWidget({
    super.key,
    required this.label,
    required this.stationName,
    required this.dotColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: dotColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: dotColor, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8899AA),
                ),
              ),
              Text(
                stationName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
