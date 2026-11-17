import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos/config/supabase_config.dart';

String _jwt(Map<String, dynamic> payload) {
  String encode(Map<String, dynamic> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${encode(payload)}.signature';
}

void main() {
  group('SupabaseConfig.checkUrl', () {
    test('accepts a bare https project URL', () {
      expect(SupabaseConfig.checkUrl('https://abc.supabase.co'), isNull);
      expect(SupabaseConfig.checkUrl('  https://abc.supabase.co  '), isNull);
      expect(SupabaseConfig.checkUrl('https://abc.supabase.co/'), isNull);
      expect(SupabaseConfig.checkUrl('https://abc.supabase.co:443'), isNull);
    });

    test('rejects missing, non-https, and malformed URLs', () {
      expect(SupabaseConfig.checkUrl(''), isNotNull);
      expect(SupabaseConfig.checkUrl('   '), isNotNull);
      expect(SupabaseConfig.checkUrl('http://abc.supabase.co'), isNotNull);
      expect(SupabaseConfig.checkUrl('abc.supabase.co'), isNotNull);
      expect(
        SupabaseConfig.checkUrl('https://user:pass@abc.supabase.co'),
        isNotNull,
      );
      expect(
        SupabaseConfig.checkUrl('https://abc.supabase.co/rest/v1'),
        isNotNull,
      );
      expect(
        SupabaseConfig.checkUrl('https://abc.supabase.co?apikey=x'),
        isNotNull,
      );
    });

    test('rejects direct database, pooler, and Postgres endpoints', () {
      expect(SupabaseConfig.checkUrl('https://db.abc.supabase.co'), isNotNull);
      expect(
        SupabaseConfig.checkUrl('https://db.abc.supabase.co:5432'),
        isNotNull,
      );
      expect(
        SupabaseConfig.checkUrl('https://abc.supabase.co:5432'),
        isNotNull,
      );
      expect(
        SupabaseConfig.checkUrl('https://abc.supabase.co:6543'),
        isNotNull,
      );
      expect(SupabaseConfig.checkUrl('https://pooler.supabase.com'), isNotNull);
      // Credential-free Postgres URI: the scheme alone must be rejected.
      expect(
        SupabaseConfig.checkUrl(
          'postgresql://db.abc.supabase.co:5432/postgres',
        ),
        isNotNull,
      );
    });
  });

  group('SupabaseConfig.checkKey', () {
    test('accepts anon JWTs, authenticated JWTs, and publishable keys', () {
      expect(SupabaseConfig.checkKey(_jwt({'role': 'anon'})), isNull);
      expect(SupabaseConfig.checkKey(_jwt({'role': 'authenticated'})), isNull);
      expect(SupabaseConfig.checkKey('sb_publishable_abc123'), isNull);
    });

    test('rejects admin credentials and unknown formats', () {
      expect(SupabaseConfig.checkKey(''), isNotNull);
      expect(SupabaseConfig.checkKey('   '), isNotNull);
      expect(SupabaseConfig.checkKey('not-a-key'), isNotNull);
      expect(SupabaseConfig.checkKey('sb_publishable_abc 123'), isNotNull);
      expect(
        SupabaseConfig.checkKey(_jwt({'role': 'service_role'})),
        isNotNull,
      );
      expect(SupabaseConfig.checkKey('sb_secret_abc123'), isNotNull);
      expect(
        SupabaseConfig.checkKey(
          'postgresql://db.abc.supabase.co:5432/postgres',
        ),
        isNotNull,
      );
      expect(
        SupabaseConfig.checkKey('${_jwt({'role': 'anon'})}.extra'),
        isNotNull,
      );
    });

    test('rejects malformed or role-less JWTs', () {
      expect(SupabaseConfig.checkKey('a.b.c'), isNotNull);
      expect(SupabaseConfig.checkKey(_jwt({'sub': 'device'})), isNotNull);
    });
  });
}
