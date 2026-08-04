import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/update_provider.dart';

class AnimatedAppUpdateTile extends ConsumerStatefulWidget {
  const AnimatedAppUpdateTile({super.key});

  @override
  ConsumerState<AnimatedAppUpdateTile> createState() => _AnimatedAppUpdateTileState();
}

class _AnimatedAppUpdateTileState extends ConsumerState<AnimatedAppUpdateTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(appUpdateProvider);
    final isUpdateAvailable = updateState.isUpdateAvailable;
    final latestVersion = updateState.updateInfo?.latestVersion ?? '1.0.0';
    final currentVersion = updateState.currentVersion;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (!isUpdateAvailable) {
      // Normal Tile
      return Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push('/settings/update'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.system_update_rounded, color: colors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Updates',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Current Version $currentVersion • Up to date',
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 20,
                  color: colors.primary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Glowing Update Available Tile
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowOpacity = _glowAnimation.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: glowOpacity),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => context.push('/settings/update'),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.system_update_rounded,
                        color: colors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Update Available',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'NEW',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: colors.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Version $latestVersion • Tap to update',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
