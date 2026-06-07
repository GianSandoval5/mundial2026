import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class SeasonSelector extends StatelessWidget {
  const SeasonSelector({
    required this.seasons,
    required this.selectedSeason,
    required this.strings,
    required this.onChanged,
    super.key,
  });

  final List<int> seasons;
  final int selectedSeason;
  final AppLocalizations strings;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final season = seasons[index];
          final selected = season == selectedSeason;
          return ChoiceChip(
            selected: selected,
            label: Text(
              season == 2026 ? '${strings.season} $season' : '$season',
            ),
            labelStyle: TextStyle(
              color:
                  selected ? MundialitoColors.pitch : MundialitoColors.smoke,
              fontWeight: FontWeight.w800,
            ),
            selectedColor: MundialitoColors.lime,
            backgroundColor: MundialitoColors.panelSoft,
            side: BorderSide(
              color: selected
                  ? MundialitoColors.lime
                  : Colors.white.withValues(alpha: 0.08),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (_) => onChanged(season),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: seasons.length,
      ),
    );
  }
}
