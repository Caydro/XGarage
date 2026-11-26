import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (isClosed) return;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      if (isClosed) return;
      emit(Unauthenticated());
    }
  }

  Future<void> login({required String login, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(login: login, password: password);
      if (isClosed) return;
      emit(Authenticated(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? make,
    String? model,
    int? year,
    String? colorName,
    String? colorHex,
    String? plateLetters,
    String? plateNumbers,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: name,
        phone: phone,
        password: password,
        email: email,
        make: make,
        model: model,
        year: year,
        colorName: colorName,
        colorHex: colorHex,
        plateLetters: plateLetters,
        plateNumbers: plateNumbers,
      );
      if (isClosed) return;
      emit(Authenticated(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
    } finally {
      if (!isClosed) emit(Unauthenticated());
    }
  }
}
