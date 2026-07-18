import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/settings/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    String tr(String text) => translate(text, settings.language);
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            border: Border.all(color: outline),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Appearance & language'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                tr('Language'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                tr('Choose the language used throughout the app.'),
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<AppLanguage>(
                initialValue: settings.language,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.language),
                ),
                items: AppLanguage.values
                    .map(
                      (language) => DropdownMenuItem(
                        value: language,
                        child: Text(language.label),
                      ),
                    )
                    .toList(),
                onChanged: (language) {
                  if (language != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setLanguage(language);
                  }
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  settings.themeMode == ThemeMode.dark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                title: Text(
                  tr('Dark mode'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(tr('Use a darker color theme.')),
                value: settings.themeMode == ThemeMode.dark,
                onChanged: ref.read(appSettingsProvider.notifier).setDarkMode,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _Backup(),
        const SizedBox(height: 12),
        const _About(),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.logout),
          label: Text(context.tr('Log out')),
        ),
      ],
    );
  }
}

class _Backup extends StatelessWidget {
  const _Backup();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7F0),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.download_outlined, color: Color(0xFF23936B)),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Backup & restore',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                'Keep a safe local copy of all your library data.',
                style: TextStyle(fontSize: 10, color: Color(0xFF969BAB)),
              ),
              SizedBox(height: 10),
              Text(
                'Last backup: 15 July 2026, 09:42 AM',
                style: TextStyle(fontSize: 9, color: Color(0xFFA2A6B3)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _About extends StatelessWidget {
  const _About();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        Icon(Icons.info_outline, color: Color(0xFF7056B8)),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About StudyDesk',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'Version 1.0.0 · Built for focused library owners',
                style: TextStyle(fontSize: 9, color: Color(0xFF999EAC)),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Color(0xFF9A9EAC)),
      ],
    ),
  );
}
