import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/auth_local_data_source.dart';
import '../../data/datasources/login_remote_data_source.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // final LoginRemoteDataSource loginRemoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthBloc({
    // required this.loginRemoteDataSource,
    required this.localDataSource,
  }) : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = null;
          // await loginRemoteDataSource.login(
          //   email: event.email,
          //   password: event.password,
          // );

      // Guardamos el token recibido por la API.
      await localDataSource.saveToken(
        response.token,
      );

      emit(
        AuthAuthenticated(
          token: response.token,
          user: response.user,
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          e.toString().replaceFirst(
            'Exception: ',
            '',
          ),
        ),
      );
    }
  }
}