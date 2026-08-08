import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('English', 'en'),
  hindi('à¤¹à¤¿à¤‚à¤¦à¥€', 'hi'),
  marathi('à¤®à¤°à¤¾à¤ à¥€', 'mr');

  const AppLanguage(this.label, this.code);
  final String label;
  final String code;
}

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.language = AppLanguage.english,
  });

  final ThemeMode themeMode;
  final AppLanguage language;

  AppSettings copyWith({ThemeMode? themeMode, AppLanguage? language}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
      );
}

class AppSettingsController extends Notifier<AppSettings> {
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'app_language';

  @override
  AppSettings build() {
    Future.microtask(_restore);
    return const AppSettings();
  }

  Future<void> _restore() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_languageKey);
    state = AppSettings(
      themeMode: preferences.getBool(_themeKey) == true
          ? ThemeMode.dark
          : ThemeMode.light,
      language: AppLanguage.values.firstWhere(
        (language) => language.code == languageCode,
        orElse: () => AppLanguage.english,
      ),
    );
  }

  Future<void> setDarkMode(bool enabled) async {
    state = state.copyWith(
      themeMode: enabled ? ThemeMode.dark : ThemeMode.light,
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themeKey, enabled);
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, language.code);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

final _translations = <String, Map<AppLanguage, String>>{
  'Dashboard': {AppLanguage.hindi: 'à¤¡à¥ˆà¤¶à¤¬à¥‹à¤°à¥à¤¡', AppLanguage.marathi: 'à¤¡à¥…à¤¶à¤¬à¥‹à¤°à¥à¤¡'},
  'Students': {AppLanguage.hindi: 'à¤›à¤¾à¤¤à¥à¤°', AppLanguage.marathi: 'à¤µà¤¿à¤¦à¥à¤¯à¤¾à¤°à¥à¤¥à¥€'},
  'Seats': {AppLanguage.hindi: 'à¤¸à¥€à¤Ÿà¥‡à¤‚', AppLanguage.marathi: 'à¤†à¤¸à¤¨à¥‡'},
  'Fees': {AppLanguage.hindi: 'à¤¶à¥à¤²à¥à¤•', AppLanguage.marathi: 'à¤¶à¥à¤²à¥à¤•'},
  'Settings': {AppLanguage.hindi: 'à¤¸à¥‡à¤Ÿà¤¿à¤‚à¤—à¥à¤¸', AppLanguage.marathi: 'à¤¸à¥‡à¤Ÿà¤¿à¤‚à¤—à¥à¤œ'},
  'Appearance & language': {
    AppLanguage.hindi: 'à¤°à¥‚à¤ª à¤”à¤° à¤­à¤¾à¤·à¤¾',
    AppLanguage.marathi: 'à¤¸à¥à¤µà¤°à¥‚à¤ª à¤†à¤£à¤¿ à¤­à¤¾à¤·à¤¾',
  },
  'Language': {AppLanguage.hindi: 'à¤­à¤¾à¤·à¤¾', AppLanguage.marathi: 'à¤­à¤¾à¤·à¤¾'},
  'Choose the language used throughout the app.': {
    AppLanguage.hindi: 'à¤ªà¥‚à¤°à¥‡ à¤à¤ª à¤®à¥‡à¤‚ à¤‡à¤¸à¥à¤¤à¥‡à¤®à¤¾à¤² à¤¹à¥‹à¤¨à¥‡ à¤µà¤¾à¤²à¥€ à¤­à¤¾à¤·à¤¾ à¤šà¥à¤¨à¥‡à¤‚à¥¤',
    AppLanguage.marathi: 'à¤¸à¤‚à¤ªà¥‚à¤°à¥à¤£ à¤…à¥…à¤ªà¤®à¤§à¥à¤¯à¥‡ à¤µà¤¾à¤ªà¤°à¤²à¥€ à¤œà¤¾à¤£à¤¾à¤°à¥€ à¤­à¤¾à¤·à¤¾ à¤¨à¤¿à¤µà¤¡à¤¾.',
  },
  'Dark mode': {
    AppLanguage.hindi: 'à¤¡à¤¾à¤°à¥à¤• à¤®à¥‹à¤¡',
    AppLanguage.marathi: 'à¤¡à¤¾à¤°à¥à¤• à¤®à¥‹à¤¡',
  },
  'Use a darker color theme.': {
    AppLanguage.hindi: 'à¤—à¤¹à¤°à¥‡ à¤°à¤‚à¤— à¤•à¥€ à¤¥à¥€à¤® à¤•à¤¾ à¤‰à¤ªà¤¯à¥‹à¤— à¤•à¤°à¥‡à¤‚à¥¤',
    AppLanguage.marathi: 'à¤—à¤¡à¤¦ à¤°à¤‚à¤—à¤¸à¤‚à¤—à¤¤à¥€ à¤µà¤¾à¤ªà¤°à¤¾.',
  },
  'Sign in': {AppLanguage.hindi: 'à¤¸à¤¾à¤‡à¤¨ à¤‡à¤¨', AppLanguage.marathi: 'à¤¸à¤¾à¤‡à¤¨ à¤‡à¤¨'},
  'Email address': {
    AppLanguage.hindi: 'à¤ˆà¤®à¥‡à¤² à¤ªà¤¤à¤¾',
    AppLanguage.marathi: 'à¤ˆà¤®à¥‡à¤² à¤ªà¤¤à¥à¤¤à¤¾',
  },
  'Password': {AppLanguage.hindi: 'à¤ªà¤¾à¤¸à¤µà¤°à¥à¤¡', AppLanguage.marathi: 'à¤ªà¤¾à¤¸à¤µà¤°à¥à¤¡'},
  'Remember me': {
    AppLanguage.hindi: 'à¤®à¥à¤à¥‡ à¤¯à¤¾à¤¦ à¤°à¤–à¥‡à¤‚',
    AppLanguage.marathi: 'à¤®à¤²à¤¾ à¤²à¤•à¥à¤·à¤¾à¤¤ à¤ à¥‡à¤µà¤¾',
  },
  'Forgot password?': {
    AppLanguage.hindi: 'à¤ªà¤¾à¤¸à¤µà¤°à¥à¤¡ à¤­à¥‚à¤² à¤—à¤?',
    AppLanguage.marathi: 'à¤ªà¤¾à¤¸à¤µà¤°à¥à¤¡ à¤µà¤¿à¤¸à¤°à¤²à¤¾à¤¤?',
  },
  'New Admission': {
    AppLanguage.hindi: 'à¤¨à¤¯à¤¾ à¤ªà¥à¤°à¤µà¥‡à¤¶',
    AppLanguage.marathi: 'à¤¨à¤µà¥€à¤¨ à¤ªà¥à¤°à¤µà¥‡à¤¶',
  },
  'Create Admission': {
    AppLanguage.hindi: 'à¤ªà¥à¤°à¤µà¥‡à¤¶ à¤¬à¤¨à¤¾à¤à¤‚',
    AppLanguage.marathi: 'à¤ªà¥à¤°à¤µà¥‡à¤¶ à¤¤à¤¯à¤¾à¤° à¤•à¤°à¤¾',
  },
  'Student name': {
    AppLanguage.hindi: 'à¤›à¤¾à¤¤à¥à¤° à¤•à¤¾ à¤¨à¤¾à¤®',
    AppLanguage.marathi: 'à¤µà¤¿à¤¦à¥à¤¯à¤¾à¤°à¥à¤¥à¥à¤¯à¤¾à¤šà¥‡ à¤¨à¤¾à¤µ',
  },
  'Mobile number': {
    AppLanguage.hindi: 'à¤®à¥‹à¤¬à¤¾à¤‡à¤² à¤¨à¤‚à¤¬à¤°',
    AppLanguage.marathi: 'à¤®à¥‹à¤¬à¤¾à¤ˆà¤² à¤•à¥à¤°à¤®à¤¾à¤‚à¤•',
  },
  'Seat number': {
    AppLanguage.hindi: 'à¤¸à¥€à¤Ÿ à¤¨à¤‚à¤¬à¤°',
    AppLanguage.marathi: 'à¤†à¤¸à¤¨ à¤•à¥à¤°à¤®à¤¾à¤‚à¤•',
  },
  'Monthly fee': {
    AppLanguage.hindi: 'à¤®à¤¾à¤¸à¤¿à¤• à¤¶à¥à¤²à¥à¤•',
    AppLanguage.marathi: 'à¤®à¤¾à¤¸à¤¿à¤• à¤¶à¥à¤²à¥à¤•',
  },
  'Full Time': {
    AppLanguage.hindi: 'à¤ªà¥‚à¤°à¥à¤£à¤•à¤¾à¤²à¤¿à¤•',
    AppLanguage.marathi: 'à¤ªà¥‚à¤°à¥à¤£à¤µà¥‡à¤³',
  },
  'Half Time': {AppLanguage.hindi: 'à¤…à¤°à¥à¤§à¤•à¤¾à¤²à¤¿à¤•', AppLanguage.marathi: 'à¤…à¤°à¥à¤§à¤µà¥‡à¤³'},
  'Search name, mobile or seat number': {
    AppLanguage.hindi: 'à¤¨à¤¾à¤®, à¤®à¥‹à¤¬à¤¾à¤‡à¤² à¤¯à¤¾ à¤¸à¥€à¤Ÿ à¤¨à¤‚à¤¬à¤° à¤–à¥‹à¤œà¥‡à¤‚',
    AppLanguage.marathi: 'à¤¨à¤¾à¤µ, à¤®à¥‹à¤¬à¤¾à¤ˆà¤² à¤•à¤¿à¤‚à¤µà¤¾ à¤†à¤¸à¤¨ à¤•à¥à¤°à¤®à¤¾à¤‚à¤• à¤¶à¥‹à¤§à¤¾',
  },
  'Search seat or student': {
    AppLanguage.hindi: 'à¤¸à¥€à¤Ÿ à¤¯à¤¾ à¤›à¤¾à¤¤à¥à¤° à¤–à¥‹à¤œà¥‡à¤‚',
    AppLanguage.marathi: 'à¤†à¤¸à¤¨ à¤•à¤¿à¤‚à¤µà¤¾ à¤µà¤¿à¤¦à¥à¤¯à¤¾à¤°à¥à¤¥à¥€ à¤¶à¥‹à¤§à¤¾',
  },
  'Search student...': {
    AppLanguage.hindi: 'à¤›à¤¾à¤¤à¥à¤° à¤–à¥‹à¤œà¥‡à¤‚...',
    AppLanguage.marathi: 'à¤µà¤¿à¤¦à¥à¤¯à¤¾à¤°à¥à¤¥à¥€ à¤¶à¥‹à¤§à¤¾...',
  },
  'Student Profile': {
    AppLanguage.hindi: 'à¤›à¤¾à¤¤à¥à¤° à¤ªà¥à¤°à¥‹à¤«à¤¼à¤¾à¤‡à¤²',
    AppLanguage.marathi: 'à¤µà¤¿à¤¦à¥à¤¯à¤¾à¤°à¥à¤¥à¥€ à¤ªà¥à¤°à¥‹à¤«à¤¾à¤‡à¤²',
  },
  'Personal Information': {
    AppLanguage.hindi: 'à¤µà¥à¤¯à¤•à¥à¤¤à¤¿à¤—à¤¤ à¤œà¤¾à¤¨à¤•à¤¾à¤°à¥€',
    AppLanguage.marathi: 'à¤µà¥ˆà¤¯à¤•à¥à¤¤à¤¿à¤• à¤®à¤¾à¤¹à¤¿à¤¤à¥€',
  },
  'Payment Information': {
    AppLanguage.hindi: 'à¤­à¥à¤—à¤¤à¤¾à¤¨ à¤œà¤¾à¤¨à¤•à¤¾à¤°à¥€',
    AppLanguage.marathi: 'à¤¦à¥‡à¤¯à¤• à¤®à¤¾à¤¹à¤¿à¤¤à¥€',
  },
  'Membership': {AppLanguage.hindi: 'à¤¸à¤¦à¤¸à¥à¤¯à¤¤à¤¾', AppLanguage.marathi: 'à¤¸à¤¦à¤¸à¥à¤¯à¤¤à¥à¤µ'},
  'Renew Membership': {
    AppLanguage.hindi: 'à¤¸à¤¦à¤¸à¥à¤¯à¤¤à¤¾ à¤¨à¤µà¥€à¤¨à¥€à¤•à¤°à¤£',
    AppLanguage.marathi: 'à¤¸à¤¦à¤¸à¥à¤¯à¤¤à¥à¤µ à¤¨à¥‚à¤¤à¤¨à¥€à¤•à¤°à¤£',
  },
    AppLanguage.hindi: 'सदस्यता नवीनीकरण',
    AppLanguage.marathi: 'सदस्यत्व नूतनीकरण',
  },
  'Activity': {AppLanguage.hindi: 'गतिविधि', AppLanguage.marathi: 'क्रियाकलाप'},
  'View receipts': {
    AppLanguage.hindi: 'रसीदें देखें',
    AppLanguage.marathi: 'पावत्या पहा',
  },
  'Add document': {
    AppLanguage.hindi: 'दस्तावेज़ जोड़ें',
    AppLanguage.marathi: 'कागदपत्र जोडा',
  },
  'Choose a source': {
    AppLanguage.hindi: 'स्रोत चुनें',
    AppLanguage.marathi: 'स्रोत निवडा',
  },
  'Camera': {AppLanguage.hindi: 'कैमरा', AppLanguage.marathi: 'कॅमेरा'},
  'Gallery': {AppLanguage.hindi: 'गैलरी', AppLanguage.marathi: 'गॅलरी'},
  'PDF or Image': {
    AppLanguage.hindi: 'पीडीएफ़ या छवि',
    AppLanguage.marathi: 'पीडीएफ किंवा चित्र',
  },
  'Preview': {
    AppLanguage.hindi: 'पूर्वावलोकन',
    AppLanguage.marathi: 'पूर्वावलोकन',
  },
  'Replace': {AppLanguage.hindi: 'बदलें', AppLanguage.marathi: 'बदला'},
  'Delete': {AppLanguage.hindi: 'हटाएं', AppLanguage.marathi: 'हटवा'},
  'Print': {AppLanguage.hindi: 'प्रिंट', AppLanguage.marathi: 'प्रिंट'},
  'Share': {AppLanguage.hindi: 'साझा करें', AppLanguage.marathi: 'शेअर करा'},
  'Close': {AppLanguage.hindi: 'बंद करें', AppLanguage.marathi: 'बंद करा'},
  'Paid': {AppLanguage.hindi: 'भुगतान हुआ', AppLanguage.marathi: 'भरले'},
  'Mark paid': {
    AppLanguage.hindi: 'भुगतान किया चिह्नित करें',
    AppLanguage.marathi: 'भरले म्हणून चिन्हांकित करा',
  },
  'Assign Student': {
    AppLanguage.hindi: 'छात्र आवंटित करें',
    AppLanguage.marathi: 'विद्यार्थी नेमा',
  },
  'Save changes': {
    AppLanguage.hindi: 'बदलाव सहेजें',
    AppLanguage.marathi: 'बदल जतन करा',
  },
  'Log out': {AppLanguage.hindi: 'लॉग आउट', AppLanguage.marathi: 'लॉग आउट'},
  'No Students Found': {
    AppLanguage.hindi: 'कोई छात्र नहीं मिला',
    AppLanguage.marathi: 'कोणताही विद्यार्थी सापडला नाही',
  },
  'Try another search or add a new admission.': {
    AppLanguage.marathi: 'à¤®à¤¾à¤à¥à¤¯à¤¾ à¤¶à¤¾à¤–à¤¾',
  },
  'Manage all your branches from one place': {
    AppLanguage.hindi: 'à¤…à¤ªà¤¨à¥€ à¤¸à¤­à¥€ à¤¶à¤¾à¤–à¤¾à¤“à¤‚ à¤•à¥‹ à¤à¤• à¤œà¤—à¤¹ à¤¸à¥‡ à¤ªà¥à¤°à¤¬à¤‚à¤§à¤¿à¤¤ à¤•à¤°à¥‡à¤‚',
    AppLanguage.marathi: 'à¤¸à¤°à¥à¤µ à¤¶à¤¾à¤–à¤¾ à¤à¤•à¤¾à¤š à¤ à¤¿à¤•à¤¾à¤£à¤¾à¤¹à¥‚à¤¨ à¤µà¥à¤¯à¤µà¤¸à¥à¤¥à¤¾à¤ªà¤¿à¤¤ à¤•à¤°à¤¾',
  },
  'Library Configuration': {
    AppLanguage.hindi: 'à¤²à¤¾à¤‡à¤¬à¥à¤°à¥‡à¤°à¥€ à¤•à¥‰à¤¨à¥à¤«à¤¼à¤¿à¤—à¤°à¥‡à¤¶à¤¨',
    AppLanguage.marathi: 'à¤—à¥à¤°à¤‚à¤¥à¤¾à¤²à¤¯ à¤¸à¥‡à¤Ÿà¤¿à¤‚à¤—à¥à¤œ',
  },
  'Configure sections, rooms, seating and documents': {
    AppLanguage.hindi: 'à¤¸à¥‡à¤•à¥à¤¶à¤¨, à¤•à¤®à¤°à¥‡, à¤¸à¥€à¤Ÿà¤¿à¤‚à¤— à¤”à¤° à¤¦à¤¸à¥à¤¤à¤¾à¤µà¥‡à¤œà¤¼ à¤•à¥‰à¤¨à¥à¤«à¤¼à¤¿à¤—à¤° à¤•à¤°à¥‡à¤‚',
    AppLanguage.marathi: 'à¤µà¤¿à¤­à¤¾à¤—, à¤–à¥‹à¤²à¥à¤¯à¤¾, à¤†à¤¸à¤¨à¥‡ à¤†à¤£à¤¿ à¤•à¤¾à¤—à¤¦à¤ªà¤¤à¥à¤°à¥‡ à¤¸à¥‡à¤Ÿ à¤•à¤°à¤¾',
  },
  'Student Data Backup & Import': {
    AppLanguage.hindi: 'à¤›à¤¾à¤¤à¥à¤° à¤¡à¥‡à¤Ÿà¤¾ à¤¬à¥ˆà¤•à¤…à¤ª à¤”à¤° à¤‡à¤‚à¤ªà¥‹à¤°à¥à¤Ÿ',
    AppLanguage.marathi: 'à¤µà¤¿à¤¦à¥à¤¯à¤¾à¤°à¥à¤¥à¥€ à¤¡à¥‡à¤Ÿà¤¾ à¤¬à¥…à¤•à¤…à¤ª à¤†à¤£à¤¿ à¤†à¤¯à¤¾à¤¤',
  },
  'Export backups or bulk import student records': {
    AppLanguage.hindi: 'à¤¬à¥ˆà¤•à¤…à¤ª à¤à¤•à¥à¤¸à¤ªà¥‹à¤°à¥à¤Ÿ à¤•à¤°à¥‡à¤‚ à¤¯à¤¾ à¤›à¤¾à¤¤à¥à¤° à¤°à¤¿à¤•à¥‰à¤°à¥à¤¡ à¤‡à¤‚à¤ªà¥‹à¤°à¥à¤Ÿ à¤•à¤°à¥‡à¤‚',
    AppLanguage.marathi: 'à¤¬à¥…à¤•à¤…à¤ª à¤à¤•à¥à¤¸à¤ªà¥‹à¤°à¥à¤Ÿ à¤•à¤°à¤¾ à¤•à¤¿à¤‚à¤µà¤¾ à¤µà¤¿à¤¦à¥à¤¯à¤¾à¤°à¥à¤¥à¥€ à¤¨à¥‹à¤‚à¤¦à¥€ à¤†à¤¯à¤¾à¤¤ à¤•à¤°à¤¾',
  },
  'About StudyDesk': {
    AppLanguage.hindi: 'StudyDesk à¤•à¥‡ à¤¬à¤¾à¤°à¥‡ à¤®à¥‡à¤‚',
    AppLanguage.marathi: 'StudyDesk à¤¬à¤¦à¥à¤¦à¤²',
  },
  'Privacy Policy': {
    AppLanguage.hindi: 'à¤—à¥‹à¤ªà¤¨à¥€à¤¯à¤¤à¤¾ à¤¨à¥€à¤¤à¤¿',
    AppLanguage.marathi: 'à¤—à¥‹à¤ªà¤¨à¥€à¤¯à¤¤à¤¾ à¤§à¥‹à¤°à¤£',
  },
  'Read data protection and usage policies': {
    AppLanguage.hindi: 'à¤¡à¥‡à¤Ÿà¤¾ à¤¸à¥à¤°à¤•à¥à¤·à¤¾ à¤”à¤° à¤‰à¤ªà¤¯à¥‹à¤— à¤¨à¥€à¤¤à¤¿à¤¯à¤¾à¤ à¤ªà¤¢à¤¼à¥‡à¤‚',
    AppLanguage.marathi: 'à¤¡à¥‡à¤Ÿà¤¾ à¤¸à¥à¤°à¤•à¥à¤·à¤¾ à¤†à¤£à¤¿ à¤µà¤¾à¤ªà¤° à¤§à¥‹à¤°à¤£à¥‡ à¤µà¤¾à¤šà¤¾',
  },
  'Log Out': {AppLanguage.hindi: 'à¤²à¥‰à¤— à¤†à¤‰à¤Ÿ', AppLanguage.marathi: 'à¤²à¥‰à¤— à¤†à¤‰à¤Ÿ'},
  'Cancel': {AppLanguage.hindi: 'à¤°à¤¦à¥à¤¦ à¤•à¤°à¥‡à¤‚', AppLanguage.marathi: 'à¤°à¤¦à¥à¤¦ à¤•à¤°à¤¾'},
  'Are you sure you want to log out of your session?': {
    AppLanguage.hindi: 'à¤•à¥à¤¯à¤¾ à¤†à¤ª à¤…à¤ªà¤¨à¥€ à¤¸à¤¤à¥à¤° à¤¸à¥‡ à¤²à¥‰à¤— à¤†à¤‰à¤Ÿ à¤•à¤°à¤¨à¤¾ à¤šà¤¾à¤¹à¤¤à¥‡ à¤¹à¥ˆà¤‚?',
    AppLanguage.marathi: 'à¤¤à¥à¤®à¥à¤¹à¤¾à¤²à¤¾ à¤¸à¤¤à¥à¤°à¤¾à¤¤à¥‚à¤¨ à¤²à¥‰à¤— à¤†à¤‰à¤Ÿ à¤•à¤°à¤¾à¤¯à¤šà¥‡ à¤†à¤¹à¥‡ à¤•à¤¾?',
  },
  'WhatsApp Support': {
    AppLanguage.hindi: 'WhatsApp à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾',
    AppLanguage.marathi: 'WhatsApp à¤¸à¤¹à¤¾à¤¯à¥à¤¯',
  },
  'Direct chat with support team': {
    AppLanguage.hindi: 'à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾ à¤Ÿà¥€à¤® à¤¸à¥‡ à¤¸à¥€à¤§à¥‡ à¤šà¥ˆà¤Ÿ à¤•à¤°à¥‡à¤‚',
    AppLanguage.marathi: 'à¤¸à¤¹à¤¾à¤¯à¥à¤¯ à¤Ÿà¥€à¤®à¤¶à¥€ à¤¥à¥‡à¤Ÿ à¤šà¥…à¤Ÿ à¤•à¤°à¤¾',
  },
  'Chat on WhatsApp': {
    AppLanguage.hindi: 'WhatsApp à¤ªà¤° à¤šà¥ˆà¤Ÿ à¤•à¤°à¥‡à¤‚',
    AppLanguage.marathi: 'WhatsApp à¤µà¤° à¤šà¥…à¤Ÿ à¤•à¤°à¤¾',
  },
  'Connecting to WhatsApp support...': {
    AppLanguage.hindi: 'WhatsApp à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾ à¤¸à¥‡ à¤œà¥à¤¡à¤¼ à¤°à¤¹à¥‡ à¤¹à¥ˆà¤‚...',
    AppLanguage.marathi: 'WhatsApp à¤¸à¤¹à¤¾à¤¯à¥à¤¯à¤¾à¤¶à¥€ à¤œà¥‹à¤¡à¤¤ à¤†à¤¹à¥‹à¤¤...',
  },
};

final _settingsTranslations = <String, Map<AppLanguage, String>>{
  'My Branches': {
    AppLanguage.hindi: 'मेरी शाखाएँ',
    AppLanguage.marathi: 'माझ्या शाखा',
  },
  'Manage all your branches from one place': {
    AppLanguage.hindi: 'अपनी सभी शाखाओं को एक जगह से प्रबंधित करें',
    AppLanguage.marathi: 'सर्व शाखा एकाच ठिकाणाहून व्यवस्थापित करा',
  },
  'Library Configuration': {
    AppLanguage.hindi: 'लाइब्रेरी कॉन्फ़िगरेशन',
    AppLanguage.marathi: 'ग्रंथालय सेटिंग्ज',
  },
  'Configure sections, rooms, seating and documents': {
    AppLanguage.hindi: 'सेक्शन, कमरे, सीटिंग और दस्तावेज़ कॉन्फ़िगर करें',
    AppLanguage.marathi: 'विभाग, खोल्या, आसने आणि कागदपत्रे सेट करा',
  },
  'Student Data Backup & Import': {
    AppLanguage.hindi: 'छात्र डेटा बैकअप और इंपोर्ट',
    AppLanguage.marathi: 'विद्यार्थी डेटा बॅकअप आणि आयात',
  },
  'Export backups or bulk import student records': {
    AppLanguage.hindi: 'बैकअप एक्सपोर्ट करें या छात्र रिकॉर्ड इंपोर्ट करें',
    AppLanguage.marathi: 'बॅकअप एक्सपोर्ट करा किंवा विद्यार्थी नोंदी आयात करा',
  },
  'About StudyDesk': {
    AppLanguage.hindi: 'StudyDesk के बारे में',
    AppLanguage.marathi: 'StudyDesk बद्दल',
  },
  'Privacy Policy': {
    AppLanguage.hindi: 'गोपनीयता नीति',
    AppLanguage.marathi: 'गोपनीयता धोरण',
  },
  'Read data protection and usage policies': {
    AppLanguage.hindi: 'डेटा सुरक्षा और उपयोग नीतियाँ पढ़ें',
    AppLanguage.marathi: 'डेटा सुरक्षा आणि वापर धोरणे वाचा',
  },
  'Log Out': {AppLanguage.hindi: 'लॉग आउट', AppLanguage.marathi: 'लॉग आउट'},
  'Cancel': {AppLanguage.hindi: 'रद्द करें', AppLanguage.marathi: 'रद्द करा'},
  'Are you sure you want to log out of your session?': {
    AppLanguage.hindi: 'क्या आप अपनी सत्र से लॉग आउट करना चाहते हैं?',
    AppLanguage.marathi: 'तुम्हाला सत्रातून लॉग आउट करायचे आहे का?',
  },
  'WhatsApp Support': {
    AppLanguage.hindi: 'WhatsApp सहायता',
    AppLanguage.marathi: 'WhatsApp सहाय्य',
  },
  'Direct chat with support team': {
    AppLanguage.hindi: 'सहायता टीम से सीधे चैट करें',
    AppLanguage.marathi: 'सहाय्य टीमशी थेट चॅट करा',
  },
  'Chat on WhatsApp': {
    AppLanguage.hindi: 'WhatsApp पर चैट करें',
    AppLanguage.marathi: 'WhatsApp वर चॅट करा',
  },
  'Connecting to WhatsApp support...': {
    AppLanguage.hindi: 'WhatsApp सहायता से जुड़ रहे हैं...',
    AppLanguage.marathi: 'WhatsApp सहाय्याशी जोडत आहोत...',
  },
};

String translate(String text, AppLanguage language) =>
    _translations[text]?[language] ??
    _settingsTranslations[text]?[language] ??
    text;

extension AppTranslations on BuildContext {
  String tr(String text) {
    final code = Localizations.localeOf(this).languageCode;
    final language = AppLanguage.values.firstWhere(
      (item) => item.code == code,
      orElse: () => AppLanguage.english,
    );
    return translate(text, language);
  }
}
