import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import '../features/mundial/data/football_api_service.dart';
import '../features/mundial/data/football_repository.dart';
import '../features/mundial/presentation/mundialito_controller.dart';
import '../features/mundial/presentation/pages/splash_page.dart';
import 'mundialito_scope.dart';

class MundialitoApp extends StatefulWidget {
  const MundialitoApp({
    required this.config,
    super.key,
  });

  final AppConfig config;

  @override
  State<MundialitoApp> createState() => _MundialitoAppState();
}

class _MundialitoAppState extends State<MundialitoApp> {
  late final MundialitoController _controller;

  @override
  void initState() {
    super.initState();
    final config = widget.config;
    final apiClient = ApiClient(
      baseUrl: config.flupibaseBaseUrl,
      projectId: config.flupibaseProjectId,
      apiKey: config.flupibaseApiKey,
      functionName: config.flupibaseFunctionName,
    );
    final api = FootballApiService(apiClient);
    final repository = FootballRepository(api);

    _controller = MundialitoController(
      config: config,
      repository: repository,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MundialitoScope(
          controller: _controller,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mundialito',
            theme: AppTheme.dark(),
            locale: Locale(_controller.language.name),
            home: const SplashPage(),
          ),
        );
      },
    );
  }
}
