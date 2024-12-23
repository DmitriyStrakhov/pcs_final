import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Вход с помощью email и пароля
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Ошибка входа: ${e.message}');
    }
  }

  // Регистрация с email и паролем
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Ошибка регистрации: ${e.message}');
    }
  }

  // Сброс пароля
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Ошибка сброса пароля: ${e.message}');
    }
  }

  // Выход из аккаунта
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Ошибка выхода из аккаунта: $e');
    }
  }

  // Получение email текущего пользователя
  String? getCurrentUserEmail() {
    final User? user = _firebaseAuth.currentUser;
    return user?.email;
  }

  // Проверка авторизации пользователя
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Получение UID текущего пользователя
  String? getCurrentUserUid() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Получение текущего пользователя
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Подписка на изменения состояния пользователя
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}
