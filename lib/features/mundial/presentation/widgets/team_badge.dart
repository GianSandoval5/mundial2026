import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/mundial_models.dart';

class TeamBadge extends StatelessWidget {
  const TeamBadge({
    required this.team,
    this.size = 52,
    this.showName = true,
    this.foregroundColor,
    super.key,
  });

  final TeamRef team;
  final double size;
  final bool showName;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final textColor = foregroundColor ?? MundialitoColors.smoke;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: _TeamLogo(team: team),
        ),
        if (showName) ...<Widget>[
          const SizedBox(height: 8),
          SizedBox(
            width: size + 36,
            child: Text(
              team.shortName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.team});

  final TeamRef team;

  @override
  Widget build(BuildContext context) {
    final url = team.logoUrl;
    if (url == null || url.isEmpty) {
      return _FallbackLogo(team: team);
    }

    return ClipOval(
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _FallbackLogo(team: team),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.team});

  final TeamRef team;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[MundialitoColors.lime, MundialitoColors.limeSoft],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          team.shortName,
          style: const TextStyle(
            color: MundialitoColors.pitch,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
