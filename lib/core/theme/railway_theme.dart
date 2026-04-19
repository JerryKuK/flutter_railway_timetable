import 'package:flutter/material.dart';
import '../enums/railway_type.dart';

class RailwayTheme {
  final List<Color> headerGradient;
  final Color accent;
  final Color accentSoft;

  const RailwayTheme({
    required this.headerGradient,
    required this.accent,
    required this.accentSoft,
  });

  static const tra = RailwayTheme(
    headerGradient: [Color(0xFF5FA6E0), Color(0xFF2E72B8)],
    accent: Color(0xFF2E72B8),
    accentSoft: Color(0xFFE3EEF9),
  );

  static const hsr = RailwayTheme(
    headerGradient: [Color(0xFFF2A85C), Color(0xFFD97A2A)],
    accent: Color(0xFFC86820),
    accentSoft: Color(0xFFFBEEDF),
  );

  static RailwayTheme of(RailwayType type) =>
      type == RailwayType.hsr ? hsr : tra;
}
