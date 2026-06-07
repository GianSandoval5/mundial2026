import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/app_localizations.dart';
import '../data/football_repository.dart';
import '../domain/mundial_models.dart';

enum MundialHomeSection {
  live,
  schedule,
  groups,
  history,
}

class MundialitoController extends ChangeNotifier {
  MundialitoController({
    required this.config,
    required this.repository,
  }) : selectedSeason = config.defaultSeason;

  static const Duration realtimeRefreshInterval = Duration(seconds: 30);

  final AppConfig config;
  final FootballRepository repository;
  final Map<int, MundialSnapshot> _seasonCache = <int, MundialSnapshot>{};
  final Map<int, DateTime?> _dateBySeason = <int, DateTime?>{};
  final Set<int> _loadingSeasons = <int>{};

  AppLanguage language = AppLanguage.es;
  int selectedSeason;
  MundialHomeSection selectedSection = MundialHomeSection.live;
  DateTime? selectedDate;
  MundialSnapshot? snapshot;
  bool isLoading = false;
  bool isRefreshing = false;
  bool _isDisposed = false;
  Timer? _realtimeTimer;

  AppLocalizations get strings => AppLocalizations(language);

  bool get hasRemoteApi => repository.hasRemoteApi;
  bool get hasData => snapshot != null;
  bool get hasLoadedAnySeason => _seasonCache.isNotEmpty;

  List<MundialMatch> get filteredMatches {
    final data = snapshot;
    if (data == null) {
      return const <MundialMatch>[];
    }

    switch (selectedSection) {
      case MundialHomeSection.live:
        final live = data.matches.where((match) => match.isLive).toList();
        if (live.isNotEmpty) {
          return live;
        }
        return _matchesForSelectedDate(data);
      case MundialHomeSection.schedule:
        return _matchesForSelectedDate(data);
      case MundialHomeSection.groups:
        return data.matches
            .where((match) => match.round.toLowerCase().contains('group'))
            .toList();
      case MundialHomeSection.history:
        return data.matches.where((match) => match.isFinished).toList();
    }
  }

  List<MundialMatch> _matchesForSelectedDate(MundialSnapshot data) {
    final day = selectedDate;
    if (day == null) {
      return data.matches;
    }

    return data.matches.where((match) {
      final date = match.date.toLocal();
      return date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    }).toList();
  }

  Future<void> load() async {
    await _loadSeason(
      season: selectedSeason,
      showBlockingLoader: snapshot == null,
      keepSelectedDate: true,
    );
    _startRealtimeUpdates();
  }

  Future<void> refresh() async {
    await _loadSeason(
      season: selectedSeason,
      showBlockingLoader: snapshot == null,
      keepSelectedDate: true,
    );
  }

  Future<void> changeSeason(int season) async {
    if (season == selectedSeason) {
      return;
    }

    _dateBySeason[selectedSeason] = selectedDate;
    selectedSeason = season;
    snapshot = _seasonCache[season];
    selectedDate = _dateBySeason[season] ?? _initialDateForCached(snapshot);
    isLoading = snapshot == null;
    isRefreshing = snapshot != null;
    _notifyListeners();

    await _loadSeason(
      season: season,
      showBlockingLoader: snapshot == null,
      keepSelectedDate: snapshot != null,
    );
  }

  void changeLanguage(AppLanguage value) {
    if (value == language) {
      return;
    }

    language = value;
    _notifyListeners();
  }

  void toggleLanguage() {
    changeLanguage(language == AppLanguage.es ? AppLanguage.en : AppLanguage.es);
  }

  void selectSection(MundialHomeSection section) {
    if (section == selectedSection) {
      return;
    }

    selectedSection = section;
    _notifyListeners();
  }

  void selectDate(DateTime date) {
    if (selectedDate != null &&
        selectedDate!.year == date.year &&
        selectedDate!.month == date.month &&
        selectedDate!.day == date.day) {
      return;
    }

    selectedDate = date;
    _dateBySeason[selectedSeason] = date;
    _notifyListeners();
  }

  Future<MundialMatch?> loadMatchDetail(int fixtureId) {
    return repository.loadMatchDetail(
      fixtureId: fixtureId,
      season: selectedSeason,
    );
  }

  DateTime? _initialDateFor(MundialSnapshot data) {
    final featured = data.featuredMatch;
    if (featured != null) {
      final local = featured.date.toLocal();
      return DateTime(local.year, local.month, local.day);
    }

    final days = data.matchDays;
    return days.isEmpty ? null : days.first;
  }

  DateTime? _initialDateForCached(MundialSnapshot? data) {
    return data == null ? null : _initialDateFor(data);
  }

  Future<void> _loadSeason({
    required int season,
    required bool showBlockingLoader,
    required bool keepSelectedDate,
  }) async {
    if (_loadingSeasons.contains(season)) {
      return;
    }

    _loadingSeasons.add(season);
    if (showBlockingLoader) {
      isLoading = true;
      isRefreshing = false;
      _notifyListeners();
    } else {
      isRefreshing = true;
    }

    try {
      final loaded = await repository.loadSeason(season);
      if (_isDisposed) {
        return;
      }

      _seasonCache[season] = loaded;

      final nextDate = keepSelectedDate
          ? _dateBySeason[season] ?? selectedDate ?? _initialDateFor(loaded)
          : _initialDateFor(loaded);
      _dateBySeason[season] = nextDate;

      if (season != selectedSeason) {
        return;
      }

      snapshot = loaded;
      selectedDate = nextDate;
      isLoading = false;
      isRefreshing = false;
      _notifyListeners();
    } finally {
      _loadingSeasons.remove(season);
    }
  }

  void _startRealtimeUpdates() {
    if (!repository.hasRemoteApi || _realtimeTimer != null) {
      return;
    }

    _realtimeTimer = Timer.periodic(realtimeRefreshInterval, (_) {
      _loadSeason(
        season: selectedSeason,
        showBlockingLoader: false,
        keepSelectedDate: true,
      );
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _realtimeTimer?.cancel();
    super.dispose();
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
