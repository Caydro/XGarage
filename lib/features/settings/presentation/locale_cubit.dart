import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/token_storage.dart';

class LocaleCubit extends Cubit<Locale> {
  final TokenStorage _tokenStorage;

  LocaleCubit(this._tokenStorage) : super(Locale(_tokenStorage.getLocale()));

  bool get isArabic => state.languageCode == 'ar';

  Future<void> toggleLocale() async {
    final next = isArabic ? const Locale('en') : const Locale('ar');
    await _tokenStorage.saveLocale(next.languageCode);
    emit(next);
  }

  Future<void> setLocale(String languageCode) async {
    await _tokenStorage.saveLocale(languageCode);
    emit(Locale(languageCode));
  }
}
