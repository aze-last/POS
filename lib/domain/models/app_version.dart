/// Represents a semantic version (Major.Minor.Patch) with optional build number.
///
/// Implements strict semantic version comparison (e.g. 1.0.10 > 1.0.9).
class AppVersion implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;
  final int? build;

  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.build,
  });

  /// Parses a version string like "v1.2.3", "1.2.3", or "1.2.3+4".
  /// Returns null if the string is not a valid semantic version.
  static AppVersion? tryParse(String? raw) {
    if (raw == null) return null;
    var trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('v') || trimmed.startsWith('V')) {
      trimmed = trimmed.substring(1);
    }

    // Split build number if present
    int? buildNumber;
    if (trimmed.contains('+')) {
      final parts = trimmed.split('+');
      trimmed = parts[0];
      if (parts.length > 1) {
        buildNumber = int.tryParse(parts[1]);
      }
    }

    final segments = trimmed.split('.');
    if (segments.length != 3) return null;

    final major = int.tryParse(segments[0]);
    final minor = int.tryParse(segments[1]);
    final patch = int.tryParse(segments[2]);

    if (major == null || minor == null || patch == null) return null;
    if (major < 0 || minor < 0 || patch < 0) return null;

    return AppVersion(
      major: major,
      minor: minor,
      patch: patch,
      build: buildNumber,
    );
  }

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    if (build != null && other.build != null && build != other.build) {
      return build!.compareTo(other.build!);
    }
    return 0;
  }

  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator >=(AppVersion other) => compareTo(other) >= 0;
  bool operator <(AppVersion other) => compareTo(other) < 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVersion &&
          runtimeType == other.runtimeType &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch &&
          build == other.build;

  @override
  int get hashCode =>
      major.hashCode ^ minor.hashCode ^ patch.hashCode ^ (build?.hashCode ?? 0);

  @override
  String toString() =>
      build != null ? '$major.$minor.$patch+$build' : '$major.$minor.$patch';
}
