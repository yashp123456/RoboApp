import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth so the UI never touches Firebase types
/// directly and error handling stays in one place.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authState => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);

  Future<void> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Turns Firebase error codes into kid-friendly messages.
  static String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'That email does not look right.';
        case 'user-disabled':
          return 'This account has been turned off.';
        case 'user-not-found':
          return 'No account found with that email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Wrong email or password. Try again.';
        case 'email-already-in-use':
          return 'That email already has an account. Try signing in.';
        case 'weak-password':
          return 'Pick a longer password (at least 6 characters).';
        case 'network-request-failed':
          return 'No internet connection. Check your network.';
        case 'too-many-requests':
          return 'Too many tries. Wait a moment and try again.';
        default:
          return error.message ?? 'Something went wrong. Try again.';
      }
    }
    return 'Something went wrong. Try again.';
  }
}
