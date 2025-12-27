import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/repositories/auth_repository.dart';

/// Service for handling Firebase authentication
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AuthRepository _repository = AuthRepository();

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyAuthToken);
    return token != null && token.isNotEmpty;
  }

  /// Get Firebase ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  /// Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw Exception('Failed to sign in - user is null');
      }

      // Get Firebase ID token
      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Authenticate with backend
      final result = await _repository.authenticateWithFirebase(idToken);
      
      // Save authentication token
      await _saveAuthToken(result['token'] as String);
      await _saveUserData(result['user'] as Map<String, dynamic>);

      return result;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw Exception(_getFirebaseErrorMessage(e.code));
      }
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<Map<String, dynamic>> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Create user in Firebase
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Update display name (non-blocking)
      user.updateProfile(displayName: name).catchError((e) {
        print('Note: Could not update display name: $e');
      });

      // Get Firebase ID token
      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Authenticate with backend (pass name since Firebase might not have it yet)
      final result = await _repository.authenticateWithFirebase(
        idToken,
        name: name,
      );

      // Save authentication token
      await _saveAuthToken(result['token'] as String);
      await _saveUserData(result['user'] as Map<String, dynamic>);

      return result;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw Exception(_getFirebaseErrorMessage(e.code));
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to sign in - user is null');
      }

      // Get Firebase ID token
      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Authenticate with backend
      final result = await _repository.authenticateWithFirebase(idToken);

      // Save authentication token
      await _saveAuthToken(result['token'] as String);
      await _saveUserData(result['user'] as Map<String, dynamic>);

      return result;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw Exception(_getFirebaseErrorMessage(e.code));
      }
      rethrow;
    }
  }

  /// Send phone verification code
  Future<void> sendPhoneVerificationCode(String phoneNumber) async {
    try {
      // Validate phone number format
      final formattedPhone = phoneNumber.trim();
      if (!formattedPhone.startsWith('+')) {
        throw Exception('Phone number must include country code (e.g., +1234567890)');
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(_getFirebaseErrorMessage(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verification ID
          _verificationId = verificationId;
          // resendToken can be used for resending codes in the future
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw Exception(_getFirebaseErrorMessage(e.code));
      }
      rethrow;
    }
  }

  String? _verificationId;

  /// Verify phone OTP
  Future<Map<String, dynamic>> verifyPhoneOTP(String smsCode) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID not found. Please request a new code.');
      }

      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // Sign in with credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to verify OTP - user is null');
      }

      // Get Firebase ID token
      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Authenticate with backend
      final result = await _repository.authenticateWithFirebase(idToken);

      // Save authentication token
      await _saveAuthToken(result['token'] as String);
      await _saveUserData(result['user'] as Map<String, dynamic>);

      // Clear verification data
      _verificationId = null;

      return result;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw Exception(_getFirebaseErrorMessage(e.code));
      }
      rethrow;
    }
  }

  /// Resend phone verification code
  Future<void> resendPhoneVerificationCode(String phoneNumber) async {
    _verificationId = null;
    await sendPhoneVerificationCode(phoneNumber);
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw Exception(_getFirebaseErrorMessage(e.code));
      }
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      await _clearAuthData();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      }
      await _clearAuthData();
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw Exception(_getFirebaseErrorMessage(e.code));
      }
      rethrow;
    }
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAuthToken);
  }

  /// Save authentication token
  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAuthToken, token);
  }

  /// Save user data
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    if (userData['id'] != null) {
      await prefs.setInt(AppConstants.keyUserId, userData['id'] as int);
    }
    // Save user data as JSON string
    // Note: SharedPreferences doesn't support Map directly
  }

  /// Clear authentication data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserData);
  }

  /// Get Firebase error message
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'session-expired':
        return 'The SMS code has expired. Please request a new one.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      default:
        return 'Authentication failed: $code';
    }
  }
}
