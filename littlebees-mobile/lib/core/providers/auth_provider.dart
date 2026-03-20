import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo de usuario autenticado
class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String tenantId;
  final String? avatarUrl;

  AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.tenantId,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';

  bool get isTeacher => role == 'teacher';
  bool get isDirector => role == 'director';
  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isParent => role == 'parent';
}

// Estado de autenticación
class AuthState {
  final AuthUser? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null && token != null;

  AuthState copyWith({
    AuthUser? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier para manejar el estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void setUser(AuthUser user, String token) {
    state = state.copyWith(user: user, token: token, error: null);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void logout() {
    state = AuthState();
  }
}

// Provider de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Provider para obtener el usuario actual
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});

// Provider para obtener el token
final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).token;
});

// Provider para verificar si está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
