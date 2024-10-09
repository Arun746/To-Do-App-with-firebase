// ignore_for_file: unnecessary_null_comparison

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LoginBloc() : super(LoginInitial()) {
    on<LoggedIn>(_onLoggedIn);
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<LoginState> emit) async {
    emit(LoginLoaded());
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential != null) {
        emit(LoginSuccess(userCredential.user!));
      } else {
        throw Exception('User not found');
      }
    } on FirebaseAuthException catch (e) {
      emit(LoginFailure(e.message ?? 'An error occurred'));
    }
  }
}
