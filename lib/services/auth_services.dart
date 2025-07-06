import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import google_sign_in
import 'package:flutter/foundation.dart' show kIsWeb;

final AuthService authService = AuthService();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  /// Metode untuk Google Sign-In yang mendukung Web dan Mobile
  Future<UserCredential> signInWithGoogle() async {
    // Cek apakah aplikasi berjalan di web
    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('profile');
      googleProvider.addScope('email');
      return await _auth.signInWithPopup(googleProvider);
    } else {
      // Untuk platform mobile (Android/iOS)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );

      await googleSignIn.signOut();

      // Lakukan proses sign-in Google native
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // Pengguna membatalkan proses sign-in
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Google Sign-In dibatalkan oleh pengguna.',
        );
      }

      // Dapatkan detail otentikasi dari akun Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Buat kredensial Firebase dari kredensial Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Masuk ke Firebase dengan kredensial Google
      return await _auth.signInWithCredential(credential);
    }
  }
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateProfile({required String name}) async {
    await currentUser!.updateDisplayName(name);
  }

  Future<void> updatePhotoUrl({required String photoUrl}) async {
    await currentUser!.updatePhotoURL(photoUrl);
  }

  Future<void> deleteAccount({
    required String email,
    required String password
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await _auth.signOut();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String password, 
    required String newPassword, 
    required String email
    }) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}
