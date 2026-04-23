import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wafi_ecommerce/core/errors/error_handler.dart';
import 'package:wafi_ecommerce/core/errors/result.dart';
import 'package:wafi_ecommerce/core/storage/secure_storage.dart';
import 'package:wafi_ecommerce/core/utils/text_utils.dart';
import 'auth_model.dart';
import 'package:wafi_ecommerce/services/tenant_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = SecureStorage();
  final _googleSignIn = GoogleSignIn();
  final _tenantService = TenantService();
  // Login
  Future<Result<AuthModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;
      return await _fetchUserData(uid);
    } on FirebaseAuthException catch (e) {
      return Result.failure(ErrorHandler.handleFirebase(e));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  // Register
  Future<Result<AuthModel>> register({
    required String storeName,
    required String email,
    required String password,
    required String tenantId,
    String role = 'admin',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;
      await _tenantService.bootstrapTenant(
        tenantId: tenantId,
        storeName: storeName,
        ownerUid: uid,
        ownerName: _ownerNameFromEmail(email),
        ownerEmail: email.trim(),
        role: role,
      );
      await _storage.saveUserId(uid);
      await _storage.saveTenantId(tenantId);
      await _storage.saveUserRole(role);

      return Result.success(
        AuthModel(
          status: AuthStatus.authenticated,
          uid: uid,
          email: email,
          tenantId: tenantId,
          role: role,
          photoUrl: null,
          coverUrl: null,
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(ErrorHandler.handleFirebase(e));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  // Fetch user data
  Future<Result<AuthModel>> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return Result.failure(ErrorHandler.handle('User not found!'));
      }

      final data = doc.data()!;
      final tenantId = data['tenantId'] as String;
      final role = data['role'] as String;
      final photoUrl = data['photoUrl'] as String?;
      final coverUrl = data['coverUrl'] as String?;

      await _storage.saveUserId(uid);
      await _storage.saveTenantId(tenantId);
      await _storage.saveUserRole(role);

      return Result.success(
        AuthModel(
          status: AuthStatus.authenticated,
          uid: uid,
          email: data['email'],
          tenantId: tenantId,
          role: role,
          photoUrl: photoUrl,
          coverUrl: coverUrl,
        ),
      );
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  // Initialize
  Future<Result<AuthModel>> initializeAuth() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.success(
          const AuthModel(status: AuthStatus.unauthenticated),
        );
      }
      return await _fetchUserData(user.uid);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<AuthModel>> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      // User cancel করলে
      if (googleUser == null) {
        return Result.failure(ErrorHandler.handle('Google sign in cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;
      final email = userCredential.user!.email ?? googleUser.email;

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return await _fetchUserData(uid);
      } else {
        final storeName = googleUser.displayName?.trim().isNotEmpty == true
            ? googleUser.displayName!.trim()
            : 'My Store';
        final tenantId = '${slugify(storeName)}_$uid';
        final googlePhotoUrl = googleUser.photoUrl;
        await _tenantService.bootstrapTenant(
          tenantId: tenantId,
          storeName: storeName,
          ownerUid: uid,
          ownerName: googleUser.displayName?.trim().isNotEmpty == true
              ? googleUser.displayName!.trim()
              : _ownerNameFromEmail(email),
          ownerEmail: email,
          role: 'admin',
        );

        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'tenantId': tenantId,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': googlePhotoUrl,
          'coverUrl': null,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _storage.saveUserId(uid);
        await _storage.saveTenantId(tenantId);
        await _storage.saveUserRole('admin');

        return Result.success(
          AuthModel(
            status: AuthStatus.authenticated,
            uid: uid,
            email: email,
            tenantId: tenantId,
            role: 'admin',
            photoUrl: googlePhotoUrl,
            coverUrl: null,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(ErrorHandler.handleFirebase(e));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _storage.clearAll();
  }

  String _ownerNameFromEmail(String email) {
    final localPart = email.split('@').first.replaceAll('.', ' ');
    return capitalizeWords(localPart);
  }
}
