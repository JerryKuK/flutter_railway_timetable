import 'package:flutter/material.dart';

class TimetableEmptyStateWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const TimetableEmptyStateWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0x154A90D9),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.train,
                size: 44,
                color: Color(0x404A90D9),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '暫無班次資料',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '目前查詢的路線與日期沒有可用班次\n請嘗試更換日期或路線',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8899AA),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '重新查詢',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
