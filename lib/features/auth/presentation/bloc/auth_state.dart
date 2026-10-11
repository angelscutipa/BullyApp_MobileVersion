import '../../data/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final String token;
  final UserModel user;

  const AuthAuthenticated({
    required this.token,
    required this.user,
  });
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}