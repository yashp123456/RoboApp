import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

/// Decides what to show based on the Firebase auth state:
/// - waiting   -> splash
/// - signed out -> AuthScreen
/// - signed in  -> load the user's progress, then HomeScreen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Splash(message: 'Starting up...');
        }
        final user = snapshot.data;
        if (user == null) {
          return const AuthScreen();
        }
        // Keyed by uid so switching accounts re-runs the loader.
        return _ProgressLoader(key: ValueKey(user.uid), uid: user.uid);
      },
    );
  }
}

/// Loads the signed-in user's progress from Firestore, then shows the game.
class _ProgressLoader extends StatefulWidget {
  final String uid;
  const _ProgressLoader({super.key, required this.uid});

  @override
  State<_ProgressLoader> createState() => _ProgressLoaderState();
}

class _ProgressLoaderState extends State<_ProgressLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().loadForUser(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loaded = context.watch<GameState>().loaded;
    if (!loaded) return const _Splash(message: 'Loading your robots...');
    return const HomeScreen();
  }
}

class _Splash extends StatelessWidget {
  final String message;
  const _Splash({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.smart_toy, size: 90, color: Colors.white),
            const SizedBox(height: 16),
            const Text('RoboBuilders',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
