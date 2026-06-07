import 'package:flutter/services.dart';

class AppConfig {
  const AppConfig({
    required this.flupibaseBaseUrl,
    required this.flupibaseProjectId,
    required this.flupibaseApiKey,
    required this.flupibaseFunctionName,
    required this.defaultSeason,
    required this.supportedSeasons,
  });

  factory AppConfig.fromEnvironment([Map<String, String> fileValues = const {}]) {
    const flupibaseBaseUrl = String.fromEnvironment(
      'FLUPIBASE_BASE_URL',
    );
    const flupibaseProjectId = String.fromEnvironment('FLUPIBASE_PROJECT_ID');
    const flupibaseApiKey = String.fromEnvironment('FLUPIBASE_API_KEY');
    const flupibaseFunctionName = String.fromEnvironment(
      'FLUPIBASE_FUNCTION_NAME',
    );

    return AppConfig(
      flupibaseBaseUrl: _pick(
        key: 'FLUPIBASE_BASE_URL',
        dartDefineValue: flupibaseBaseUrl,
        fileValues: fileValues,
        fallback: 'https://flupibase.com/api/v1',
      ),
      flupibaseProjectId: _pick(
        key: 'FLUPIBASE_PROJECT_ID',
        dartDefineValue: flupibaseProjectId,
        fileValues: fileValues,
      ),
      flupibaseApiKey: _pick(
        key: 'FLUPIBASE_API_KEY',
        dartDefineValue: flupibaseApiKey,
        fileValues: fileValues,
      ),
      flupibaseFunctionName: _pick(
        key: 'FLUPIBASE_FUNCTION_NAME',
        dartDefineValue: flupibaseFunctionName,
        fileValues: fileValues,
        fallback: 'mundialito-football',
      ),
      defaultSeason: 2026,
      supportedSeasons: <int>[2026, 2022, 2018, 2014, 2010, 2006],
    );
  }

  static Future<AppConfig> load() async {
    final fileValues = await EnvFileLoader.load();
    return AppConfig.fromEnvironment(fileValues);
  }

  final String flupibaseBaseUrl;
  final String flupibaseProjectId;
  final String flupibaseApiKey;
  final String flupibaseFunctionName;
  final int defaultSeason;
  final List<int> supportedSeasons;

  bool get hasRemoteApi =>
      flupibaseBaseUrl.trim().isNotEmpty &&
      flupibaseProjectId.trim().isNotEmpty &&
      flupibaseApiKey.trim().isNotEmpty &&
      flupibaseFunctionName.trim().isNotEmpty;

  static String _pick({
    required String key,
    required String dartDefineValue,
    required Map<String, String> fileValues,
    String fallback = '',
  }) {
    final dartDefine = dartDefineValue.trim();
    if (dartDefine.isNotEmpty) {
      return dartDefine;
    }

    final fileValue = fileValues[key]?.trim();
    if (fileValue != null && fileValue.isNotEmpty) {
      return fileValue;
    }

    return fallback;
  }
}

class EnvFileLoader {
  static const _paths = <String>[
    'config/.env',
  ];

  static Future<Map<String, String>> load() async {
    final values = <String, String>{};

    for (final path in _paths) {
      try {
        final content = await rootBundle.loadString(path);
        values.addAll(parse(content));
      } catch (_) {
        // Missing env assets are allowed so release builds can use dart-define.
      }
    }

    return values;
  }

  static Map<String, String> parse(String content) {
    final values = <String, String>{};
    final lines = content.split(RegExp(r'\r?\n'));

    for (final rawLine in lines) {
      var line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }

      if (line.startsWith('export ')) {
        line = line.substring(7).trim();
      }

      final separator = line.indexOf('=');
      if (separator <= 0) {
        continue;
      }

      final key = line.substring(0, separator).trim();
      final value = _stripQuotes(line.substring(separator + 1).trim());
      if (key.isNotEmpty) {
        values[key] = value;
      }
    }

    return values;
  }

  static String _stripQuotes(String value) {
    if (value.length < 2) {
      return value;
    }

    final first = value[0];
    final last = value[value.length - 1];
    if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
      return value.substring(1, value.length - 1);
    }

    return value;
  }
}
