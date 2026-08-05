import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_logo.dart';
import '../providers/active_library_provider.dart';

class LibrariesScreen extends ConsumerStatefulWidget {
  const LibrariesScreen({super.key});

  @override
  ConsumerState<LibrariesScreen> createState() => _LibrariesScreenState();
}

class _LibrariesScreenState extends ConsumerState<LibrariesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _switchController;
  LibraryModel? _targetLibrary;
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _switchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  Future<void> _switchLibrary(LibraryModel library) async {
    if (library.id == ref.read(activeLibraryProvider).id) return;
    setState(() {
      _targetLibrary = library;
      _isSwitching = true;
    });
    _switchController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    await ref.read(activeLibraryProvider.notifier).selectLibrary(library);
    await _switchController.reverse();
    if (!mounted) return;
    setState(() => _isSwitching = false);
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<void> _openCreateLibrary() async {
    final controller = TextEditingController();
    var submitting = false;
    String? error;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _SheetHandle(theme: theme)),
                  const SizedBox(height: 22),
                  const _CreateHeader(),
                  const SizedBox(height: 26),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) {
                      if (error != null) setSheetState(() => error = null);
                    },
                    decoration: InputDecoration(
                      labelText: 'Library Name',
                      hintText: 'e.g. Bright Minds Library',
                      errorText: error,
                      prefixIcon: const Icon(Icons.domain_rounded),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _LogoPlaceholder(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: submitting
                              ? null
                              : () => Navigator.pop(sheetContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: submitting
                              ? null
                              : () async {
                                  final name = controller.text.trim();
                                  if (name.isEmpty) {
                                    setSheetState(
                                      () => error = 'Enter a library name',
                                    );
                                    return;
                                  }
                                  setSheetState(() => submitting = true);
                                  try {
                                    await ref
                                        .read(activeLibraryProvider.notifier)
                                        .addLibrary(name);
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext);
                                    }
                                  } catch (exception) {
                                    setSheetState(() {
                                      submitting = false;
                                      error = exception.toString();
                                    });
                                  }
                                },
                          icon: submitting
                              ? const SizedBox.square(
                                  dimension: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add_rounded),
                          label: const Text('Create Library'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = ref.watch(activeLibraryProvider);
    final librariesState = ref.watch(librariesProvider);
    final libraries = librariesState.value ?? const <LibraryModel>[];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.brightness == Brightness.dark
              ? const Color(0xFF0B1020)
              : const Color(0xFFF5F7FB),
          appBar: AppBar(
            title: const Text('Libraries'),
            centerTitle: false,
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => ref.invalidate(librariesProvider),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                      children: [
                        _PremiumHero(
                          activeLibrary: active,
                          libraryCount: libraries.length,
                        ),
                        const SizedBox(height: 26),
                        _SectionHeader(count: libraries.length),
                        const SizedBox(height: 12),
                        if (librariesState.isLoading)
                          const _LoadingLibraries()
                        else if (librariesState.hasError)
                          _LibrariesError(
                            onRetry: () => ref.invalidate(librariesProvider),
                          )
                        else if (libraries.isEmpty)
                          _EmptyLibraries(onCreate: _openCreateLibrary)
                        else
                          ...libraries.indexed.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _LibraryCard(
                                library: entry.$2,
                                index: entry.$1,
                                isActive: entry.$2.id == active.id,
                                onTap: () => _switchLibrary(entry.$2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                _AddLibraryBar(onPressed: _openCreateLibrary),
              ],
            ),
          ),
        ),
        if (_isSwitching)
          _SwitchOverlay(
            controller: _switchController,
            library: _targetLibrary,
          ),
      ],
    );
  }
}

class _PremiumHero extends StatelessWidget {
  const _PremiumHero({required this.activeLibrary, required this.libraryCount});

  final LibraryModel activeLibrary;
  final int libraryCount;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF111B3D), Color(0xFF263A7A), Color(0xFF5B4FD8)],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF293B80).withValues(alpha: .28),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: Stack(
      children: [
        const Positioned(right: -18, top: -34, child: _HeroGlow()),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _HeroIcon(),
                const Spacer(),
                _CountPill(count: libraryCount),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Libraries',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Manage and switch between your library branches.',
              style: TextStyle(color: Color(0xFFC9D2F5), fontSize: 13),
            ),
            if (activeLibrary.id.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                    color: Color(0xFF67E8B4),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${activeLibrary.name} is active',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        'ALL BRANCHES',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.35,
        ),
      ),
      const Spacer(),
      Text('$count total', style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.library,
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  final LibraryModel library;
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  static const _accents = [
    Color(0xFF6254E7),
    Color(0xFF159A79),
    Color(0xFFD57832),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = isActive ? const Color(0xFF159A79) : _accents[index % 3];
    return Semantics(
      button: true,
      selected: isActive,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isActive
                    ? accent
                    : colors.outlineVariant.withValues(alpha: .55),
                width: isActive ? 1.7 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? accent.withValues(alpha: .13)
                      : Colors.black.withValues(alpha: .035),
                  blurRadius: isActive ? 22 : 12,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                _LibraryMonogram(name: library.name, accent: accent),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        library.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isActive
                            ? 'Currently selected workspace'
                            : 'Tap to open this workspace',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (isActive)
                  const _ActiveBadge()
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: colors.outline,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddLibraryBar extends StatelessWidget {
  const _AddLibraryBar({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        top: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: .4),
        ),
      ),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add_business_rounded),
            label: const Text('Add New Library'),
          ),
        ),
      ),
    ),
  );
}

class _SwitchOverlay extends StatefulWidget {
  const _SwitchOverlay({required this.controller, required this.library});
  final AnimationController controller;
  final LibraryModel? library;

  @override
  State<_SwitchOverlay> createState() => _SwitchOverlayState();
}

class _SwitchOverlayState extends State<_SwitchOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeInOutQuad,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.15),
              radius: 1.1,
              colors: isDark
                  ? [
                      colorScheme.primaryContainer.withOpacity(0.35),
                      colorScheme.surface,
                      colorScheme.surface,
                    ]
                  : [
                      colorScheme.primary.withOpacity(0.08),
                      colorScheme.surface,
                      colorScheme.surface,
                    ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                  CurvedAnimation(
                    parent: widget.controller,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: isDark
                        ? colorScheme.surfaceContainerHighest.withOpacity(0.65)
                        : Colors.white.withOpacity(0.85),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.12)
                          : colorScheme.primary.withOpacity(0.12),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(isDark ? 0.25 : 0.12),
                        blurRadius: 36,
                        spreadRadius: 2,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glow ring behind logo
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final pulse = Tween<double>(begin: 0.95, end: 1.08)
                              .evaluate(_pulseController);
                          final opacity = Tween<double>(begin: 0.3, end: 0.6)
                              .evaluate(_pulseController);
                          return Transform.scale(
                            scale: pulse,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(opacity),
                                    blurRadius: 30,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: const AppLogo(size: 80, borderRadius: 24),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horizontal_circle_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SWITCHING WORKSPACE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.library?.name ?? 'Library Branch',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Loading branch records & seat maps...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Animated loading progress bar
                      SizedBox(
                        width: 140,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            backgroundColor: colorScheme.primary.withOpacity(0.12),
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateHeader extends StatelessWidget {
  const _CreateHeader();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      _GradientIcon(icon: Icons.add_business_rounded, filled: true),
      SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Library',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 3),
            Text('Create an independent workspace for your branch.'),
          ],
        ),
      ),
    ],
  );
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      children: [
        Icon(Icons.image_outlined),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Library Logo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'You can add branding later in settings.',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LoadingLibraries extends StatelessWidget {
  const _LoadingLibraries();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _LibrariesError extends StatelessWidget {
  const _LibrariesError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => _MessageCard(
    icon: Icons.cloud_off_rounded,
    title: 'Could not load libraries',
    subtitle: 'Check your connection and try again.',
    action: TextButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: const Text('Retry'),
    ),
  );
}

class _EmptyLibraries extends StatelessWidget {
  const _EmptyLibraries({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => _MessageCard(
    icon: Icons.domain_add_rounded,
    title: 'No libraries yet',
    subtitle: 'Create your first workspace to get started.',
    action: TextButton(
      onPressed: onCreate,
      child: const Text('Create library'),
    ),
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget action;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        Icon(icon, size: 36),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(subtitle, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        action,
      ],
    ),
  );
}

class _LibraryMonogram extends StatelessWidget {
  const _LibraryMonogram({required this.name, required this.accent});
  final String name;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 52,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: accent.withValues(alpha: .11),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      name.trim().isEmpty ? 'L' : name.trim()[0].toUpperCase(),
      style: TextStyle(
        color: accent,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF159A79).withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      'ACTIVE',
      style: TextStyle(
        color: Color(0xFF128064),
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: .55,
      ),
    ),
  );
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();
  @override
  Widget build(BuildContext context) =>
      const _GradientIcon(icon: Icons.account_balance_rounded);
}

class _GradientIcon extends StatelessWidget {
  const _GradientIcon({required this.icon, this.filled = false});
  final IconData icon;
  final bool filled;
  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: filled
          ? const Color(0xFF5B4FD8)
          : Colors.white.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.white.withValues(alpha: .17)),
    ),
    child: Icon(icon, color: Colors.white),
  );
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
    child: Text(
      '$count ${count == 1 ? 'branch' : 'branches'}',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _HeroGlow extends StatelessWidget {
  const _HeroGlow();
  @override
  Widget build(BuildContext context) => Container(
    width: 140,
    height: 140,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: .06),
    ),
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.theme});
  final ThemeData theme;
  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 4,
    decoration: BoxDecoration(
      color: theme.colorScheme.outlineVariant,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
