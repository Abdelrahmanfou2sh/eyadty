import 'package:eyadty/features/auth/presentation/cubit/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubit extends Cubit<AuthState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit() : super(AuthInitial());

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
  Future<void> checkAuthState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure('فشل تسجيل الدخول'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
