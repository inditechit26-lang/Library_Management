import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/owner_profile_controller.dart';

class OwnerProfileScreen extends ConsumerStatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  ConsumerState<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends ConsumerState<OwnerProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _libraryNameController;
  late TextEditingController _branchController;
  late TextEditingController _addressController;
  late TextEditingController _openingController;
  late TextEditingController _closingController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(ownerProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _libraryNameController = TextEditingController(text: profile.libraryName);
    _branchController = TextEditingController(text: profile.branchName);
    _addressController = TextEditingController(text: profile.address);
    _openingController = TextEditingController(text: profile.openingTime);
    _closingController = TextEditingController(text: profile.closingTime);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _libraryNameController.dispose();
    _branchController.dispose();
    _addressController.dispose();
    _openingController.dispose();
    _closingController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    ref.read(ownerProfileProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          libraryName: _libraryNameController.text.trim(),
          branchName: _branchController.text.trim(),
          address: _addressController.text.trim(),
          openingTime: _openingController.text.trim(),
          closingTime: _closingController.text.trim(),
        );
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile details updated successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(ownerProfileProvider);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Owner & Library Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_outlined),
            tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6E62FF),
                  const Color(0xFF574DEB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF574DEB).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Center(
                        child: Text(
                          'SD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3AB080),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        profile.subscriptionPlan,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Section: Owner Details
          _buildSectionHeader(context, 'Personal Details', Icons.person_outline),
          const SizedBox(height: 12),
          _buildDetailCard(
            context,
            isDark: isDark,
            children: [
              _buildField(
                context,
                label: 'Owner Full Name',
                controller: _nameController,
                icon: Icons.person_rounded,
                isEditing: _isEditing,
              ),
              const Divider(height: 24),
              _buildField(
                context,
                label: 'Email Address',
                controller: _emailController,
                icon: Icons.email_rounded,
                isEditing: _isEditing,
              ),
              const Divider(height: 24),
              _buildField(
                context,
                label: 'Phone Number',
                controller: _phoneController,
                icon: Icons.phone_rounded,
                isEditing: _isEditing,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Section: Library Details
          _buildSectionHeader(context, 'Library Information', Icons.local_library_outlined),
          const SizedBox(height: 12),
          _buildDetailCard(
            context,
            isDark: isDark,
            children: [
              _buildField(
                context,
                label: 'Library Name',
                controller: _libraryNameController,
                icon: Icons.business_rounded,
                isEditing: _isEditing,
              ),
              const Divider(height: 24),
              _buildField(
                context,
                label: 'Branch Name',
                controller: _branchController,
                icon: Icons.location_city_rounded,
                isEditing: _isEditing,
              ),
              const Divider(height: 24),
              _buildField(
                context,
                label: 'Full Address',
                controller: _addressController,
                icon: Icons.map_rounded,
                isEditing: _isEditing,
                maxLines: 2,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Section: Operational Hours & Capacity
          _buildSectionHeader(
              context, 'Operational Hours & Plan', Icons.access_time_rounded),
          const SizedBox(height: 12),
          _buildDetailCard(
            context,
            isDark: isDark,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      context,
                      label: 'Opening Time',
                      controller: _openingController,
                      icon: Icons.wb_sunny_outlined,
                      isEditing: _isEditing,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      context,
                      label: 'Closing Time',
                      controller: _closingController,
                      icon: Icons.nights_stay_outlined,
                      isEditing: _isEditing,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildReadOnlyTile(
                context,
                label: 'Total Seat Capacity',
                value: '${profile.totalSeats} Seats Configured',
                icon: Icons.chair_alt_rounded,
              ),
              const Divider(height: 24),
              _buildReadOnlyTile(
                context,
                label: 'Member Since',
                value: profile.joinDate,
                icon: Icons.calendar_today_rounded,
              ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: _saveProfile,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: const Color(0xFF574DEB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'Save Profile Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF574DEB)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(BuildContext context,
      {required bool isDark, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : const Color(0x081E293B),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditing,
    int maxLines = 1,
  }) {
    final colors = Theme.of(context).colorScheme;

    if (!isEditing) {
      return Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF574DEB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF574DEB)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF3AB080).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF3AB080)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'System Managed',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
