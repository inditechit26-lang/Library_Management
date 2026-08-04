import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/update_provider.dart';
import '../services/download_manager.dart';
import '../services/installer_service.dart';

class UpdateCenterScreen extends ConsumerWidget {
  const UpdateCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(appUpdateProvider);
    final updateInfo = updateState.updateInfo;
    final downloadState = updateState.downloadState;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final latestVersion = updateInfo?.latestVersion ?? '1.0.0';
    final releaseDate = updateInfo?.releaseDate.isNotEmpty == true
        ? updateInfo!.releaseDate
        : 'Recent Release';
    final apkSize = updateInfo?.apkSize.isNotEmpty == true
        ? updateInfo!.apkSize
        : 'Standard';

    return Scaffold(
      appBar: AppBar(title: const Text('Update Center'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Header Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.primaryContainer.withValues(alpha: 0.3)
                  : colors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    color: colors.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Version Available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version $latestVersion is ready for your app.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Overview Details Grid Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version Overview',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        label: 'Current Version',
                        value: updateState.currentVersion,
                        icon: Icons.smartphone_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        label: 'Latest Version',
                        value: latestVersion,
                        icon: Icons.new_releases_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        label: 'Release Date',
                        value: releaseDate,
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        label: 'Package Size',
                        value: apkSize,
                        icon: Icons.straighten_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Download & Progress Section
          _DownloadSection(
            downloadState: downloadState,
            onStartDownload: () =>
                ref.read(appUpdateProvider.notifier).startDownload(),
            onCancelDownload: () =>
                ref.read(appUpdateProvider.notifier).cancelDownload(),
            onResetDownload: () =>
                ref.read(appUpdateProvider.notifier).resetDownload(),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadSection extends StatelessWidget {
  final DownloadState downloadState;
  final VoidCallback onStartDownload;
  final VoidCallback onCancelDownload;
  final VoidCallback onResetDownload;

  const _DownloadSection({
    required this.downloadState,
    required this.onStartDownload,
    required this.onCancelDownload,
    required this.onResetDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (downloadState.status == DownloadStatus.idle) {
      return FilledButton.icon(
        onPressed: onStartDownload,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.download_rounded),
        label: const Text(
          'Update Now',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      );
    }

    if (downloadState.status == DownloadStatus.downloading) {
      final percentage = (downloadState.progress * 100).toStringAsFixed(1);
      final downloadedMb = (downloadState.downloadedBytes / (1024 * 1024))
          .toStringAsFixed(1);
      final totalMb = downloadState.totalBytes > 0
          ? (downloadState.totalBytes / (1024 * 1024)).toStringAsFixed(1)
          : 'Unknown';

      final speedKb = downloadState.speedBytesPerSec / 1024;
      final speedText = speedKb > 1024
          ? '${(speedKb / 1024).toStringAsFixed(1)} MB/s'
          : '${speedKb.toStringAsFixed(0)} KB/s';

      final remainingSecs = downloadState.remainingSeconds.round();
      final remainingText = remainingSecs > 60
          ? '${(remainingSecs / 60).toStringAsFixed(0)} mins remaining'
          : '$remainingSecs secs remaining';

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: downloadState.progress,
                        strokeWidth: 4,
                      ),
                      Text(
                        '${percentage.split('.')[0]}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Downloading Update...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$downloadedMb MB of $totalMb MB • $speedText',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        remainingText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onCancelDownload,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Cancel Download'),
            ),
          ],
        ),
      );
    }

    if (downloadState.status == DownloadStatus.completed) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF3AB080),
              size: 48,
            ),
            const SizedBox(height: 10),
            Text(
              '✓ Update Ready',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'The update APK has been downloaded successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      if (downloadState.filePath != null) {
                        InstallerService.installApk(downloadState.filePath!);
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.system_update_rounded, size: 18),
                    label: const Text('Install Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Error or Cancelled State
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, color: colors.error, size: 22),
              const SizedBox(width: 10),
              Text(
                downloadState.status == DownloadStatus.cancelled
                    ? 'Download Cancelled'
                    : 'Download Failed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.error,
                ),
              ),
            ],
          ),
          if (downloadState.errorMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              downloadState.errorMessage,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton(
                onPressed: onResetDownload,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Reset'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onStartDownload,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry Download'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
