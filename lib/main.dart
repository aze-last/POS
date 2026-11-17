import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/services/supabase_bootstrap.dart';
import 'presentation/screens/pos/pos_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait-only orientation (Spec Section 1)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Optional Step 9 scaffold. No-op unless the build supplied SUPABASE_URL and
  // a public key; never blocks startup and never fails the app.
  await initSupabaseIfConfigured();

  runApp(const ProviderScope(child: BananaPosApp()));
}

class BananaPosApp extends StatelessWidget {
  const BananaPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banana POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PosScreen(),
    );
  }
}
