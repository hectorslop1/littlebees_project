import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design_system/theme/app_theme.dart';
import 'design_system/theme/app_theme_dark.dart';
import 'routing/app_router.dart';
import 'core/i18n/locale_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class LittleBeesApp extends ConsumerWidget {
  const LittleBeesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Little Bees',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppThemeDark.theme,
      themeMode: themeMode,
      routerConfig: goRouter,
      locale: currentLocale,
      supportedLocales: const [Locale('en'), Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
