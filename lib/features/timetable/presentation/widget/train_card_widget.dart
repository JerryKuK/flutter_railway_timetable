import 'package:flutter/material.dart';
import '../../domain/entity/train.dart';

class TrainCardWidget extends StatelessWidget {
  final Train train;

  const TrainCardWidget({super.key, required this.train});

  String _formatTravelTime(String raw) {
    // TDX API returns HH:MM format
    final parts = raw.split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      if (h > 0 && m > 0) return '─── ${h}h ${m}m ───';
      if (h > 0) return '─── ${h}h ───';
      if (m > 0) return '─── ${m}m ───';
    }
    return raw.isNotEmpty ? '─── $raw ───' : '';
  }

  Widget _dot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xEEFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Top row: train name + fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${train.trainTypeName}  #${train.trainNo}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                'NT\$ ${train.fare}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A90D9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Middle row: departure | duration | arrival
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _dot(const Color(0xFF4A90D9)),
                  const SizedBox(width: 6),
                  Text(
                    train.departureTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              Text(
                _formatTravelTime(train.travelTime),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8899AA),
                ),
              ),
              Row(
                children: [
                  Text(
                    train.arrivalTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _dot(const Color(0xFFD93C15)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
