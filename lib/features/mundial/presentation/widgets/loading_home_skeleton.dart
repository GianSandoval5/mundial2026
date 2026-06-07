import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class LoadingHomeSkeleton extends StatefulWidget {
  const LoadingHomeSkeleton({super.key});

  @override
  State<LoadingHomeSkeleton> createState() => _LoadingHomeSkeletonState();
}

class _LoadingHomeSkeletonState extends State<LoadingHomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
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
        final color = Color.lerp(
          MundialitoColors.panel,
          MundialitoColors.panelSoft,
          _controller.value,
        )!;

        return Column(
          children: <Widget>[
            _Block(height: 184, color: color),
            const SizedBox(height: 16),
            _Block(height: 74, color: color),
            const SizedBox(height: 12),
            _Block(height: 122, color: color),
            const SizedBox(height: 12),
            _Block(height: 122, color: color),
          ],
        );
      },
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.height,
    required this.color,
  });

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
