import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_badge.dart';
import 'level_select_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: AppTheme.primary),
                    onPressed: () => _showSettings(context),
                  ),
                  const CoinBadge(),
                ],
              ),
              const Spacer(),
              const Icon(Icons.smart_toy, size: 110, color: AppTheme.primary),
              const SizedBox(height: 8),
              const Text(
                'RoboBuilders',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Build it. Code it. Solve it!',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const Spacer(),
              _bigButton(
                context,
                icon: Icons.play_arrow,
                label: 'Play',
                color: AppTheme.accent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LevelSelectScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _bigButton(
                context,
                icon: Icons.store,
                label: 'Robot Shop',
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopScreen()),
                ),
              ),
              const Spacer(),
              Text(
                'Levels completed: ${game.completedLevels.length}',
                style: const TextStyle(color: Colors.black45),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bigButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 260,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(label),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    final email = AuthService().currentUser?.email ?? 'Signed in';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(email,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
                'RoboBuilders teaches the engineering design cycle: design a '
                'robot, program it with blocks, test it, and improve.\n\n'
                'Your progress is saved to your account in the cloud.\n\n'
                'Resetting will erase all coins, unlocks, and progress.'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) context.read<GameState>().clear();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await context.read<GameState>().resetProgress();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Reset Progress'),
          ),
        ],
      ),
    );
  }
}
