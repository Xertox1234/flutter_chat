import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isInitialized = false;

  // Sign in with email and password
  Future<(User?, String?)> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (userCredential.user, null);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed login attempts. Please try again later.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during sign in.';
      }
      return (null, errorMessage);
    } catch (e) {
      return (null, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<(User?, String?)> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (userCredential.user, null);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password is too weak. Please use at least 6 characters.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please contact support.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during registration.';
      }
      return (null, errorMessage);
    } catch (e) {
      return (null, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Initialize Google Sign-In (v7 requirement)
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      // Get client ID from environment variable for security
      const clientId = String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID',
          defaultValue: '1015010025725-d04m4i8mmi0ig9hlkl8ps5dknksrr74d.apps.googleusercontent.com');

      await _googleSignIn.initialize(
        clientId: clientId,
      );
      _isInitialized = true;
    }
  }

  // Sign in with Google (v7 with web/mobile platform handling)
  Future<(User?, String?)> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // For web platform, use Firebase Auth popup directly
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // Add required scopes
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        // Set custom parameters for better UX
        googleProvider.setCustomParameters({
          'prompt': 'select_account',
        });

        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        return (userCredential.user, null);
      } else {
        // For mobile platforms, use Google Sign-In v7
        await _ensureInitialized();

        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
        if (googleUser == null) {
          return (null, 'Google sign-in was cancelled.');
        }

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return (userCredential.user, null);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with a different sign-in method.';
          break;
        case 'invalid-credential':
          errorMessage = 'The credential is invalid or has expired.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google sign-in is not enabled. Please contact support.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during Google sign-in.';
      }
      return (null, errorMessage);
    } catch (e) {
      return (null, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }

  // Get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}