import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Try creating the user
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).then((userCredential) async {
        // If successful, update the user profile if displayName is provided
        if (displayName != null && displayName.isNotEmpty) {
          await userCredential.user?.updateDisplayName(displayName);
        }

        // Hash the password for secure storage
        final hashedPassword = _hashPassword(password);

        // Create user document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'hashedPassword': hashedPassword,
        });

        return userCredential;
      });
    } catch (e) {
      // Handle the specific reCAPTCHA error
      if (e is FirebaseAuthException && 
          (e.message?.contains('CONFIGURATION_NOT_FOUND') == true || 
           e.message?.contains('reCAPTCHA') == true)) {
        print('reCAPTCHA error occurred: ${e.message}');
        
        // For development only: Create a custom authentication flow
        // This is NOT secure for production
        
        // Check if email already exists
        try {
          final methods = await _auth.fetchSignInMethodsForEmail(email);
          if (methods.isNotEmpty) {
            throw FirebaseAuthException(
              code: 'email-already-in-use',
              message: 'The email address is already in use by another account.',
            );
          }
        } catch (innerError) {
          if (innerError is FirebaseAuthException && 
              innerError.code == 'email-already-in-use') {
            rethrow;
          }
          // Continue if the error is not about email being already in use
        }
        
        try {
          // Try again with createUserWithEmailAndPassword
          // This might work on some Firebase projects despite the reCAPTCHA error
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          // Update user profile if displayName is provided
          if (displayName != null && displayName.isNotEmpty) {
            await userCredential.user?.updateDisplayName(displayName);
          }
          
          // Hash the password for secure storage
          final hashedPassword = _hashPassword(password);
          
          // Create user document in Firestore
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'email': email,
            'displayName': displayName,
            'createdAt': FieldValue.serverTimestamp(),
            'hashedPassword': hashedPassword,
          });
          
          return userCredential;
        } catch (finalError) {
          print('Failed to create user after handling reCAPTCHA error: $finalError');
          rethrow;
        }
      }
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Handle the specific reCAPTCHA error for sign in as well
      if (e is FirebaseAuthException && 
          (e.message?.contains('CONFIGURATION_NOT_FOUND') == true || 
           e.message?.contains('reCAPTCHA') == true)) {
        print('reCAPTCHA error occurred during sign in: ${e.message}');
        
        // Try again - sometimes this works despite the error
        try {
          return await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (finalError) {
          print('Failed to sign in after handling reCAPTCHA error: $finalError');
          rethrow;
        }
      }
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}