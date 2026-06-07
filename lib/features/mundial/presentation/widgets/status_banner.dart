import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/mundial_models.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    required this.mode,
    required this.strings,
    this.message,
    super.key,
  });

  final MundialDataMode mode;
  final AppLocalizations strings;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final remote = mode == MundialDataMode.remote;
    final title = switch (mode) {
      MundialDataMode.remote => strings.statusConfigured,
      MundialDataMode.notConfigured => strings.statusNeedsConfig,
      MundialDataMode.error => strings.statusError,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: remote
            ? MundialitoColors.lime.withValues(alpha: 0.14)
            : MundialitoColors.panelSoft.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: remote
              ? MundialitoColors.lime.withValues(alpha: 0.32)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            remote ? Icons.cloud_done_rounded : Icons.info_outline_rounded,
            size: 18,
            color: remote ? MundialitoColors.lime : MundialitoColors.muted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message == null || remote ? title : '$title: $message',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: remote ? MundialitoColors.lime : MundialitoColors.smoke,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
