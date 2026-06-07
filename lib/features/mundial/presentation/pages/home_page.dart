import 'package:flutter/material.dart';

import '../../../../app/mundialito_scope.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/mundial_models.dart';
import '../mundialito_controller.dart';
import '../widgets/app_background.dart';
import '../widgets/date_strip.dart';
import '../widgets/loading_home_skeleton.dart';
import '../widgets/match_cards.dart';
import '../widgets/season_selector.dart';
import '../widgets/section_selector.dart';
import '../widgets/standings_panel.dart';
import '../widgets/status_banner.dart';
import 'match_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MundialitoScope.of(context);
    final strings = controller.strings;
    final snapshot = controller.snapshot;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: MundialitoColors.lime,
            backgroundColor: MundialitoColors.panel,
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: <Widget>[
                _HomeHeader(controller: controller),
                const SizedBox(height: 22),
                _HeroCopy(controller: controller),
                const SizedBox(height: 18),
                SeasonSelector(
                  seasons: controller.config.supportedSeasons,
                  selectedSeason: controller.selectedSeason,
                  strings: strings,
                  onChanged: (season) {
                    controller.changeSeason(season);
                  },
                ),
                const SizedBox(height: 16),
                SectionSelector(
                  selected: controller.selectedSection,
                  strings: strings,
                  onChanged: controller.selectSection,
                ),
                const SizedBox(height: 16),
                if (snapshot == null &&
                    controller.isLoading &&
                    !controller.hasLoadedAnySeason)
                  const LoadingHomeSkeleton()
                else if (snapshot != null)
                  _HomeData(
                    snapshot: snapshot,
                    controller: controller,
                  )
                else if (controller.isLoading)
                  _InlineLoadingState(text: strings.loadingSeason)
                else
                  _EmptyState(text: strings.noMatches),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeData extends StatelessWidget {
  const _HomeData({
    required this.snapshot,
    required this.controller,
  });

  final MundialSnapshot snapshot;
  final MundialitoController controller;

  @override
  Widget build(BuildContext context) {
    final strings = controller.strings;
    final featured = snapshot.featuredMatch;
    final matches = controller.filteredMatches;
    final showGroups = controller.selectedSection == MundialHomeSection.groups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StatusBanner(
          mode: snapshot.mode,
          strings: strings,
          message: snapshot.message,
        ),
        const SizedBox(height: 18),
        if (featured != null) ...<Widget>[
          _SectionTitle(
            title: strings.featuredMatch,
            action: strings.refresh,
            onAction: () {
              controller.refresh();
            },
          ),
          const SizedBox(height: 12),
          FeaturedMatchCard(
            match: featured,
            strings: strings,
            language: controller.language,
            onTap: () => _openMatch(context, featured),
          ),
          const SizedBox(height: 20),
        ],
        DateStrip(
          days: snapshot.matchDays,
          selectedDay: controller.selectedDate,
          language: controller.language,
          onChanged: controller.selectDate,
        ),
        const SizedBox(height: 18),
        if (showGroups)
          StandingsPanel(rows: snapshot.standings, strings: strings)
        else ...<Widget>[
          _SectionTitle(
            title: strings.topEvents,
            action: strings.viewAll,
            onAction: () {
              controller.selectSection(MundialHomeSection.schedule);
            },
          ),
          const SizedBox(height: 12),
          if (matches.isEmpty)
            _EmptyState(text: strings.noMatches)
          else
            ...matches.map(
              (match) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MatchCard(
                  match: match,
                  strings: strings,
                  language: controller.language,
                  onTap: () => _openMatch(context, match),
                ),
              ),
            ),
          if (snapshot.standings.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            StandingsPanel(
              rows: snapshot.standings.take(8).toList(),
              strings: strings,
            ),
          ],
        ],
      ],
    );
  }

  void _openMatch(BuildContext context, MundialMatch match) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MatchDetailPage(match: match),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller});

  final MundialitoController controller;

  @override
  Widget build(BuildContext context) {
    final strings = controller.strings;

    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: MundialitoColors.lime.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(
              color: MundialitoColors.lime.withValues(alpha: 0.38),
            ),
          ),
          child: const Icon(
            Icons.sports_soccer_rounded,
            color: MundialitoColors.lime,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.greeting,
                style: const TextStyle(
                  color: MundialitoColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                strings.fanName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: MundialitoColors.smoke,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        _RoundIconButton(
          tooltip: strings.languageAction,
          icon: Icons.language_rounded,
          label: controller.language.name.toUpperCase(),
          onTap: controller.toggleLanguage,
        ),
        const SizedBox(width: 8),
        _RoundIconButton(
          tooltip: strings.refresh,
          icon: Icons.refresh_rounded,
          onTap: () {
            controller.refresh();
          },
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.controller});

  final MundialitoController controller;

  @override
  Widget build(BuildContext context) {
    final strings = controller.strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${strings.appName} ${controller.selectedSeason}',
          style: const TextStyle(
            color: MundialitoColors.smoke,
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.subtitle,
          style: const TextStyle(
            color: MundialitoColors.muted,
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: MundialitoColors.smoke,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                color: MundialitoColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.label,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: MundialitoColors.panelSoft.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(icon, size: 20, color: MundialitoColors.smoke),
              if (label != null)
                Positioned(
                  bottom: 6,
                  child: Text(
                    label!,
                    style: const TextStyle(
                      color: MundialitoColors.lime,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineLoadingState extends StatelessWidget {
  const _InlineLoadingState({required this.text});

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: MundialitoColors.lime,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MundialitoColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

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
