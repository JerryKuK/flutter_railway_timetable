import 'package:flutter/material.dart';

class ProfileStatsWidget extends StatelessWidget {
  final int mileage;
  final int points;
  final int frequentRoutes;

  const ProfileStatsWidget({
    super.key,
    required this.mileage,
    required this.points,
    required this.frequentRoutes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _StatItem(value: '$mileage', label: '里程行'),
            _divider(),
            _StatItem(
              value: points.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (m) => '${m[1]},',
                  ),
              label: '累積點數',
            ),
            _divider(),
            _StatItem(value: '$frequentRoutes', label: '常用路線'),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: Colors.grey[200]);
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
