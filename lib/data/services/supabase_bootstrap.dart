import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';

/// Starts the Supabase client when the build supplied a safe project URL and
/// public key, and reports whether a client is available.
///
/// Scaffolding only: no table is read or written here. Startup is deliberately
/// best-effort, so a misconfigured or offline build still opens the POS, which
/// remains fully usable without sync.
Future<bool> initSupabaseIfConfigured() async {
  if (!SupabaseConfig.isConfigured) {
    final problem = SupabaseConfig.problem;
    if (problem != null) {
      debugPrint('[sync] disabled: $problem');
    }
    return false;
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url!,
      // `publishableKey` is the current name for what used to be `anonKey`.
      publishableKey: SupabaseConfig.key,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
        // This app has no OAuth deep-link flow.
        detectSessionInUri: false,
      ),
    );
    return true;
  } catch (error) {
    // Never let optional sync break startup. Log the type only: error text can
    // echo request details.
    debugPrint('[sync] initialization failed (${error.runtimeType}).');
    return false;
  }
}
