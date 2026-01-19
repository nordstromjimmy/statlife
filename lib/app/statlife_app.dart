import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/l10n/app_localizations.dart';
import 'router.dart';
import 'theme.dart';

class StatlifeApp extends ConsumerWidget {
  const StatlifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Evolvem',
      theme: AppTheme.dark(),
      routerConfig: router,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add your custom delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('sv', '')],
    );
  }
}
