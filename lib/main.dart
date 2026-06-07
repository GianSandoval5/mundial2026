import 'package:flutter/material.dart';

import 'app/mundialito_app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.load();
  runApp(MundialitoApp(config: config));
}
