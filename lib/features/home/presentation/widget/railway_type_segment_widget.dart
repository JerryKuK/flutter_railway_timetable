import 'package:flutter/material.dart';
import '../../../../core/enums/railway_type.dart';
import '../../../../core/theme/railway_theme.dart';

class RailwayTypeSegmentWidget extends StatelessWidget {
  final RailwayType value;
  final ValueChanged<RailwayType> onChanged;

  const RailwayTypeSegmentWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: RailwayType.values.map((type) {
          final isSelected = type == value;
          final theme = RailwayTheme.of(type);
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: isSelected
                            ? theme.accent
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type == RailwayType.hsr ? 'HSR' : 'Rail',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: isSelected
                            ? theme.accent.withValues(alpha: 0.55)
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
