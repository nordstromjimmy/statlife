import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class StatlifeApp extends StatelessWidget {
  const StatlifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Statlife',
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
