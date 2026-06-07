import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/mundial_models.dart';
import 'team_badge.dart';

class StandingsPanel extends StatelessWidget {
  const StandingsPanel({
    required this.rows,
    required this.strings,
    super.key,
  });

  final List<StandingRow> rows;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final grouped = <String, List<StandingRow>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.group, () => <StandingRow>[]).add(row);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.standings,
          style: const TextStyle(
            color: MundialitoColors.smoke,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        ...grouped.entries.take(4).map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GroupTable(
              group: entry.key,
              rows: entry.value,
              strings: strings,
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupTable extends StatelessWidget {
  const _GroupTable({
    required this.group,
    required this.rows,
    required this.strings,
  });

  final String group;
  final List<StandingRow> rows;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MundialitoColors.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            group,
            style: const TextStyle(
              color: MundialitoColors.lime,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${row.rank}',
                      style: const TextStyle(
                        color: MundialitoColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TeamBadge(team: row.team, size: 28, showName: false),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      row.team.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MundialitoColors.smoke,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    strings.playedShort(row.played),
                    style: const TextStyle(
                      color: MundialitoColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    strings.pointsShort(row.points),
                    style: const TextStyle(
                      color: MundialitoColors.lime,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
