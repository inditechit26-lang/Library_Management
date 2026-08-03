import 'dart:ui';
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
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
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

    // Simulate ultra-smooth library switching transition
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            color: isDark ? const Color(0xFF1E2235) : colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Grab Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Title Section with Luxury Icon Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_business_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Library',
                          style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Add a new library branch to your organization.',
                          style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // Input 1: Library Name
              TextFormField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  labelText: 'Library Name',
                  hintText: 'e.g. Bright Minds Library',
                  prefixIcon: const Icon(Icons.apartment_rounded),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input 2: Library Logo (Placeholder Container)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primaryContainer, colors.secondaryContainer],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: colors.primary,
                        size: 24,
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
                            'Upload logo image (PNG, JPG)',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_rounded, size: 16),
                      label: const Text('Upload'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Buttons Section
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
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
    final isDark = theme.brightness == Brightness.dark;
    final activeLibrary = ref.watch(activeLibraryProvider);
    final libraries = ref.watch(activeLibraryProvider.notifier).libraries;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F121C) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              'Libraries',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: IgnorePointer(
            ignoring: _isSwitching,
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      children: [
                        // Ultra Premium Header Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [const Color(0xFF1E2438), const Color(0xFF161A29)]
                                  : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2E3752)
                                  : const Color(0xFFC7D2FE),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.3)
                                    : const Color(0xFF6366F1).withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.business_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Libraries',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.4,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Manage and switch between your library branches.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section Title & Counter
                        Row(
                          children: [
                            Text(
                              'ALL BRANCHES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${libraries.length} Available',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (libraries.isEmpty)
                          // Empty State Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 54,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: colors.outlineVariant),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colors.primaryContainer.withValues(alpha: 0.6),
                                        colors.primaryContainer.withValues(alpha: 0.2),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.business_rounded,
                                    size: 42,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  'No Libraries Found',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: colors.onSurface,
                                        fontSize: 18,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Create your first library to get started.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                ),
                                const SizedBox(height: 26),
                                FilledButton.icon(
                                  onPressed: _openCreateLibraryBottomSheet,
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Create Library'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 26,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
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
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 240),
                                    curve: Curves.easeInOut,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _handleSwitchLibrary(lib),
                                        borderRadius: BorderRadius.circular(24),
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: colors.surface,
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(
                                              color: isActive
                                                  ? const Color(0xFF3AB080)
                                                  : colors.outlineVariant.withValues(alpha: 0.6),
                                              width: isActive ? 2 : 1,
                                            ),
                                            boxShadow: [
                                              if (isActive)
                                                BoxShadow(
                                                  color: const Color(0xFF3AB080)
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 20,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 6),
                                                )
                                              else
                                                BoxShadow(
                                                  color: colors.shadow.withValues(alpha: 0.04),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              // Logo Avatar
                                              Container(
                                                width: 52,
                                                height: 52,
                                                decoration: BoxDecoration(
                                                  gradient: isActive
                                                      ? const LinearGradient(
                                                          colors: [
                                                            Color(0xFF3AB080),
                                                            Color(0xFF288C68),
                                                          ],
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                        )
                                                      : LinearGradient(
                                                          colors: [
                                                            colors.secondaryContainer,
                                                            colors.surfaceContainerHighest,
                                                          ],
                                                        ),
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: [
                                                    if (isActive)
                                                      BoxShadow(
                                                        color: const Color(0xFF288C68)
                                                            .withValues(alpha: 0.35),
                                                        blurRadius: 10,
                                                        offset: const Offset(0, 4),
                                                      ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  lib.icon,
                                                  size: 26,
                                                  color: isActive
                                                      ? Colors.white
                                                      : colors.onSecondaryContainer,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      lib.name,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w900,
                                                        letterSpacing: -0.2,
                                                        color: colors.onSurface,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 9,
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
                                                              fontSize: 10.5,
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
                                                              horizontal: 9,
                                                              vertical: 3.5,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              gradient: const LinearGradient(
                                                                colors: [
                                                                  Color(0xFFE8F5E9),
                                                                  Color(0xFFC8E6C9),
                                                                ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(8),
                                                              border: Border.all(
                                                                color: const Color(0xFF2E7D32)
                                                                    .withValues(alpha: 0.3),
                                                              ),
                                                            ),
                                                            child: const Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(
                                                                  Icons.check_circle_rounded,
                                                                  size: 13,
                                                                  color: Color(0xFF2E7D32),
                                                                ),
                                                                SizedBox(width: 4),
                                                                Text(
                                                                  'ACTIVE',
                                                                  style: TextStyle(
                                                                    fontSize: 10,
                                                                    fontWeight:
                                                                        FontWeight.w900,
                                                                    color: Color(0xFF2E7D32),
                                                                    letterSpacing: 0.6,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        else
                                                          Text(
                                                            'Tap to switch',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w500,
                                                              color: colors.onSurfaceVariant
                                                                  .withValues(alpha: 0.7),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                isActive
                                                    ? Icons.radio_button_checked_rounded
                                                    : Icons.radio_button_off_rounded,
                                                color: isActive
                                                    ? const Color(0xFF3AB080)
                                                    : colors.outlineVariant,
                                                size: 22,
                                              ),
                                            ],
                                          ),
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

                  // Full-Width Ultra Premium Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.38),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _openCreateLibraryBottomSheet,
                        icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
                        label: const Text(
                          'Add New Library',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
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

        // Ultra Premium Glassmorphic Switch Loading Overlay (Fade + Scale + Backdrop Blur)
        if (_isSwitching)
          FadeTransition(
            opacity: _fadeAnimation,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                color: Colors.black.withValues(alpha: 0.65),
                alignment: Alignment.center,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2235) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'SWITCHING LIBRARY',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: colors.onSurface,
                          ),
                        ),
                        if (_targetLibrary != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _targetLibrary!.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
