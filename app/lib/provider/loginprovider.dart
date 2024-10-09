import 'package:app/screens/home.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// LoginState holds the username and password values
class LoginState {
  final String username;
  final String password;

  LoginState({
    this.username = '',
    this.password = '',
  });

  LoginState copyWith({String? username, String? password}) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}

// LoginNotifier manages the login state and logic
class LoginNotifier extends StateNotifier<LoginState> {
  final FirebaseAuth firebaseAuth;
  LoginNotifier(this.firebaseAuth) : super(LoginState());

  void setUsername(String username) {
    state = state.copyWith(username: username);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  Future<void> login(WidgetRef ref, BuildContext context) async {
    if (state.username.isEmpty || state.password.isEmpty) {
      // Handle validation error
      SnackBarMsg.showSuccess(context, "Email and Password are required", 2);
      return;
    }

    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: state.username.trim(),
        password: state.password.trim(),
      );
      SnackBarMsg.showSuccess(context, "Logged In Successfully", 2);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Home()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        SnackBarMsg.showSuccess(context, "User not valid", 2);
      } else if (e.code == 'wrong-password') {
        SnackBarMsg.showSuccess(context, "Invalid Password", 2);
      } else {
        SnackBarMsg.showSuccess(context, "${e.message}", 2);
      }
    }
  }
}

// Create a provider for the LoginNotifier
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(FirebaseAuth.instance);
});
