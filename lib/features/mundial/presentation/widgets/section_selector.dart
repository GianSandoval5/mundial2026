import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../mundialito_controller.dart';

class SectionSelector extends StatelessWidget {
  const SectionSelector({
    required this.selected,
    required this.strings,
    required this.onChanged,
    super.key,
  });

  final MundialHomeSection selected;
  final AppLocalizations strings;
  final ValueChanged<MundialHomeSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <_SectionItem>[
      _SectionItem(MundialHomeSection.live, Icons.sensors_rounded, strings.live),
      _SectionItem(
        MundialHomeSection.schedule,
        Icons.calendar_month_rounded,
        strings.schedule,
      ),
      _SectionItem(
        MundialHomeSection.groups,
        Icons.table_chart_rounded,
        strings.groups,
      ),
      _SectionItem(
        MundialHomeSection.history,
        Icons.history_rounded,
        strings.history,
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.section == selected;
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onChanged(item.section),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? MundialitoColors.lime
                    : MundialitoColors.panelSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? MundialitoColors.lime
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    item.icon,
                    size: 18,
                    color: isSelected
                        ? MundialitoColors.pitch
                        : MundialitoColors.smoke,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected
                          ? MundialitoColors.pitch
                          : MundialitoColors.smoke,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}

class _SectionItem {
  const _SectionItem(this.section, this.icon, this.label);

  final MundialHomeSection section;
  final IconData icon;
  final String label;
}
