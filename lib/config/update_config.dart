/// Configuration for GitHub Releases update checking and APK downloading.
///
/// This is the ONLY file that specifies the repository coordinates.
class UpdateConfig {
  static const String githubOwner = 'aze-last';
  static const String githubRepo = 'POS';

  /// Construct the GitHub API latest release endpoint URL.
  static Uri get latestReleaseUri => Uri.parse(
    'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest',
  );
}
