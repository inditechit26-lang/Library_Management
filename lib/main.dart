import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/router.dart';
import 'core/settings/app_settings.dart';

void main() => runApp(const ProviderScope(child: ShelfApp()));

class ShelfApp extends ConsumerWidget {
  const ShelfApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp.router(
      title: 'StudyDesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: Locale(settings.language.code),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
