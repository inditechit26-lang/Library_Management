class VersionComparator {
  /// Compares semantic versions (e.g., "1.2.0" vs "1.0.0").
  /// Returns > 0 if version1 > version2
  /// Returns < 0 if version1 < version2
  /// Returns 0 if equal
  static int compare(String version1, String version2) {
    final v1Parts = _parseVersion(version1);
    final v2Parts = _parseVersion(version2);

    final maxLength = v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;

    for (int i = 0; i < maxLength; i++) {
      final part1 = i < v1Parts.length ? v1Parts[i] : 0;
      final part2 = i < v2Parts.length ? v2Parts[i] : 0;

      if (part1 > part2) return 1;
      if (part1 < part2) return -1;
    }

    return 0;
  }

  static bool isUpdateAvailable(String currentVersion, String latestVersion) {
    return compare(latestVersion, currentVersion) > 0;
  }

  static List<int> _parseVersion(String version) {
    final cleanVersion = version.split('+').first.trim();
    final parts = cleanVersion.split('.');
    return parts.map((p) => int.tryParse(RegExp(r'\d+').stringMatch(p) ?? '0') ?? 0).toList();
  }
}
