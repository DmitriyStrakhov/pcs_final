import 'profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'note.dart';
import 'login_page.dart';
import 'auth_service.dart'; // Add this import for signOut functionality

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.orderHistory});
  final List<Sweet> orderHistory;

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final authService = AuthService();  // Add this to handle sign out

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return ProfilePage(
            onSignOut: () async {
              await authService.signOut();  // Sign out logic
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
