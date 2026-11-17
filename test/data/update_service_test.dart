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
          Uri.parse(
            'https://github.com/aze-last/POS/releases/download/v1.0.0/app.apk',
          ),
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
          Uri.parse(
            'https://release-assets.githubusercontent.com/github-production-release-asset/123/asset.apk',
          ),
        ),
        isTrue,
      );
      expect(
        UpdateService.isHostAllowed(
          Uri.parse('https://api.github.com/repos/aze-last/POS/releases'),
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
          Uri.parse('https://raw.githubusercontent.com/malicious/file.apk'),
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
      'parses valid release with matching .apk and .sha256 assets',
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

    test('returns null for auto-check and throws for manual check when assets are missing or mismatched', () async {
      final mockJsonMissingSha = jsonEncode({
        'tag_name': 'v1.0.1',
        'draft': false,
        'prerelease': false,
        'body': 'Notes',
        'assets': [
          {
            'name': 'banana-pos-v1.0.1.apk',
            'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.1/banana-pos-v1.0.1.apk',
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

      final autoCheck = await service.checkForUpdate(isManual: false);
      expect(autoCheck, isNull);

      await expectLater(
        service.checkForUpdate(isManual: true),
        throwsA(isA<UpdateCheckException>()),
      );
    });

    test('rejects mismatched sha256 filename for manual checks', () async {
      final mockJsonMismatchedSha = jsonEncode({
        'tag_name': 'v1.0.2',
        'draft': false,
        'prerelease': false,
        'body': 'Notes',
        'assets': [
          {
            'name': 'banana-pos-v1.0.2.apk',
            'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.2/banana-pos-v1.0.2.apk',
          },
          {
            'name': 'other-app.apk.sha256',
            'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.2/other-app.apk.sha256',
          },
        ],
      });

      final client = MockClient((request) async {
        return http.Response(mockJsonMismatchedSha, 200);
      });

      final service = UpdateService(
        client: client,
        cacheDirProvider: () async => tempDir,
        currentVersionProvider: () async => '1.0.0',
      );

      await expectLater(
        service.checkForUpdate(isManual: true),
        throwsA(isA<UpdateCheckException>()),
      );
    });

    test('ignores drafts and prereleases', () async {
      final mockDraftJson = jsonEncode({
        'tag_name': 'v2.0.0',
        'draft': true,
        'prerelease': false,
        'assets': [
          {
            'name': 'app.apk',
            'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v2.0.0/app.apk',
          },
          {
            'name': 'app.apk.sha256',
            'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v2.0.0/app.apk.sha256',
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

    test('never downgrades when candidate release is older or equal including +BUILD numbers', () async {
      final mockJsonOlder = jsonEncode({
        'tag_name': 'v1.0.0+1',
        'draft': false,
        'prerelease': false,
        'assets': [
          {
            'name': 'banana-pos.apk',
            'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.0/banana-pos.apk',
          },
          {
            'name': 'banana-pos.apk.sha256',
            'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.0/banana-pos.apk.sha256',
          },
        ],
      });

      final clientOlder = MockClient(
        (request) async => http.Response(mockJsonOlder, 200),
      );

      final serviceOlder = UpdateService(
        client: clientOlder,
        cacheDirProvider: () async => tempDir,
        currentVersionProvider: () async => '1.0.0+2',
      );

      expect(await serviceOlder.checkForUpdate(isManual: true), isNull);

      // Candidate newer by build number
      final mockJsonNewer = jsonEncode({
        'tag_name': 'v1.0.0+3',
        'draft': false,
        'prerelease': false,
        'assets': [
          {
            'name': 'banana-pos.apk',
            'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.0/banana-pos.apk',
          },
          {
            'name': 'banana-pos.apk.sha256',
            'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.0/banana-pos.apk.sha256',
          },
        ],
      });

      final clientNewer = MockClient(
        (request) async => http.Response(mockJsonNewer, 200),
      );

      final serviceNewer = UpdateService(
        client: clientNewer,
        cacheDirProvider: () async => tempDir,
        currentVersionProvider: () async => '1.0.0+2',
      );

      final update = await serviceNewer.checkForUpdate(isManual: true);
      expect(update, isNotNull);
      expect(
        update!.version,
        const AppVersion(major: 1, minor: 0, patch: 0, build: 3),
      );
    });

    test(
      'checkForUpdate rejects candidate release with off-allowlist asset URLs',
      () async {
        final mockJsonEvil = jsonEncode({
          'tag_name': 'v2.0.0',
          'draft': false,
          'prerelease': false,
          'assets': [
            {
              'name': 'banana-pos.apk',
              'browser_download_url':
                  'https://malicious-site.com/banana-pos.apk',
            },
            {
              'name': 'banana-pos.apk.sha256',
              'browser_download_url':
                  'https://malicious-site.com/banana-pos.apk.sha256',
            },
          ],
        });

        final client = MockClient(
          (request) async => http.Response(mockJsonEvil, 200),
        );

        final service = UpdateService(
          client: client,
          cacheDirProvider: () async => tempDir,
          currentVersionProvider: () async => '1.0.0',
        );

        await expectLater(
          service.checkForUpdate(isManual: true),
          throwsA(isA<SecurityException>()),
        );
      },
    );

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
              'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.1.0/app.apk',
            },
            {
              'name': 'app.apk.sha256',
              'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.1.0/app.apk.sha256',
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

    test('handles 403 rate limit, 404 not found, and offline gracefully without saving throttle timestamp', () async {
      final metaFile = File('${tempDir.path}/update_check_meta.json');

      // 403 test
      final client403 = MockClient(
        (request) async => http.Response('Rate limit', 403),
      );
      final service403 = UpdateService(
        client: client403,
        cacheDirProvider: () async => tempDir,
        currentVersionProvider: () async => '1.0.0',
      );

      expect(await service403.checkForUpdate(isManual: false), isNull);
      expect(
        await metaFile.exists(),
        isFalse,
      ); // Throttle NOT saved on error (p7-8)

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
      expect(await metaFile.exists(), isFalse);

      expect(
        () => service404.checkForUpdate(isManual: true),
        throwsA(isA<HttpException>()),
      );
    });

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
              'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.5/app.apk',
            },
            {
              'name': 'app.apk.sha256',
              'browser_download_url': 'https://github.com/aze-last/POS/releases/download/v1.0.5/app.apk.sha256',
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
            return http.Response('$expectedHash  banana.apk', 200);
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
          apkDownloadUrl: 'https://github.com/aze-last/POS/releases/download/v1.0.1/banana.apk',
          apkFileName: 'banana.apk',
          sha256DownloadUrl: 'https://github.com/aze-last/POS/releases/download/v1.0.1/banana.apk.sha256',
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

    test('downloadAndVerifyUpdate safely follows valid redirects', () async {
      final apkBytes = utf8.encode('DUMMY APK BINARY CONTENT VIA REDIRECT');
      final expectedHash = sha256.convert(apkBytes).toString();

      final client = MockClient((request) async {
        if (request.url.path.endsWith('.sha256')) {
          return http.Response('$expectedHash  banana.apk', 200);
        }
        if (request.url.host == 'github.com') {
          return http.Response(
            '',
            302,
            headers: {
              'location':
                  'https://objects.githubusercontent.com/download/banana.apk',
            },
          );
        }
        if (request.url.host == 'objects.githubusercontent.com') {
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
        apkDownloadUrl: 'https://github.com/aze-last/POS/releases/download/v1.0.1/banana.apk',
        apkFileName: 'banana.apk',
        sha256DownloadUrl: 'https://github.com/aze-last/POS/releases/download/v1.0.1/banana.apk.sha256',
      );

      final downloadedFile = await service.downloadAndVerifyUpdate(
        release: release,
      );
      expect(await downloadedFile.exists(), isTrue);
      expect(
        await downloadedFile.readAsString(),
        equals('DUMMY APK BINARY CONTENT VIA REDIRECT'),
      );
    });

    test(
      'downloadAndVerifyUpdate rejects redirect to non-allowlisted host',
      () async {
        final apkBytes = utf8.encode('MALICIOUS CONTENT');
        final expectedHash = sha256.convert(apkBytes).toString();

        final client = MockClient((request) async {
          if (request.url.path.endsWith('.sha256')) {
            return http.Response('$expectedHash  banana.apk', 200);
          }
          // Redirects to evil site
          return http.Response(
            '',
            302,
            headers: {'location': 'https://evil-site.com/banana.apk'},
          );
        });

        final service = UpdateService(
          client: client,
          cacheDirProvider: () async => tempDir,
        );

        final release = const ReleaseInfo(
          version: AppVersion(major: 1, minor: 0, patch: 1),
          rawTag: 'v1.0.1',
          releaseNotes: 'Fixes',
          apkDownloadUrl: 'https://github.com/aze-last/POS/releases/download/v1.0.1/banana.apk',
          apkFileName: 'banana.apk',
          sha256DownloadUrl: 'https://github.com/aze-last/POS/releases/download/v1.0.1/banana.apk.sha256',
        );

        await expectLater(
          service.downloadAndVerifyUpdate(release: release),
          throwsA(isA<SecurityException>()),
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
          apkDownloadUrl: 'https://github.com/aze-last/POS/releases/download/v1.0.1/banana.apk',
          apkFileName: 'banana.apk',
          sha256DownloadUrl: 'https://github.com/aze-last/POS/releases/download/v1.0.1/banana.apk.sha256',
        );

        await expectLater(
          service.downloadAndVerifyUpdate(release: release),
          throwsA(isA<SecurityException>()),
        );

        // Verify file was purged immediately
        final targetFile = File('${tempDir.path}/updates/banana.apk');
        expect(await targetFile.exists(), isFalse);
      },
    );

    test('cleanOldUpdateFiles purges all .apk files in cache and updates directory', () async {
      final updatesDir = Directory('${tempDir.path}/updates');
      await updatesDir.create();
      final file1 = File('${updatesDir.path}/old1.apk');
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
    });
  });
}
