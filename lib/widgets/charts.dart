import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';

/// أعمدة مصاريف آخر ٧ أيام
class WeeklyBars extends StatelessWidget {
  const WeeklyBars({super.key, required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: CustomPaint(painter: _WeeklyBarsPainter(values, labels)),
    );
  }
}

class _WeeklyBarsPainter extends CustomPainter {
  _WeeklyBarsPainter(this.values, this.labels);
  final List<double> values;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = values.fold<double>(0, math.max);
    const labelH = 22.0;
    final chartH = size.height - labelH;
    final n = values.length;
    final slot = size.width / n;
    final barW = slot * 0.5;

    for (var i = 0; i < n; i++) {
      final v = values[i];
      final h = maxV == 0 ? 4.0 : math.max(4.0, chartH * (v / maxV));
      final x = slot * i + (slot - barW) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartH - h, barW, h),
        const Radius.circular(7),
      );
      final isMax = v == maxV && maxV > 0;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isMax
              ? [AppColors.gold, AppColors.gold.withValues(alpha: 0.55)]
              : [AppColors.teal, AppColors.emerald.withValues(alpha: 0.55)],
        ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.5,
            fontWeight: isMax ? FontWeight.w800 : FontWeight.w500,
            color: isMax ? AppColors.emeraldDark : Colors.grey[600],
          ),
        ),
        textDirection: ui.TextDirection.rtl,
      )..layout();
      tp.paint(
        canvas,
        Offset(slot * i + (slot - tp.width) / 2, size.height - 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarsPainter old) =>
      old.values != values || old.labels != labels;
}

/// دونات توزيع المصاريف حسب التصنيف
class CategoryDonut extends StatelessWidget {
  const CategoryDonut({super.key, required this.entries});

  final List<MapEntry<String, double>> entries;

  static const palette = [
    Color(0xFF0E7C66),
    Color(0xFFE3A93B),
    Color(0xFF4E8DD6),
    Color(0xFFD64545),
    Color(0xFF8B5CC7),
    Color(0xFF2AA5A0),
    Color(0xFFE4743C),
    Color(0xFF6D8B3C),
  ];

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<double>(0, (s, e) => s + e.value);
    return SizedBox(
      height: 170,
      width: 170,
      child: CustomPaint(painter: _DonutPainter(entries, palette, total)),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.entries, this.palette, this.total);
  final List<MapEntry<String, double>> entries;
  final List<Color> palette;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    const stroke = 26.0;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    var start = -math.pi / 2;
    const gap = 0.035;

    for (var i = 0; i < entries.length; i++) {
      final sweep = (entries[i].value / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = palette[i % palette.length];
      canvas.drawArc(
        rect,
        start + gap / 2,
        math.max(0.01, sweep - gap),
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.entries != entries;
}

/// أعمدة دخل مقابل مصروف لآخر ٦ شهور
class MonthlyBars extends StatelessWidget {
  const MonthlyBars({
    super.key,
    required this.months,
    required this.income,
    required this.expense,
    required this.labels,
  });

  final List<DateTime> months;
  final List<double> income;
  final List<double> expense;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: CustomPaint(painter: _MonthlyBarsPainter(income, expense, labels)),
    );
  }
}

class _MonthlyBarsPainter extends CustomPainter {
  _MonthlyBarsPainter(this.income, this.expense, this.labels);
  final List<double> income;
  final List<double> expense;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = math.max(
      income.fold<double>(0, math.max),
      expense.fold<double>(0, math.max),
    );
    const labelH = 22.0;
    final chartH = size.height - labelH;
    final n = income.length;
    final slot = size.width / n;
    final barW = slot * 0.24;

    for (var i = 0; i < n; i++) {
      for (var k = 0; k < 2; k++) {
        final v = k == 0 ? income[i] : expense[i];
        final h = maxV == 0 ? 3.0 : math.max(3.0, chartH * (v / maxV));
        final x = slot * i + slot / 2 + (k == 0 ? -barW - 2 : 2);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, chartH - h, barW, h),
          const Radius.circular(6),
        );
        canvas.drawRRect(
          rect,
          Paint()
            ..color = k == 0
                ? AppColors.income
                : AppColors.expense.withValues(alpha: 0.85),
        );
      }
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        textDirection: ui.TextDirection.rtl,
      )..layout();
      tp.paint(
        canvas,
        Offset(slot * i + (slot - tp.width) / 2, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyBarsPainter old) =>
      old.income != income || old.expense != expense;
}
