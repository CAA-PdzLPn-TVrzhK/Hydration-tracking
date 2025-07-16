import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydration_tracker/core/services/storage_service.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('ru')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final code = StorageService.getLanguage();
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLanguage(Locale locale) async {
    state = locale;
    await StorageService.saveLanguage(locale.languageCode);
  }
} 