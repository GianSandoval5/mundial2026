import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_text.dart';

class DateStrip extends StatelessWidget {
  const DateStrip({
    required this.days,
    required this.selectedDay,
    required this.language,
    required this.onChanged,
    super.key,
  });

  final List<DateTime> days;
  final DateTime? selectedDay;
  final AppLanguage language;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 66,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = _sameDay(day, selectedDay);
          return GestureDetector(
            onTap: () => onChanged(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? MundialitoColors.lime
                    : MundialitoColors.panelSoft.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? MundialitoColors.lime
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                DateText.dayChip(day, language),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? MundialitoColors.pitch
                      : MundialitoColors.smoke,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: days.length,
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime? b) {
    if (b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
