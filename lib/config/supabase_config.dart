import 'dart:convert';

/// Build-time configuration for the optional Supabase sync backend (Step 9).
///
/// The app may only ever hold the project URL and a **public** key:
/// `sb_publishable_...` or the legacy `anon` JWT. Both are injected at build
/// time and are never committed:
///
/// ```sh
/// flutter run --dart-define-from-file=.env
/// flutter build apk --release --dart-define-from-file=.env
/// ```
///
/// `.env` is gitignored; `.env.example` lists the accepted names. When either
/// value is missing or fails validation, sync stays off and the app behaves
/// exactly as it does today: offline, with no Supabase traffic.
///
/// The direct Postgres connection string
/// (`postgresql://postgres:...@db.<ref>.supabase.co:5432/postgres`) is an admin
/// credential. [checkUrl] and [checkKey] reject it on purpose, and reject any
/// JWT whose role is not a client role.
class SupabaseConfig {
  const SupabaseConfig._();

  static const String _urlValue = String.fromEnvironment('SUPABASE_URL');
  static const String _anonKeyValue = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const String _publishableKeyValue = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static String get _keyValue =>
      _anonKeyValue.isNotEmpty ? _anonKeyValue : _publishableKeyValue;

  static final String? _validUrl = checkUrl(_urlValue) == null
      ? _urlValue.trim()
      : null;
  static final String? _validKey = checkKey(_keyValue) == null
      ? _keyValue.trim()
      : null;

  /// The validated project URL, or `null` when sync is unavailable.
  static String? get url => _validUrl;

  /// The validated public key, or `null` when sync is unavailable.
  static String? get key => _validKey;

  /// True only when both build-time values are present and safe to use.
  static bool get isConfigured => _validUrl != null && _validKey != null;

  /// A human-readable reason sync is off, for debug logs only.
  ///
  /// `null` when sync is configured, or when no values were supplied at all
  /// (the default offline build). Never contains credential material.
  static String? get problem {
    if (_urlValue.trim().isEmpty && _keyValue.trim().isEmpty) return null;
    return checkUrl(_urlValue) ?? checkKey(_keyValue);
  }

  /// Returns an error message when [value] is not a public Supabase project
  /// URL, or `null` when it is safe to hand to the client.
  static String? checkUrl(String value) {
    final candidate = value.trim();
    if (candidate.isEmpty) return 'SUPABASE_URL is missing.';

    final Uri uri;
    try {
      uri = Uri.parse(candidate);
    } on FormatException {
      return 'SUPABASE_URL is not a valid URI.';
    }

    if (uri.scheme != 'https') {
      return 'SUPABASE_URL must use https.';
    }
    if (uri.host.isEmpty) {
      return 'SUPABASE_URL has no host.';
    }
    if (uri.userInfo.isNotEmpty) {
      return 'SUPABASE_URL must not contain credentials.';
    }
    if (uri.hasQuery || uri.hasFragment) {
      return 'SUPABASE_URL must be a bare project URL.';
    }
    if (uri.path.isNotEmpty && uri.path != '/') {
      return 'SUPABASE_URL must not include a path.';
    }
    if (uri.hasPort && uri.port != 443) {
      return 'SUPABASE_URL must not use port ${uri.port}. '
          'The app talks to the HTTPS API, not Postgres.';
    }
    if (uri.host.startsWith('db.') || uri.host.startsWith('pooler.')) {
      return 'SUPABASE_URL points at a database host. '
          'Use https://<project-ref>.supabase.co instead.';
    }
    return null;
  }

  /// Returns an error message when [value] is not a public Supabase key, or
  /// `null` when it is safe to ship in the app.
  static String? checkKey(String value) {
    final candidate = value.trim();
    if (candidate.isEmpty) {
      return 'SUPABASE_ANON_KEY (or SUPABASE_PUBLISHABLE_KEY) is missing.';
    }
    if (RegExp(r'\s').hasMatch(candidate)) {
      return 'The public key contains whitespace.';
    }

    final lower = candidate.toLowerCase();
    if (lower.startsWith('postgres://') || lower.startsWith('postgresql://')) {
      return 'The key slot contains a Postgres connection string. '
          'Admin credentials must never ship in the app.';
    }
    if (lower.startsWith('sb_secret_')) {
      return 'sb_secret_ keys bypass Row Level Security and must never ship '
          'in the app.';
    }

    final segments = candidate.split('.');
    if (segments.length == 3) {
      final payload = _decodeJwtPayload(segments[1]);
      if (payload == null) {
        return 'The JWT payload cannot be decoded.';
      }
      final role = payload['role'];
      if (role is! String) {
        return 'The JWT has no role claim.';
      }
      if (role != 'anon' && role != 'authenticated') {
        return 'JWT role "$role" is not a client role. '
            'service_role bypasses Row Level Security.';
      }
      return null;
    }

    if (candidate.startsWith('sb_publishable_')) return null;

    return 'Unrecognized public key. '
        'Expected sb_publishable_... or a legacy anon JWT.';
  }

  static Map<String, dynamic>? _decodeJwtPayload(String segment) {
    try {
      final normalized = base64Url.normalize(segment);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
