import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/game_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final gameState = GameState();
  runApp(
    ChangeNotifierProvider<GameState>.value(
      value: gameState..load(),
      child: const RoboBuildersApp(),
    ),
  );
}

class RoboBuildersApp extends StatelessWidget {
  const RoboBuildersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoboBuilders',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _Boot(),
    );
  }
}

/// Shows a tiny splash until saved progress has loaded.
class _Boot extends StatelessWidget {
  const _Boot();

  @override
  Widget build(BuildContext context) {
    final loaded = context.watch<GameState>().loaded;
    if (!loaded) {
      return const Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.smart_toy, size: 90, color: Colors.white),
              SizedBox(height: 16),
              Text('RoboBuilders',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }
    return const HomeScreen();
  }
}
