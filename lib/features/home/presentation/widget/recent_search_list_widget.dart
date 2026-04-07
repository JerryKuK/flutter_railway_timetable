import 'package:flutter/material.dart';
import '../../domain/entity/recent_search.dart';

class RecentSearchListWidget extends StatelessWidget {
  final List<RecentSearch> searches;
  final VoidCallback onClearAll;
  final ValueChanged<RecentSearch> onSelect;

  const RecentSearchListWidget({
    super.key,
    required this.searches,
    required this.onClearAll,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '最近查詢',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF2C3E50),
              ),
            ),
            GestureDetector(
              onTap: onClearAll,
              child: const Text(
                '清除全部',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A90D9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: searches
              .map((s) => _buildRecentItem(s))
              .expand((w) => [w, const SizedBox(height: 8)])
              .toList()
            ..removeLast(),
        ),
      ],
    );
  }

  Widget _buildRecentItem(RecentSearch s) {
    return GestureDetector(
      onTap: () => onSelect(s),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0x99FFFFFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.train, size: 16, color: Color(0xFF4A90D9)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${s.departureStation} → ${s.arrivalStation}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
