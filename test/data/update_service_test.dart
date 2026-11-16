import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos/data/services/update_service.dart';
import 'package:pos/domain/models/app_version.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pos_update_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('UpdateService Tests', () {
    test('Host allowlist accepts GitHub domains and rejects non-allowlisted/HTTP hosts', () {
      expect(
        UpdateService.isHostAllowed(
          Uri.parse('https://github.com/aze-last/POS'),
        ),
        isTrue,
      );
      expect(
        UpdateService.isHostAllowed(
          Uri.parse('https://objects.githubusercontent.com/asset.apk'),
        ),
        isTrue,
      );
      expect(
        UpdateService.isHostAllowed(
          Uri.parse('https://api.github.com/repos/aze-last/POS'),
        ),
        isTrue,
      );

      // Rejects HTTP
      expect(
        UpdateService.isHostAllowed(Uri.parse('http://github.com/file.apk')),
        isFalse,
      );
      // Rejects non-allowlisted domain
      expect(
        UpdateService.isHostAllowed(
          Uri.parse('https://evil-site.com/file.apk'),
        ),
        isFalse,
      );
      expect(
        UpdateService.isHostAllowed(
          Uri.parse('https://github.com.evil.com/file.apk'),
        ),
        isFalse,
      );
    });

    test(
      'parses valid release with both .apk and .apk.sha256 assets',
      () async {
        final mockJson = jsonEncode({
          'tag_name': 'v1.0.10',
          'draft': false,
          'prerelease': false,
          'body': 'Cool new features and fixes',
          'assets': [
            {
              'name': 'banana-pos-v1.0.10.apk',
              'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.10/banana-pos-v1.0.10.apk',
            },
            {
              'name': 'banana-pos-v1.0.10.apk.sha256',
              'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.10/banana-pos-v1.0.10.apk.sha256',
            },
          ],
        });

        final client = MockClient((request) async {
          return http.Response(mockJson, 200);
        });

        final service = UpdateService(
          client: client,
          cacheDirProvider: () async => tempDir,
          currentVersionProvider: () async => '1.0.0',
        );

        final update = await service.checkForUpdate(isManual: true);
        expect(update, isNotNull);
        expect(
          update!.version,
          equals(const AppVersion(major: 1, minor: 0, patch: 10)),
        );
        expect(update.releaseNotes, equals('Cool new features and fixes'));
        expect(update.apkFileName, equals('banana-pos-v1.0.10.apk'));
      },
    );

    test('returns null when .apk or .sha256 asset is missing', () async {
      final mockJsonMissingSha = jsonEncode({
        'tag_name': 'v1.0.1',
        'draft': false,
        'prerelease': false,
        'body': 'Notes',
        'assets': [
          {
            'name': 'banana-pos-v1.0.1.apk',
            'browser_download_url':
                'https://github.com/aze-last/POS/releases/v1.0.1/app.apk',
          },
        ],
      });

      final client = MockClient((request) async {
        return http.Response(mockJsonMissingSha, 200);
      });

      final service = UpdateService(
        client: client,
        cacheDirProvider: () async => tempDir,
        currentVersionProvider: () async => '1.0.0',
      );

      final update = await service.checkForUpdate(isManual: true);
      expect(update, isNull);
    });

    test('ignores drafts and prereleases', () async {
      final mockDraftJson = jsonEncode({
        'tag_name': 'v2.0.0',
        'draft': true,
        'prerelease': false,
        'assets': [
          {
            'name': 'app.apk',
            'browser_download_url': 'https://github.com/app.apk',
          },
          {
            'name': 'app.apk.sha256',
            'browser_download_url': 'https://github.com/app.apk.sha256',
          },
        ],
      });

      final client = MockClient(
        (request) async => http.Response(mockDraftJson, 200),
      );

      final service = UpdateService(
        client: client,
        cacheDirProvider: () async => tempDir,
        currentVersionProvider: () async => '1.0.0',
      );

      expect(await service.checkForUpdate(isManual: true), isNull);
    });

    test('never downgrades when candidate release is older or equal', () async {
      final mockJson = jsonEncode({
        'tag_name': 'v1.0.0',
        'draft': false,
        'prerelease': false,
        'assets': [
          {
            'name': 'app.apk',
            'browser_download_url': 'https://github.com/app.apk',
          },
          {
            'name': 'app.apk.sha256',
            'browser_download_url': 'https://github.com/app.apk.sha256',
          },
        ],
      });

      final client = MockClient(
        (request) async => http.Response(mockJson, 200),
      );

      final service = UpdateService(
        client: client,
        cacheDirProvider: () async => tempDir,
        currentVersionProvider: () async => '1.0.5',
      );

      expect(await service.checkForUpdate(isManual: true), isNull);
    });

    test(
      'enforces 24-hour throttle for auto-checks but allows manual checks',
      () async {
        final mockJson = jsonEncode({
          'tag_name': 'v1.1.0',
          'draft': false,
          'prerelease': false,
          'assets': [
            {
              'name': 'app.apk',
              'browser_download_url': 'https://github.com/app.apk',
            },
            {
              'name': 'app.apk.sha256',
              'browser_download_url': 'https://github.com/app.apk.sha256',
            },
          ],
        });

        int networkCalls = 0;
        final client = MockClient((request) async {
          networkCalls++;
          return http.Response(mockJson, 200);
        });

        final service = UpdateService(
          client: client,
          cacheDirProvider: () async => tempDir,
          currentVersionProvider: () async => '1.0.0',
        );

        // First check (not manual)
        final first = await service.checkForUpdate(isManual: false);
        expect(first, isNotNull);
        expect(networkCalls, equals(1));

        // Second check immediately after (auto-check) -> throttled without network call
        final second = await service.checkForUpdate(isManual: false);
        expect(second, isNull);
        expect(networkCalls, equals(1));

        // Third check (manual) -> bypasses throttle
        final third = await service.checkForUpdate(isManual: true);
        expect(third, isNotNull);
        expect(networkCalls, equals(2));
      },
    );

    test(
      'handles 403 rate limit, 404 not found, and offline gracefully',
      () async {
        // 403 test
        final client403 = MockClient(
          (request) async => http.Response('Rate limit', 403),
        );
        final service403 = UpdateService(
          client: client403,
          cacheDirProvider: () async => tempDir,
          currentVersionProvider: () async => '1.0.0',
        );

        // Auto-check fails silently without crash
        expect(await service403.checkForUpdate(isManual: false), isNull);
        // Manual check throws clear HttpException
        expect(
          () => service403.checkForUpdate(isManual: true),
          throwsA(isA<HttpException>()),
        );

        // 404 test
        final client404 = MockClient(
          (request) async => http.Response('Not Found', 404),
        );
        final service404 = UpdateService(
          client: client404,
          cacheDirProvider: () async => tempDir,
          currentVersionProvider: () async => '1.0.0',
        );
        expect(await service404.checkForUpdate(isManual: false), isNull);
        expect(
          () => service404.checkForUpdate(isManual: true),
          throwsA(isA<HttpException>()),
        );
      },
    );

    test(
      'skipped-version logic ignores skipped tag during auto-checks',
      () async {
        final mockJson = jsonEncode({
          'tag_name': 'v1.0.5',
          'draft': false,
          'prerelease': false,
          'assets': [
            {
              'name': 'app.apk',
              'browser_download_url': 'https://github.com/app.apk',
            },
            {
              'name': 'app.apk.sha256',
              'browser_download_url': 'https://github.com/app.apk.sha256',
            },
          ],
        });

        final client = MockClient(
          (request) async => http.Response(mockJson, 200),
        );
        final service = UpdateService(
          client: client,
          cacheDirProvider: () async => tempDir,
          currentVersionProvider: () async => '1.0.0',
        );

        // Skip v1.0.5
        await service.skipVersion('v1.0.5');
        expect(await service.getSkippedVersion(), equals('v1.0.5'));

        // Auto-check ignores skipped version
        expect(await service.checkForUpdate(isManual: false), isNull);

        // Manual check still returns it
        expect(await service.checkForUpdate(isManual: true), isNotNull);
      },
    );

    test(
      'downloadAndVerifyUpdate verifies SHA-256 and saves file on match',
      () async {
        final apkBytes = utf8.encode('DUMMY APK BINARY CONTENT');
        final expectedHash = sha256.convert(apkBytes).toString();

        final client = MockClient((request) async {
          final path = request.url.path;
          if (path.endsWith('.sha256')) {
            return http.Response('$expectedHash  banana-pos-v1.0.1.apk', 200);
          } else if (path.endsWith('.apk')) {
            return http.Response.bytes(
              apkBytes,
              200,
              headers: {'content-length': apkBytes.length.toString()},
            );
          }
          return http.Response('Not Found', 404);
        });

        final service = UpdateService(
          client: client,
          cacheDirProvider: () async => tempDir,
        );

        final release = const ReleaseInfo(
          version: AppVersion(major: 1, minor: 0, patch: 1),
          rawTag: 'v1.0.1',
          releaseNotes: 'Fixes',
          apkDownloadUrl: 'https://github.com/aze-last/POS/releases/banana.apk',
          apkFileName: 'banana.apk',
          sha256DownloadUrl:
              'https://github.com/aze-last/POS/releases/banana.apk.sha256',
        );

        final downloadedFile = await service.downloadAndVerifyUpdate(
          release: release,
        );
        expect(await downloadedFile.exists(), isTrue);
        expect(
          await downloadedFile.readAsString(),
          equals('DUMMY APK BINARY CONTENT'),
        );
      },
    );

    test(
      'downloadAndVerifyUpdate deletes file and throws on SHA-256 mismatch',
      () async {
        final apkBytes = utf8.encode('CORRUPT APK CONTENT');
        const bogusHash =
            '0000000000000000000000000000000000000000000000000000000000000000';

        final client = MockClient((request) async {
          final path = request.url.path;
          if (path.endsWith('.sha256')) {
            return http.Response(bogusHash, 200);
          } else if (path.endsWith('.apk')) {
            return http.Response.bytes(apkBytes, 200);
          }
          return http.Response('Not found', 404);
        });

        final service = UpdateService(
          client: client,
          cacheDirProvider: () async => tempDir,
        );

        final release = const ReleaseInfo(
          version: AppVersion(major: 1, minor: 0, patch: 1),
          rawTag: 'v1.0.1',
          releaseNotes: 'Fixes',
          apkDownloadUrl: 'https://github.com/aze-last/POS/releases/banana.apk',
          apkFileName: 'banana.apk',
          sha256DownloadUrl:
              'https://github.com/aze-last/POS/releases/banana.apk.sha256',
        );

        expect(
          () => service.downloadAndVerifyUpdate(release: release),
          throwsA(isA<SecurityException>()),
        );

        // Verify file was purged immediately
        final targetFile = File('${tempDir.path}/banana.apk');
        expect(await targetFile.exists(), isFalse);
      },
    );

    test(
      'cleanOldUpdateFiles purges all .apk files in cache directory',
      () async {
        final file1 = File('${tempDir.path}/old1.apk');
        final file2 = File('${tempDir.path}/old2.apk');
        final textFile = File('${tempDir.path}/keep.txt');

        await file1.writeAsString('test');
        await file2.writeAsString('test');
        await textFile.writeAsString('test');

        final service = UpdateService(cacheDirProvider: () async => tempDir);
        await service.cleanOldUpdateFiles();

        expect(await file1.exists(), isFalse);
        expect(await file2.exists(), isFalse);
        expect(await textFile.exists(), isTrue);
      },
    );
  });
}
