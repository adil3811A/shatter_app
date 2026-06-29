import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  /// Maps a dynamic error/exception to a human-readable, friendly string.
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid username or password. Please try again.';
        case 'email-already-in-use':
          return 'This email address is already registered.';
        case 'weak-password':
          return 'Your password is too weak. It must be at least 6 characters.';
        case 'operation-not-allowed':
          return 'Email/password authentication is currently disabled.';
        case 'too-many-requests':
          return 'Too many failed attempts. Access is temporarily disabled. Please try again later.';
        case 'network-request-failed':
          return 'Connection failed. Please check your internet connection and try again.';
        default:
          return error.message ?? 'An unexpected authentication error occurred.';
      }
    }

    if (error is FirebaseException) {
      return error.message ?? 'A database error occurred. Please try again.';
    }

    final errorStr = error.toString();
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }

    // Check for some common patterns in stringified exception codes
    if (errorStr.contains('invalid-credential') || 
        errorStr.contains('wrong-password') || 
        errorStr.contains('user-not-found')) {
      return 'Invalid username or password. Please try again.';
    }
    if (errorStr.contains('email-already-in-use')) {
      return 'This email address is already registered.';
    }
    if (errorStr.contains('network-request-failed')) {
      return 'Connection failed. Please check your internet connection.';
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
