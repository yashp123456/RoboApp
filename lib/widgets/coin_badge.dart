import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../theme/app_theme.dart';

/// A small pill showing the player's current coin balance. Updates live.
class CoinBadge extends StatelessWidget {
  const CoinBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<GameState>().coins;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: AppTheme.coin, size: 22),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
