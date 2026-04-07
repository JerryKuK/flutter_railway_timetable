import 'package:flutter/material.dart';

class DateTimeRowWidget extends StatelessWidget {
  final String date;
  final String time;
  final ValueChanged<String> onDateChanged;
  final ValueChanged<String> onTimeChanged;

  const DateTimeRowWidget({
    super.key,
    required this.date,
    required this.time,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
      onDateChanged(formatted);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final parts = time.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 8,
      minute: int.tryParse(parts.last) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onTimeChanged(formatted);
    }
  }

  Widget _buildCard({
    required Widget icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xEEFFFFFF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8899AA),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          icon: const Icon(Icons.calendar_today_outlined,
              size: 18, color: Color(0xFF4A90D9)),
          label: '日期',
          value: date,
          onTap: () => _pickDate(context),
        ),
        const SizedBox(width: 12),
        _buildCard(
          icon: const Icon(Icons.access_time,
              size: 18, color: Color(0xFF4A90D9)),
          label: '時間',
          value: time,
          onTap: () => _pickTime(context),
        ),
      ],
    );
  }
}
