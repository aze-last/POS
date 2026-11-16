import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../config/update_config.dart';
import '../../domain/models/app_version.dart';

/// Information about an available GitHub release update.
class ReleaseInfo {
  final AppVersion version;
  final String rawTag;
  final String releaseNotes;
  final String apkDownloadUrl;
  final String apkFileName;
  final String sha256DownloadUrl;

  const ReleaseInfo({
    required this.version,
    required this.rawTag,
    required this.releaseNotes,
    required this.apkDownloadUrl,
    required this.apkFileName,
    required this.sha256DownloadUrl,
  });
}

/// Service managing update checks, secure downloads, checksum verification, and cleanup.
class UpdateService {
  final http.Client _client;
  final Future<Directory> Function()? cacheDirProvider;
  final Future<String> Function()? currentVersionProvider;

  UpdateService({
    http.Client? client,
    this.cacheDirProvider,
    this.currentVersionProvider,
  }) : _client = client ?? http.Client();

  /// Allowed download hosts for release artifacts.
  static const List<String> allowedHosts = [
    'github.com',
    'api.github.com',
    'objects.githubusercontent.com',
    'github-releases.githubusercontent.com',
    'raw.githubusercontent.com',
  ];

  /// Validates that a URI is HTTPS and belongs to an allowed GitHub host.
  static bool isHostAllowed(Uri uri) {
    if (uri.scheme.toLowerCase() != 'https') return false;
    final host = uri.host.toLowerCase();
    for (final allowed in allowedHosts) {
      if (host == allowed || host.endsWith('.$allowed')) {
        return true;
      }
    }
    return false;
  }

  /// Gets the currently installed app version.
  Future<AppVersion> getCurrentAppVersion() async {
    final versionFn = currentVersionProvider;
    if (versionFn != null) {
      final raw = await versionFn();
      return AppVersion.tryParse(raw) ??
          const AppVersion(major: 1, minor: 0, patch: 0);
    }
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final parsed = AppVersion.tryParse(packageInfo.version);
      if (parsed != null) {
        final buildNum = int.tryParse(packageInfo.buildNumber);
        return AppVersion(
          major: parsed.major,
          minor: parsed.minor,
          patch: parsed.patch,
          build: buildNum,
        );
      }
    } catch (_) {}
    return const AppVersion(major: 1, minor: 0, patch: 0);
  }

  /// Retrieves the directory used to cache update downloads.
  Future<Directory> getCacheDirectory() async {
    final dirFn = cacheDirProvider;
    if (dirFn != null) {
      return dirFn();
    }
    return getTemporaryDirectory();
  }

  /// Checks for an update against GitHub Releases API.
  ///
  /// [isManual]: When true, ignores the 24-hour throttle and re-checks immediately.
  Future<ReleaseInfo?> checkForUpdate({bool isManual = false}) async {
    final cacheDir = await getCacheDirectory();
    final metaFile = File('${cacheDir.path}/update_check_meta.json');

    // 1. Throttle auto-checks to once every 24 hours
    if (!isManual) {
      try {
        if (await metaFile.exists()) {
          final content = await metaFile.readAsString();
          final data = jsonDecode(content);
          if (data is Map && data['last_check'] != null) {
            final lastCheck = DateTime.parse(data['last_check'] as String);
            if (DateTime.now().difference(lastCheck).inHours < 24) {
              return null; // Throttled
            }
          }
        }
      } catch (_) {}
    }

    // 2. Fetch latest release from GitHub (unauthenticated, public HTTPS)
    final response = await _client.get(
      UpdateConfig.latestReleaseUri,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'Banana-POS',
      },
    );

    // Record check timestamp
    try {
      await metaFile.writeAsString(
        jsonEncode({'last_check': DateTime.now().toIso8601String()}),
      );
    } catch (_) {}

    if (response.statusCode != 200) {
      if (isManual) {
        if (response.statusCode == 404) {
          throw const HttpException(
            'No releases published on GitHub repository yet.',
          );
        } else if (response.statusCode == 403) {
          throw const HttpException(
            'GitHub API rate limit exceeded. Please try again later.',
          );
        } else {
          throw HttpException(
            'GitHub API returned error ${response.statusCode}',
          );
        }
      }
      return null;
    }

    final dynamic releaseData;
    try {
      releaseData = jsonDecode(response.body);
    } catch (e) {
      if (isManual) throw const FormatException('Invalid JSON from GitHub API');
      return null;
    }

    if (releaseData is! Map) return null;

    // Ignore drafts and prereleases
    if (releaseData['draft'] == true || releaseData['prerelease'] == true) {
      return null;
    }

    final rawTag = releaseData['tag_name'] as String?;
    final tagVersion = AppVersion.tryParse(rawTag);
    if (tagVersion == null) return null; // Malformed tag

    final currentVersion = await getCurrentAppVersion();
    if (tagVersion <= currentVersion) {
      return null; // Not newer; never downgrade
    }

    // Check if user chose to skip this specific version (auto-check only)
    if (!isManual) {
      final skippedTag = await getSkippedVersion();
      if (skippedTag != null && skippedTag == rawTag) {
        return null;
      }
    }

    // Locate .apk and .apk.sha256 assets
    final assets = releaseData['assets'] as List?;
    if (assets == null) return null;

    Map? apkAsset;
    Map? sha256Asset;

    for (final a in assets) {
      if (a is Map) {
        final name = (a['name'] as String?)?.toLowerCase() ?? '';
        if (name.endsWith('.apk.sha256') || name.endsWith('.sha256')) {
          sha256Asset = a;
        } else if (name.endsWith('.apk')) {
          apkAsset = a;
        }
      }
    }

    // Both .apk and .apk.sha256 are strictly required for security
    if (apkAsset == null || sha256Asset == null) {
      return null;
    }

    final apkUrl = apkAsset['browser_download_url'] as String?;
    final sha256Url = sha256Asset['browser_download_url'] as String?;
    final apkName = apkAsset['name'] as String? ?? 'banana-pos.apk';

    if (apkUrl == null || sha256Url == null) return null;

    // Verify host allowlist
    if (!isHostAllowed(Uri.parse(apkUrl)) ||
        !isHostAllowed(Uri.parse(sha256Url))) {
      throw const SecurityException(
        'Download URL rejected: not in GitHub allowlist',
      );
    }

    return ReleaseInfo(
      version: tagVersion,
      rawTag: rawTag!,
      releaseNotes:
          releaseData['body'] as String? ?? 'No release notes provided.',
      apkDownloadUrl: apkUrl,
      apkFileName: apkName,
      sha256DownloadUrl: sha256Url,
    );
  }

  /// Downloads the release APK and its checksum, verifies integrity, and returns the verified file.
  Future<File> downloadAndVerifyUpdate({
    required ReleaseInfo release,
    void Function(int received, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final apkUri = Uri.parse(release.apkDownloadUrl);
    final sha256Uri = Uri.parse(release.sha256DownloadUrl);

    if (!isHostAllowed(apkUri) || !isHostAllowed(sha256Uri)) {
      throw const SecurityException('Download aborted: non-allowlisted host');
    }

    // 1. Fetch expected SHA-256 hash
    final shaResponse = await _client.get(sha256Uri);
    if (shaResponse.statusCode != 200) {
      throw HttpException(
        'Failed to download SHA-256 checksum (HTTP ${shaResponse.statusCode})',
      );
    }

    final shaContent = shaResponse.body.trim();
    final hexMatch = RegExp(r'[a-fA-F0-9]{64}').firstMatch(shaContent);
    if (hexMatch == null) {
      throw const FormatException(
        'Invalid or missing SHA-256 hash in checksum file',
      );
    }
    final expectedHash = hexMatch.group(0)!.toLowerCase();

    // 2. Download APK to cache directory
    final cacheDir = await getCacheDirectory();
    final targetFile = File('${cacheDir.path}/${release.apkFileName}');
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    final request = http.Request('GET', apkUri);
    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode != 200) {
      throw HttpException(
        'Failed to download APK (HTTP ${streamedResponse.statusCode})',
      );
    }

    final totalBytes = streamedResponse.contentLength ?? -1;
    int receivedBytes = 0;

    final sink = targetFile.openWrite();
    try {
      await for (final chunk in streamedResponse.stream) {
        if (isCancelled != null && isCancelled()) {
          await sink.close();
          if (await targetFile.exists()) await targetFile.delete();
          throw Exception('Download cancelled by user');
        }
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (onProgress != null && totalBytes > 0) {
          onProgress(receivedBytes, totalBytes);
        }
      }
    } finally {
      await sink.close();
    }

    // 3. Verify SHA-256 of downloaded APK
    final actualHash = (await sha256.bind(targetFile.openRead()).first)
        .toString()
        .toLowerCase();

    if (actualHash != expectedHash) {
      // Security breach or corruption: delete immediately
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      throw SecurityException(
        'Integrity verification failed! Expected SHA-256: $expectedHash, got: $actualHash. File has been deleted.',
      );
    }

    return targetFile;
  }

  /// Persists a version tag that the user chose to skip.
  Future<void> skipVersion(String tag) async {
    final cacheDir = await getCacheDirectory();
    final file = File('${cacheDir.path}/update_prefs.json');
    await file.writeAsString(jsonEncode({'skipped_tag': tag}));
  }

  /// Gets the currently skipped version tag, if any.
  Future<String?> getSkippedVersion() async {
    try {
      final cacheDir = await getCacheDirectory();
      final file = File('${cacheDir.path}/update_prefs.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        if (data is Map) return data['skipped_tag'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Cleans up any lingering update APKs in cache.
  Future<void> cleanOldUpdateFiles() async {
    try {
      final cacheDir = await getCacheDirectory();
      if (!await cacheDir.exists()) return;
      final entities = cacheDir.listSync();
      for (final entity in entities) {
        if (entity is File && entity.path.toLowerCase().endsWith('.apk')) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }
}

/// Thrown when security constraints (host allowlist or cryptographic checksums) are violated.
class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
