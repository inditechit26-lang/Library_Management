import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('English', 'en'),
  hindi('हिंदी', 'hi'),
  marathi('मराठी', 'mr');

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
  'Dashboard': {AppLanguage.hindi: 'डैशबोर्ड', AppLanguage.marathi: 'डॅशबोर्ड'},
  'Students': {AppLanguage.hindi: 'छात्र', AppLanguage.marathi: 'विद्यार्थी'},
  'Seats': {AppLanguage.hindi: 'सीटें', AppLanguage.marathi: 'आसने'},
  'Fees': {AppLanguage.hindi: 'शुल्क', AppLanguage.marathi: 'शुल्क'},
  'Settings': {AppLanguage.hindi: 'सेटिंग्स', AppLanguage.marathi: 'सेटिंग्ज'},
  'Appearance & language': {
    AppLanguage.hindi: 'रूप और भाषा',
    AppLanguage.marathi: 'स्वरूप आणि भाषा',
  },
  'Language': {AppLanguage.hindi: 'भाषा', AppLanguage.marathi: 'भाषा'},
  'Choose the language used throughout the app.': {
    AppLanguage.hindi: 'पूरे ऐप में इस्तेमाल होने वाली भाषा चुनें।',
    AppLanguage.marathi: 'संपूर्ण अॅपमध्ये वापरली जाणारी भाषा निवडा.',
  },
  'Dark mode': {
    AppLanguage.hindi: 'डार्क मोड',
    AppLanguage.marathi: 'डार्क मोड',
  },
  'Use a darker color theme.': {
    AppLanguage.hindi: 'गहरे रंग की थीम का उपयोग करें।',
    AppLanguage.marathi: 'गडद रंगसंगती वापरा.',
  },
  'Sign in': {AppLanguage.hindi: 'साइन इन', AppLanguage.marathi: 'साइन इन'},
  'Email address': {
    AppLanguage.hindi: 'ईमेल पता',
    AppLanguage.marathi: 'ईमेल पत्ता',
  },
  'Password': {AppLanguage.hindi: 'पासवर्ड', AppLanguage.marathi: 'पासवर्ड'},
  'Remember me': {
    AppLanguage.hindi: 'मुझे याद रखें',
    AppLanguage.marathi: 'मला लक्षात ठेवा',
  },
  'Forgot password?': {
    AppLanguage.hindi: 'पासवर्ड भूल गए?',
    AppLanguage.marathi: 'पासवर्ड विसरलात?',
  },
  'New Admission': {
    AppLanguage.hindi: 'नया प्रवेश',
    AppLanguage.marathi: 'नवीन प्रवेश',
  },
  'Create Admission': {
    AppLanguage.hindi: 'प्रवेश बनाएं',
    AppLanguage.marathi: 'प्रवेश तयार करा',
  },
  'Student name': {
    AppLanguage.hindi: 'छात्र का नाम',
    AppLanguage.marathi: 'विद्यार्थ्याचे नाव',
  },
  'Mobile number': {
    AppLanguage.hindi: 'मोबाइल नंबर',
    AppLanguage.marathi: 'मोबाईल क्रमांक',
  },
  'Seat number': {
    AppLanguage.hindi: 'सीट नंबर',
    AppLanguage.marathi: 'आसन क्रमांक',
  },
  'Monthly fee': {
    AppLanguage.hindi: 'मासिक शुल्क',
    AppLanguage.marathi: 'मासिक शुल्क',
  },
  'Full Time': {
    AppLanguage.hindi: 'पूर्णकालिक',
    AppLanguage.marathi: 'पूर्णवेळ',
  },
  'Half Time': {AppLanguage.hindi: 'अर्धकालिक', AppLanguage.marathi: 'अर्धवेळ'},
  'Search name, mobile or seat number': {
    AppLanguage.hindi: 'नाम, मोबाइल या सीट नंबर खोजें',
    AppLanguage.marathi: 'नाव, मोबाईल किंवा आसन क्रमांक शोधा',
  },
  'Search seat or student': {
    AppLanguage.hindi: 'सीट या छात्र खोजें',
    AppLanguage.marathi: 'आसन किंवा विद्यार्थी शोधा',
  },
  'Search student...': {
    AppLanguage.hindi: 'छात्र खोजें...',
    AppLanguage.marathi: 'विद्यार्थी शोधा...',
  },
  'Student Profile': {
    AppLanguage.hindi: 'छात्र प्रोफ़ाइल',
    AppLanguage.marathi: 'विद्यार्थी प्रोफाइल',
  },
  'Personal Information': {
    AppLanguage.hindi: 'व्यक्तिगत जानकारी',
    AppLanguage.marathi: 'वैयक्तिक माहिती',
  },
  'Payment Information': {
    AppLanguage.hindi: 'भुगतान जानकारी',
    AppLanguage.marathi: 'देयक माहिती',
  },
  'Membership': {AppLanguage.hindi: 'सदस्यता', AppLanguage.marathi: 'सदस्यत्व'},
  'Renew Membership': {
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
    AppLanguage.marathi: 'भरले म्हणून चिन्हित करा',
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
    AppLanguage.hindi: 'दूसरी खोज करें या नया प्रवेश जोड़ें।',
    AppLanguage.marathi: 'दुसरा शोध घ्या किंवा नवीन प्रवेश जोडा.',
  },
};

String translate(String text, AppLanguage language) =>
    _translations[text]?[language] ?? text;

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
