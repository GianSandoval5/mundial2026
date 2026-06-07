import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_text.dart';
import '../../domain/mundial_models.dart';
import 'live_pulse.dart';
import 'team_badge.dart';

class FeaturedMatchCard extends StatelessWidget {
  const FeaturedMatchCard({
    required this.match,
    required this.strings,
    required this.language,
    required this.onTap,
    super.key,
  });

  final MundialMatch match;
  final AppLocalizations strings;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: _FeaturedCardClipper(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          decoration: BoxDecoration(
            color: MundialitoColors.lime,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: MundialitoColors.lime.withValues(alpha: 0.22),
                blurRadius: 26,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      match.round,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MundialitoColors.pitch,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _StatusPill(match: match, strings: strings, onLime: true),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TeamBadge(
                      team: match.home,
                      foregroundColor: MundialitoColors.pitch,
                    ),
                  ),
                  _ScoreBlock(match: match, language: language),
                  Expanded(
                    child: TeamBadge(
                      team: match.away,
                      foregroundColor: MundialitoColors.pitch,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.stadium_rounded,
                    size: 16,
                    color: MundialitoColors.pitch,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      match.venueText.isEmpty
                          ? DateText.matchDate(match.date, language)
                          : match.venueText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MundialitoColors.pitch,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: MundialitoColors.pitch,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  const MatchCard({
    required this.match,
    required this.strings,
    required this.language,
    required this.onTap,
    super.key,
  });

  final MundialMatch match;
  final AppLocalizations strings;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MundialitoColors.panel.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    match.round,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: MundialitoColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusPill(match: match, strings: strings),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(child: _CompactTeam(team: match.home)),
                Text(
                  match.scoreText,
                  style: const TextStyle(
                    color: MundialitoColors.smoke,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _CompactTeam(team: match.away, reverse: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Icon(
                  match.isLive
                      ? Icons.timer_rounded
                      : Icons.calendar_today_rounded,
                  size: 15,
                  color: MundialitoColors.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    match.isLive
                        ? "${match.status.elapsed}' - ${match.status.long}"
                        : DateText.matchDate(match.date, language),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: MundialitoColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: MundialitoColors.muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({
    required this.match,
    required this.language,
  });

  final MundialMatch match;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Column(
        children: <Widget>[
          Text(
            match.isLive || match.isFinished
                ? match.scoreText
                : DateText.shortDate(match.date, language),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MundialitoColors.pitch,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            match.isLive
                ? "${match.status.elapsed}'"
                : match.status.long.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MundialitoColors.pitch,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.match,
    required this.strings,
    this.onLime = false,
  });

  final MundialMatch match;
  final AppLocalizations strings;
  final bool onLime;

  @override
  Widget build(BuildContext context) {
    final label = match.isLive
        ? strings.live
        : match.isFinished
            ? strings.finished
            : strings.upcoming;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: onLime
            ? MundialitoColors.pitch.withValues(alpha: 0.86)
            : MundialitoColors.panelSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (match.isLive) ...<Widget>[
            const LivePulse(size: 6),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: match.isLive
                  ? MundialitoColors.lime
                  : onLime
                      ? MundialitoColors.smoke
                      : MundialitoColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTeam extends StatelessWidget {
  const _CompactTeam({
    required this.team,
    this.reverse = false,
  });

  final TeamRef team;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      TeamBadge(team: team, size: 38, showName: false),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          team.shortName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: MundialitoColors.smoke,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          reverse ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: reverse ? children.reversed.toList() : children,
    );
  }
}

class _FeaturedCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - 22)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height - 22,
        size.width * 0.62,
        size.height - 8,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 8,
        size.width * 0.38,
        size.height - 8,
      )
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height - 22,
        0,
        size.height - 22,
      )
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
