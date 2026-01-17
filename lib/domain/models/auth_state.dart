import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

enum UserType { guest, authenticated }

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    required UserType userType,
    String? userId, // null for guest, Supabase UUID for authenticated
    String? email,
    @Default(false) bool hasSeenWelcome,
  }) = _AuthState;

  factory AuthState.fromJson(Map<String, dynamic> json) =>
      _$AuthStateFromJson(json);
}

extension AuthStateX on AuthState {
  bool get isGuest => userType == UserType.guest;
  bool get isAuthenticated => userType == UserType.authenticated;
  bool get hasLimitations => isGuest;
}

// Initial state for first-time users
const kInitialAuthState = AuthState(
  userType: UserType.guest,
  userId: null,
  email: null,
  hasSeenWelcome: false,
);
