import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/mundialito_scope.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_text.dart';
import '../../domain/mundial_models.dart';
import '../widgets/app_background.dart';
import '../widgets/live_pulse.dart';
import '../widgets/team_badge.dart';

class MatchDetailPage extends StatefulWidget {
  const MatchDetailPage({required this.match, super.key});

  final MundialMatch match;

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  static const Duration _refreshInterval = Duration(seconds: 30);

  MundialMatch? _detail;
  bool _isLoadingDetail = false;
  bool _didStartRealtime = false;
  Timer? _refreshTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didStartRealtime) {
      return;
    }

    _didStartRealtime = true;
    _detail ??= widget.match;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDetail();
      }
    });
    _refreshTimer ??= Timer.periodic(_refreshInterval, (_) {
      _loadDetail();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MundialitoScope.of(context);
    final strings = controller.strings;
    final match = _detail ?? widget.match;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: MundialitoColors.lime.withValues(
                        alpha: 0.9,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.matchDetails,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: MundialitoColors.smoke,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
              const SizedBox(height: 18),
              _DetailHero(match: match),
              const SizedBox(height: 18),
              _InfoPanel(match: match, language: controller.language),
              const SizedBox(height: 18),
              Text(
                strings.minuteByMinute,
                style: const TextStyle(
                  color: MundialitoColors.smoke,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (match.events.isEmpty)
                _NoEvents(text: strings.noEventsYet)
              else
                ...match.events.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EventTile(event: event),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadDetail() async {
    if (_isLoadingDetail) {
      return;
    }

    _isLoadingDetail = true;

    final detail = await MundialitoScope.of(
      context,
    ).loadMatchDetail(widget.match.id);
    if (!mounted) {
      return;
    }

    setState(() {
      if (detail != null) {
        _detail = detail;
      }
      _isLoadingDetail = false;
    });
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.match});

  final MundialMatch match;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: MundialitoColors.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (match.isLive) ...<Widget>[
                const LivePulse(size: 7),
                const SizedBox(width: 6),
              ],
              Text(
                match.isLive
                    ? "LIVE ${match.status.elapsed}'"
                    : match.status.long,
                style: TextStyle(
                  color: match.isLive
                      ? MundialitoColors.lime
                      : MundialitoColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(child: TeamBadge(team: match.home, size: 64)),
              SizedBox(
                width: 118,
                child: Text(
                  match.scoreText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MundialitoColors.smoke,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Expanded(child: TeamBadge(team: match.away, size: 64)),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: MundialitoColors.lime.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.flag_rounded,
                  size: 18,
                  color: MundialitoColors.lime,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.round,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: MundialitoColors.lime,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.match, required this.language});

  final MundialMatch match;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final controller = MundialitoScope.of(context);
    final strings = controller.strings;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MundialitoColors.panelSoft.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: <Widget>[
          _InfoRow(
            icon: Icons.calendar_month_rounded,
            label: DateText.matchDate(match.date, language),
          ),
          if (match.venueText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.stadium_rounded,
              label: '${strings.venue}: ${match.venueText}',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: MundialitoColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MundialitoColors.smoke,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final MatchEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MundialitoColors.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MundialitoColors.lime.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFor(event.type),
              color: MundialitoColors.lime,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${event.minuteLabel}  ${event.detail}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MundialitoColors.smoke,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    event.team.name,
                    if (event.player != null) event.player!,
                    if (event.assist != null) 'Asist. ${event.assist}',
                  ].join(' - '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MundialitoColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('goal')) {
      return Icons.sports_soccer_rounded;
    }
    if (lower.contains('card')) {
      return Icons.style_rounded;
    }
    if (lower.contains('subst')) {
      return Icons.swap_horiz_rounded;
    }
    return Icons.flash_on_rounded;
  }
}

class _NoEvents extends StatelessWidget {
  const _NoEvents({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MundialitoColors.panel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: MundialitoColors.muted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
