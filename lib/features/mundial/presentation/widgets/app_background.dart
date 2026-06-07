import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.2,
          colors: <Color>[
            Color(0xFF263417),
            MundialitoColors.pitch,
            Color(0xFF070A05),
          ],
          stops: <double>[0, 0.52, 1],
        ),
      ),
      child: CustomPaint(
        painter: PitchLinesPainter(),
        child: child,
      ),
    );
  }
}

class PitchLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = MundialitoColors.lime.withValues(alpha: 0.055);

    final center = Offset(size.width * 0.5, size.height * 0.38);
    canvas.drawCircle(center, size.width * 0.34, paint);
    canvas.drawLine(
      Offset(0, size.height * 0.38),
      Offset(size.width, size.height * 0.38),
      paint,
    );

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = MundialitoColors.lime.withValues(alpha: 0.04);

    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * (0.16 + i * 0.24)),
        width: size.width * (0.9 + i * 0.24),
        height: size.height * 0.4,
      );
      canvas.drawArc(rect, math.pi * 0.1, math.pi * 0.8, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
