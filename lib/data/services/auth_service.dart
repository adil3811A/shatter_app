import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'local_storage_service.dart';
import '../models/user_session.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorageService = LocalStorageService();

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get the current authenticated user.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Generate a pseudo-random Base64 key pair for E2E mockup.
  Map<String, String> _generateKeyPair(String seed) {
    final random = Random(seed.hashCode);
    final pubBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final privBytes = List<int>.generate(32, (_) => random.nextInt(256));
    
    return {
      'publicKey': 'pub_E2E_${base64Url.encode(pubBytes)}',
      'privateKey': 'priv_E2E_${base64Url.encode(privBytes)}',
    };
  }

  /// Check if a username is available (i.e., not registered by another user).
  Future<bool> isUsernameAvailable(String username) async {
    final cleanUsername = username.trim().toLowerCase();
    if (cleanUsername.isEmpty) return false;
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: cleanUsername)
          .limit(1)
          .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking username: $e');
      rethrow;
    }
  }

  /// Register a new user using Firebase Auth, create Firestore entries, and save locally.
  Future<UserSession> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // 0. Check if username is already taken
      final cleanUsername = username.trim().toLowerCase();
      final isAvailable = await isUsernameAvailable(cleanUsername);
      if (!isAvailable) {
        throw Exception('The username "$cleanUsername" is already taken.');
      }

      // 1. Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 2. Generate E2E keys
      final keys = _generateKeyPair(username);
      final publicKey = keys['publicKey']!;
      final privateKey = keys['privateKey']!;

      // 3. Create document in 'users' collection
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'password_hash': 'PBKDF2_CLIENT_MANAGED', // Firebase Auth handles actual authentication
        'created_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
        'is_active': true,
        'public_key': publicKey,
        'avatar_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'bio': 'Hello from Shatter!',
        'location_shared': false,
        'theme': 'dark',
      });

      // 4. Create document in 'user_profiles' collection
      await _firestore.collection('user_profiles').doc(uid).set({
        'display_name': username.substring(0, 1).toUpperCase() + username.substring(1),
        'avatar_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'bio': 'Hello! I\'m using Shatter.',
        'status': 'online',
        'location': {
          'latitude': 19.076,
          'longitude': 72.877,
        },
        'location_shared': false,
        'theme': 'dark',
        'notification_enabled': true,
        'language': 'en',
        'privacy_setting': 'friends_only',
      });

      // 5. Create and cache UserSession locally
      final session = UserSession(
        uid: uid,
        email: email,
        username: username,
        displayName: username,
        publicKey: publicKey,
        privateKey: privateKey,
      );

      await _localStorageService.saveSession(session);
      return session;
    } catch (e) {
      print('AuthService Registration Error: $e');
      rethrow;
    }
  }

  /// Login a user using username and password. Resolves the email associated
  /// with the username in Firestore and authenticates via Firebase Auth.
  Future<UserSession> login({
    required String username,
    required String password,
  }) async {
    try {
      final cleanUsername = username.trim().toLowerCase();
      
      // 0. Query Firestore to find the user document by username
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: cleanUsername)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No user found with the username "$username".');
      }

      final userDoc = querySnapshot.docs.first;
      final uid = userDoc.id;
      final userData = userDoc.data();
      final email = userData['email'] as String?;

      if (email == null) {
        throw Exception('Invalid user document configuration (missing email).');
      }

      // 1. Sign in with Firebase Auth using resolved email
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Fetch Profile data from Firestore
      final profileDoc = await _firestore.collection('user_profiles').doc(uid).get();
      final profileData = profileDoc.exists ? profileDoc.data()! : {};

      final displayName = profileData['display_name'] as String? ?? cleanUsername;
      final publicKey = userData['public_key'] as String?;

      // Check if we already have the private key cached locally for this user
      var cachedSession = await _localStorageService.getSession();
      String? privateKey;
      if (cachedSession != null && cachedSession.uid == uid) {
        privateKey = cachedSession.privateKey;
      } else {
        // If not found, generate a key deterministically from username for recovery mockup
        privateKey = _generateKeyPair(cleanUsername)['privateKey'];
      }

      // 3. Save session locally
      final session = UserSession(
        uid: uid,
        email: email,
        username: cleanUsername,
        displayName: displayName,
        publicKey: publicKey,
        privateKey: privateKey,
      );

      await _localStorageService.saveSession(session);

      // Update last_login on Firestore
      await _firestore.collection('users').doc(uid).update({
        'last_login': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('user_profiles').doc(uid).update({
        'status': 'online',
      });

      return session;
    } catch (e) {
      print('AuthService Login Error: $e');
      rethrow;
    }
  }

  /// Logout current session, update status, and clear local storage.
  Future<void> logout() async {
    try {
      final uid = currentUser?.uid;
      if (uid != null) {
        // Update user status to offline before signing out
        await _firestore.collection('user_profiles').doc(uid).update({
          'status': 'offline',
        }).catchError((_) {});
      }
      
      // Clear Firestore auth & local cache
      await _firebaseAuth.signOut();
      await _localStorageService.clearSession();
    } catch (e) {
      print('AuthService Logout Error: $e');
      rethrow;
    }
  }
}
