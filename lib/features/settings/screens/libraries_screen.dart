import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/active_library_provider.dart';

class LibrariesScreen extends ConsumerStatefulWidget {
  const LibrariesScreen({super.key});

  @override
  ConsumerState<LibrariesScreen> createState() => _LibrariesScreenState();
}

class _LibrariesScreenState extends ConsumerState<LibrariesScreen>
    with SingleTickerProviderStateMixin {
  bool _isSwitching = false;
  LibraryModel? _targetLibrary;
  late AnimationController _overlayAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _overlayAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleSwitchLibrary(LibraryModel library) async {
    final activeLibrary = ref.read(activeLibraryProvider);
    if (activeLibrary.id == library.id) return;

    setState(() {
      _isSwitching = true;
      _targetLibrary = library;
    });

    _overlayAnimationController.forward();

    // Simulate smooth library switching (800-1200ms)
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    // Update active library in Riverpod local state
    ref.read(activeLibraryProvider.notifier).selectLibrary(library);

    await _overlayAnimationController.reverse();

    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _openCreateLibraryBottomSheet() {
    final nameController = TextEditingController();
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: colors.outlineVariant),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Create Library',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add a new library to manage your spaces and students.',
                style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Library Name',
                  hintText: 'e.g. Bright Minds Library',
                  prefixIcon: const Icon(Icons.apartment_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Library Logo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Upload image placeholder',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Upload'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isNotEmpty) {
                          ref
                              .read(activeLibraryProvider.notifier)
                              .addLibrary(name);
                        }
                        Navigator.pop(sheetContext);
                      },
                      child: const Text(
                        'Create Library',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeLibrary = ref.watch(activeLibraryProvider);
    final libraries = ref.watch(activeLibraryProvider.notifier).libraries;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'Libraries',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            centerTitle: false,
          ),
          body: IgnorePointer(
            ignoring: _isSwitching,
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      children: [
                        Text(
                          'Libraries',
                          style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage all your libraries from one place.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 24),

                        if (libraries.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 48,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.business_rounded,
                                    size: 40,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No Libraries Found',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: colors.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Create your first library to get started.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 24),
                                FilledButton.icon(
                                  onPressed: _openCreateLibraryBottomSheet,
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Create Library'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          for (final lib in libraries) ...[
                            Builder(
                              builder: (context) {
                                final isActive = lib.id == activeLibrary.id;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _handleSwitchLibrary(lib),
                                      borderRadius: BorderRadius.circular(22),
                                      child: Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: colors.surface,
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(
                                            color: isActive
                                                ? colors.primary
                                                : colors.outlineVariant,
                                            width: isActive ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            if (isActive)
                                              BoxShadow(
                                                color: colors.primary.withValues(alpha: 0.15),
                                                blurRadius: 16,
                                                offset: const Offset(0, 4),
                                              )
                                            else
                                              BoxShadow(
                                                color: colors.shadow.withValues(alpha: 0.04),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? colors.primaryContainer
                                                    : colors.secondaryContainer,
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Icon(
                                                lib.icon,
                                                size: 24,
                                                color: isActive
                                                    ? colors.onPrimaryContainer
                                                    : colors.onSecondaryContainer,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    lib.name,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w800,
                                                      color: colors.onSurface,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: colors.surfaceContainerHighest,
                                                          borderRadius:
                                                              BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          lib.ownerName,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w700,
                                                            color: colors.onSurfaceVariant,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      if (isActive)
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 3,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF3AB080)
                                                                .withValues(alpha: 0.15),
                                                            borderRadius:
                                                                BorderRadius.circular(8),
                                                            border: Border.all(
                                                              color: const Color(0xFF3AB080)
                                                                  .withValues(alpha: 0.4),
                                                            ),
                                                          ),
                                                          child: const Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(
                                                                Icons.check_rounded,
                                                                size: 13,
                                                                color: Color(0xFF3AB080),
                                                              ),
                                                              SizedBox(width: 3),
                                                              Text(
                                                                'Active',
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight.w900,
                                                                  color: Color(0xFF3AB080),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _openCreateLibraryBottomSheet,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text(
                          'Add New Library',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Premium Instagram-style Switch Loading Overlay (Fade + Scale)
        if (_isSwitching)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
              alignment: Alignment.center,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Switching Library...',
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                            ),
                      ),
                      if (_targetLibrary != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _targetLibrary!.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
