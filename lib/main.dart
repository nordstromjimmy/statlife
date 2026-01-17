import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/statlife_app.dart';
import 'application/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://tmuzyqscxgzokbdkaarq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtdXp5cXNjeGd6b2tiZGthYXJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg2Mjg2NDEsImV4cCI6MjA4NDIwNDY0MX0.BEubep7i-QGwF9MQEg-Pfpe9xqMwTopchxBtHFXpZVA',
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const StatlifeApp(),
    ),
  );
}
