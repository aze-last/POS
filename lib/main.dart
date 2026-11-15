import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/screens/pos/pos_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait-only orientation (Spec Section 1)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
