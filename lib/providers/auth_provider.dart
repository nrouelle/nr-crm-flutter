import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_logger.dart';

// Provider pour l'instance FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider pour l'état d'authentification
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Provider pour l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider pour vérifier si l'utilisateur est connecté
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Notifier pour les actions d'authentification
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseAuth _auth;

  AuthNotifier(this._auth) : super(const AsyncValue.data(null));

  // Connexion avec email et mot de passe
  Future<void> signInWithEmailPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      AppLogger.info('Tentative de connexion pour: $email');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      AppLogger.info('Connexion réussie pour: $email');
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      AppLogger.error('Erreur lors de la connexion', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Inscription avec email et mot de passe
  Future<void> createUserWithEmailPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      AppLogger.info('Tentative d\'inscription pour: $email');
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      AppLogger.info('Inscription réussie pour: $email');
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      AppLogger.error('Erreur lors de l\'inscription', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final userEmail = _auth.currentUser?.email;
      AppLogger.info('Déconnexion de l\'utilisateur: $userEmail');
      await _auth.signOut();
      AppLogger.info('Déconnexion réussie');
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      AppLogger.error('Erreur lors de la déconnexion', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      AppLogger.info('Envoi d\'un email de réinitialisation à: $email');
      await _auth.sendPasswordResetEmail(email: email);
      AppLogger.info('Email de réinitialisation envoyé à: $email');
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      AppLogger.error('Erreur lors de l\'envoi de l\'email de réinitialisation', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Provider pour le notifier d'authentification
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthNotifier(auth);
});