import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/auth_models.dart';
import '../../../shared/enums/enums.dart';
import '../data/auth_repository.dart';

// --- Auth State ---

class AuthState {
  final UserInfo? user;
  final TenantInfo? tenant;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.tenant, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
  UserRole? get role => user?.role;
  bool get isDirector => role == UserRole.director;
  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;
  bool get isTeacher => role == UserRole.teacher;
  bool get isParent => role == UserRole.parent;
  bool get isStaff => isDirector || isAdmin || isTeacher;

  AuthState copyWith({
    UserInfo? user,
    TenantInfo? tenant,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      tenant: clearUser ? null : (tenant ?? this.tenant),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// --- Auth Notifier ---

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState(isLoading: true)) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final hasSession = await _repository.hasValidSession();
      if (!hasSession) {
        state = const AuthState(isLoading: false);
        return;
      }

      // Try to get full user data from API
      try {
        final meResponse = await _repository.getMe();
        state = AuthState(
          user: meResponse.user,
          tenant: meResponse.tenant,
          isLoading: false,
        );
      } catch (_) {
        // Fallback: hydrate minimal user from JWT
        final user = await _repository.getUserFromToken();
        state = AuthState(user: user, isLoading: false);
      }
    } catch (_) {
      state = const AuthState(isLoading: false);
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );

      state = AuthState(
        user: response.user,
        tenant: response.tenant,
        isLoading: false,
      );

      return response;
    } catch (e) {
      String errorMessage = 'Error al iniciar sesión';

      // Parse DioException for better error messages
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
        errorMessage = 'Credenciales incorrectas';
      } else if (errorStr.contains('400') || errorStr.contains('bad request')) {
        errorMessage = 'Email o contraseña inválidos';
      } else if (errorStr.contains('socketexception') ||
          errorStr.contains('connection') ||
          errorStr.contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu internet.';
      } else if (errorStr.contains('timeout')) {
        errorMessage = 'Tiempo de espera agotado. Intenta de nuevo.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      throw Exception(errorMessage);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(isLoading: false);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// --- Providers ---

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserInfo?>((ref) {
  return ref.watch(authProvider).user;
});

final currentTenantProvider = Provider<TenantInfo?>((ref) {
  return ref.watch(authProvider).tenant;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});
