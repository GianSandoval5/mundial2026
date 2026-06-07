import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/mundialito_scope.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/home_page.dart';
import '../widgets/app_background.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _boot();
      }
    });
  }

  Future<void> _boot() async {
    final controller = MundialitoScope.of(context);
    await Future.wait<void>(<Future<void>>[
      controller.load(),
      Future<void>.delayed(const Duration(milliseconds: 2300)),
    ]);

    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MundialitoScope.of(context);
    final strings = controller.strings;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 164,
                      height: 164,
                      child: CustomPaint(
                        painter: SplashLogoPainter(_animationController.value),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      strings.appName,
                      style: const TextStyle(
                        color: MundialitoColors.smoke,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      strings.configuring,
                      style: const TextStyle(
                        color: MundialitoColors.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 96,
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(8),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          MundialitoColors.lime,
                        ),
                        backgroundColor:
                            MundialitoColors.smoke.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SplashLogoPainter extends CustomPainter {
  SplashLogoPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    final glowPaint = Paint()
      ..color = MundialitoColors.lime.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, radius, glowPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: <Color>[
          MundialitoColors.lime,
          MundialitoColors.limeSoft,
          Colors.transparent,
          MundialitoColors.lime,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.55,
      false,
      ringPaint,
    );
    canvas.restore();

    final ballPaint = Paint()
      ..color = MundialitoColors.smoke
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.24, ballPaint);

    final seamPaint = Paint()
      ..color = MundialitoColors.pitch
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 5; i++) {
      final angle = progress * math.pi * 2 + i * math.pi * 2 / 5;
      final start = Offset(
        center.dx + math.cos(angle) * size.width * 0.08,
        center.dy + math.sin(angle) * size.width * 0.08,
      );
      final end = Offset(
        center.dx + math.cos(angle) * size.width * 0.2,
        center.dy + math.sin(angle) * size.width * 0.2,
      );
      canvas.drawLine(start, end, seamPaint);
    }

    final cupPaint = Paint()
      ..color = MundialitoColors.lime
      ..style = PaintingStyle.fill;
    final cupPath = Path()
      ..moveTo(center.dx - 18, center.dy - 4)
      ..lineTo(center.dx + 18, center.dy - 4)
      ..quadraticBezierTo(center.dx + 10, center.dy + 24, center.dx, center.dy + 28)
      ..quadraticBezierTo(center.dx - 10, center.dy + 24, center.dx - 18, center.dy - 4)
      ..close();
    canvas.drawPath(cupPath, cupPaint);
  }

  @override
  bool shouldRepaint(covariant SplashLogoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
