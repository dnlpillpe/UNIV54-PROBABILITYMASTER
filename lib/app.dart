/// Configuración de la aplicación y navegación raíz.
library;

import 'package:flutter/material.dart';

import 'core/constants/app_info.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/root_shell.dart';

class ProbabilityMasterApp extends StatelessWidget {
  const ProbabilityMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const RootShell(),
    );
  }
}
