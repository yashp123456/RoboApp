import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/levels_data.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_badge.dart';
import 'level_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Level'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: CoinBadge()),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
        ),
        itemCount: kLevels.length,
        itemBuilder: (context, i) {
          final level = kLevels[i];
          final unlocked = game.isLevelUnlocked(level.number);
          final completed = game.isLevelCompleted(level.number);

          return Card(
            color: unlocked ? Colors.white : Colors.grey.shade300,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: unlocked
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LevelScreen(levelNumber: level.number),
                        ),
                      )
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          unlocked ? AppTheme.primary : Colors.grey,
                      child: unlocked
                          ? Text(
                              '${level.number}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(Icons.lock, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      level.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.concept,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    if (completed)
                      const Icon(Icons.star, color: AppTheme.coin, size: 22)
                    else if (unlocked)
                      Text('Earn ${level.coinReward} coins',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black45)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
