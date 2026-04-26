

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wafi_ecommerce/core/errors/error_handler.dart';
import 'package:wafi_ecommerce/core/errors/result.dart';
import 'package:wafi_ecommerce/core/storage/secure_storage.dart';
import 'package:wafi_ecommerce/core/utils/helpers.dart';
import 'package:wafi_ecommerce/features/tenant/tenant_service.dart';
import 'auth_model.dart';

class AuthService {
  final _auth        = FirebaseAuth.instance;
  final _firestore   = FirebaseFirestore.instance;
  final _storage     = SecureStorage();
  final _googleSignIn = GoogleSignIn();
  final _tenantService = TenantService();

  // ════════════════════════════════════════════════════════
  //  LOGIN
  // ════════════════════════════════════════════════════════
  Future<Result<AuthModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email:    email.trim(),
        password: password.trim(),
      );
      return await _fetchUserData(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return Result.failure(ErrorHandler.handleFirebase(e));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  // ════════════════════════════════════════════════════════
  //  REGISTER
  // ════════════════════════════════════════════════════════
  Future<Result<AuthModel>> register({
    required String storeName,
    required String email,
    required String password,
    required String tenantId,
    String role = 'admin',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email:    email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      // Tenant + user documents bootstrap
      await _tenantService.bootstrapTenant(
        tenantId:   tenantId,
        storeName:  storeName,
        ownerUid:   uid,
        ownerName:  _nameFromEmail(email),
        ownerEmail: email.trim(),
        role:       role,
      );

      await Future.wait([
        _storage.saveUserId(uid),
        _storage.saveTenantId(tenantId),
        _storage.saveUserRole(role),
      ]);

      return Result.success(
        AuthModel(
          status:   AuthStatus.authenticated,
          uid:      uid,
          email:    email.trim(),
          tenantId: tenantId,
          role:     role,
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(ErrorHandler.handleFirebase(e));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  // ════════════════════════════════════════════════════════
  //  GOOGLE LOGIN
  // ════════════════════════════════════════════════════════
  Future<Result<AuthModel>> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Result.failure(ErrorHandler.handle('Google sign in cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid   = userCredential.user!.uid;
      final email = userCredential.user!.email ?? googleUser.email;

      // Existing user → fetch data
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return await _fetchUserData(uid);
      }

      // New user → bootstrap
      final storeName = googleUser.displayName?.trim().isNotEmpty == true
          ? googleUser.displayName!.trim()
          : 'My Store';
      final newTenantId  = '${slugify(storeName)}_$uid';
      final googlePhoto  = googleUser.photoUrl;
      const role         = 'admin';

      await _tenantService.bootstrapTenant(
        tenantId:   newTenantId,
        storeName:  storeName,
        ownerUid:   uid,
        ownerName:  googleUser.displayName?.trim().isNotEmpty == true
            ? googleUser.displayName!.trim()
            : _nameFromEmail(email),
        ownerEmail: email,
        role:       role,
      );

      await _firestore.collection('users').doc(uid).set({
        'email':       email,
        'tenantId':    newTenantId,
        'role':        role,
        'photoUrl':    googlePhoto,
        'coverUrl':    null,
        'isActive':    true,
        'createdAt':   FieldValue.serverTimestamp(),
        'updatedAt':   FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await Future.wait([
        _storage.saveUserId(uid),
        _storage.saveTenantId(newTenantId),
        _storage.saveUserRole(role),
      ]);

      return Result.success(
        AuthModel(
          status:   AuthStatus.authenticated,
          uid:      uid,
          email:    email,
          tenantId: newTenantId,
          role:     role,
          photoUrl: googlePhoto,
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(ErrorHandler.handleFirebase(e));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  // ════════════════════════════════════════════════════════
  //  INITIALIZE (app restart session restore)
  // ════════════════════════════════════════════════════════
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

  // ════════════════════════════════════════════════════════
  //  LOGOUT
  // ════════════════════════════════════════════════════════
  Future<void> logout() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
      _storage.clearAll(),
    ]);
  }

  // ════════════════════════════════════════════════════════
  //  PRIVATE — Fetch User Data
  //  users/{uid}                       → basic info
  //  users/{uid}/tenants/{tenantId}    → permissions, isActive
  // ════════════════════════════════════════════════════════
  Future<Result<AuthModel>> _fetchUserData(String uid) async {
    try {
      // Step 1: users/{uid} থেকে basic info
      final userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        return Result.failure(ErrorHandler.handle('User not found'));
      }

      final data     = userDoc.data()!;
      final tenantId = data['tenantId'] as String? ?? '';
      final role     = data['role']     as String? ?? 'viewer';
      final photoUrl = data['photoUrl'] as String?;
      final coverUrl = data['coverUrl'] as String?;

      // Step 2: users/{uid}/tenants/{tenantId} → permissions + isActive
      Map<String, dynamic> permissions = {};
      bool isActive = true;

      if (tenantId.isNotEmpty) {
        final tenantRoleDoc = await _firestore
            .collection('users')
            .doc(uid)
            .collection('tenants')
            .doc(tenantId)
            .get();

        if (tenantRoleDoc.exists) {
          final td = tenantRoleDoc.data()!;
          isActive    = td['isActive']    as bool?              ?? true;
          permissions = Map<String, dynamic>.from(
            td['permissions'] as Map? ?? {},
          );
        }
      }

      // Step 3: deactivated account → block login
      if (!isActive) {
        await _auth.signOut();
        return Result.failure(
          ErrorHandler.handle('Your account has been deactivated'),
        );
      }

      // Step 4: lastLoginAt update
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // Step 5: SecureStorage এ save
      await Future.wait([
        _storage.saveUserId(uid),
        _storage.saveTenantId(tenantId),
        _storage.saveUserRole(role),
      ]);

      return Result.success(
        AuthModel(
          status:      AuthStatus.authenticated,
          uid:         uid,
          email:       data['email'] as String? ?? '',
          tenantId:    tenantId,
          role:        role,
          photoUrl:    photoUrl,
          coverUrl:    coverUrl,
          permissions: permissions,
        ),
      );
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  // ── Helper ────────────────────────────────────────────────
  String _nameFromEmail(String email) {
    final local = email.split('@').first.replaceAll('.', ' ');
    return capitalizeWords(local);
  }
}