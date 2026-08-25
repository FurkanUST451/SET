import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSigngit statusIn(scopes: ['email']);

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    return UserModel(
      id: user.uid,
      name: user.displayName ?? email.split('@').first,
      email: user.email!,
      role: UserRole.client,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    return UserModel(
      id: user.uid,
      name: name,
      email: user.email!,
      role: UserRole.client,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  // Kullanıcı Google hesap seçim ekranını iptal ederse null döner.
  Future<UserModel?> loginWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    return UserModel(
      id: user.uid,
      name: user.displayName ?? user.email?.split('@').first ?? 'Kullanıcı',
      email: user.email!,
      role: UserRole.client,
      avatarUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? get currentFirebaseUser => _auth.currentUser;
}
