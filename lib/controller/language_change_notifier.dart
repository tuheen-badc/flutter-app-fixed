import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageChangeController with ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';

    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  // Change language and persist to shared preferences
  Future<void> changeLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    notifyListeners();
  }

  // Toggle between English and Bangla
  Future<void> toggleLanguage() async {
    if (_currentLocale.languageCode == 'en') {
      await changeLanguage('bn');
    } else {
      await changeLanguage('en');
    }
  }

  bool get isEnglish => _currentLocale.languageCode == 'en';

  bool get isBangla => _currentLocale.languageCode == 'bn';
}
