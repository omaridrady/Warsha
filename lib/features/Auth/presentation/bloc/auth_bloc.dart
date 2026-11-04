import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/features/Auth/presentation/bloc/auth_event.dart';
import 'package:warsha/features/Auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState()) {
    on<SignInUser>((event, emit) async {
      emit(
        state.copyWith(
          isLoading: true,
          errorMessage: () => null,
          isSuccess: false,
        ),
      );
      try {
        final userData = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        if (userData.user != null) {
          if (userData.user!.emailVerified) {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();

            await prefs.setString("uid", userData.user!.uid);

            emit(
              state.copyWith(
                userId: userData.user!.uid,
                isSuccess: true,
                isLoading: false,
              ),
            );
          } else {
            emit(
              state.copyWith(
                errorMessage: () => "Please verify your email first",
                isLoading: false,
              ),
            );
          }
        } else {
          emit(
            state.copyWith(
              errorMessage: () => "User Not Found!",
              isLoading: false,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String error = "An error occurred";

        if (e.code == 'user-not-found') {
          error = "No account found with this email";
        } else if (e.code == 'wrong-password') {
          error = "Incorrect password";
        } else if (e.code == 'invalid-email') {
          error = "Invalid email format";
        } else if (e.code == 'user-disabled') {
          error = "This account has been disabled";
        } else if (e.code == 'too-many-requests') {
          error = "Too many login attempts. Please try again later";
        } else if (e.code == 'network-request-failed') {
          error = "Network error. Please check your internet connection";
        } else {
          error = e.message ?? "Login failed";
        }
        emit(state.copyWith(errorMessage: () => error, isLoading: false));
      }
    });

    on<ResetPassword>((event , emit){

      FirebaseAuth.instance.sendPasswordResetEmail(email: event.email);
    });
  }
}
