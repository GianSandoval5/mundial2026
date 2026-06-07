import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class LivePulse extends StatefulWidget {
  const LivePulse({
    this.size = 8,
    super.key,
  });

  final double size;

  @override
  State<LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 1 - _controller.value;
        return SizedBox(
          width: widget.size * 2.5,
          height: widget.size * 2.5,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Transform.scale(
                scale: 1 + _controller.value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: MundialitoColors.danger.withValues(
                      alpha: opacity * 0.25,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: MundialitoColors.danger,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
