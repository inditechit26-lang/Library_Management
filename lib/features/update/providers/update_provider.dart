import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/update_info.dart';
import '../repositories/update_repository.dart';
import '../services/version_comparator.dart';
import '../services/download_manager.dart';

final updateRepositoryProvider = Provider<UpdateRepository>((ref) {
  return UpdateRepository();
});

class AppUpdateState {
  final bool isChecking;
  final bool isUpdateAvailable;
  final String currentVersion;
  final UpdateInfo? updateInfo;
  final DownloadState downloadState;

  const AppUpdateState({
    this.isChecking = false,
    this.isUpdateAvailable = false,
    this.currentVersion = '1.0.0',
    this.updateInfo,
    this.downloadState = const DownloadState(),
  });

  AppUpdateState copyWith({
    bool? isChecking,
    bool? isUpdateAvailable,
    String? currentVersion,
    UpdateInfo? updateInfo,
    DownloadState? downloadState,
  }) {
    return AppUpdateState(
      isChecking: isChecking ?? this.isChecking,
      isUpdateAvailable: isUpdateAvailable ?? this.isUpdateAvailable,
      currentVersion: currentVersion ?? this.currentVersion,
      updateInfo: updateInfo ?? this.updateInfo,
      downloadState: downloadState ?? this.downloadState,
    );
  }
}

class AppUpdateNotifier extends Notifier<AppUpdateState> {
  late final DownloadManager _downloadManager;

  @override
  AppUpdateState build() {
    _downloadManager = DownloadManager();
    
    // Listen to download state changes
    _downloadManager.stateStream.listen((dState) {
      state = state.copyWith(downloadState: dState);
    });

    // Check updates silently on initialization
    Future.microtask(() => checkUpdateSilently());

    ref.onDispose(() {
      _downloadManager.dispose();
    });

    return const AppUpdateState();
  }

  Future<void> checkUpdateSilently() async {
    state = state.copyWith(isChecking: true);
    
    String installedVer = '1.0.0';
    try {
      final pkgInfo = await PackageInfo.fromPlatform();
      installedVer = pkgInfo.version;
    } catch (_) {
      installedVer = '1.0.0';
    }

    final repo = ref.read(updateRepositoryProvider);
    final updateInfo = await repo.getAndroidUpdateInfo();

    if (updateInfo == null || !updateInfo.enabled) {
      state = state.copyWith(
        isChecking: false,
        isUpdateAvailable: false,
        currentVersion: installedVer,
        updateInfo: updateInfo,
      );
      return;
    }

    final hasUpdate = VersionComparator.isUpdateAvailable(
      installedVer,
      updateInfo.latestVersion,
    );

    state = state.copyWith(
      isChecking: false,
      isUpdateAvailable: hasUpdate,
      currentVersion: installedVer,
      updateInfo: updateInfo,
    );
  }

  void startDownload() {
    final apkUrl = state.updateInfo?.apkUrl;
    if (apkUrl == null || apkUrl.isEmpty) return;
    _downloadManager.startDownload(apkUrl);
  }

  void cancelDownload() {
    _downloadManager.cancelDownload();
  }

  void resetDownload() {
    _downloadManager.reset();
  }
}

final appUpdateProvider = NotifierProvider<AppUpdateNotifier, AppUpdateState>(
  AppUpdateNotifier.new,
);
