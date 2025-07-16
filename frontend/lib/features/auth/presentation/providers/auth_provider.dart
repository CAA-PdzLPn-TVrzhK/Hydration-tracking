import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydration_tracker/core/services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    await _apiService.initialize();
    final isAuthenticated = await _apiService.isAuthenticated();
    if (isAuthenticated) {
      state = state.copyWith(isAuthenticated: true, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.login(
        username: username,
        password: password,
      );

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: User(
          id: response['user']['id'],
          username: response['user']['username'],
          email: response['user']['email'],
        ),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.register(
        username: username,
        email: email,
        password: password,
      );

      // After successful registration, login automatically
      await login(username: username, password: password);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    state = AuthState.initial();
  }

  Future<void> loadProfile() async {
    if (!state.isAuthenticated) return;

    try {
      final profile = await _apiService.getProfile();
      state = state.copyWith(
        user: User(
          id: profile['user_id'],
          username: profile['username'],
          email: '', // Profile endpoint doesn't return email
        ),
      );
    } catch (error) {
      // If profile loading fails, user might be logged out
      if (error.toString().contains('Unauthorized')) {
        await logout();
      }
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.user,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      isAuthenticated: false,
      isLoading: true,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.email,
  });
} 