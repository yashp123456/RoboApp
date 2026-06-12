import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/components_data.dart';
import '../data/shop_data.dart';
import '../models/component.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_badge.dart';
import '../widgets/robot_view.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    // A preview robot showing the player's currently equipped cosmetics.
    final previewEquipped = <SlotType, RobotComponent?>{
      SlotType.chassis: componentById('chassis_basic'),
      SlotType.wheel: componentById('wheels_standard'),
      SlotType.sensor: null,
      SlotType.tool: null,
    };

    final patterns = kShopItems.where((i) => i.kind == 'pattern').toList();
    final accessories = kShopItems.where((i) => i.kind == 'accessory').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Robot Shop'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: CoinBadge()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: RobotView(
              equipped: previewEquipped,
              patternId: game.equippedPattern,
              accessoryId: game.equippedAccessory,
              size: 160,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Spend coins to customize your robot!',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Patterns'),
          ...patterns.map((item) => _shopTile(context, game, item, isPattern: true)),
          const SizedBox(height: 12),
          _sectionTitle('Accessories'),
          ...accessories
              .map((item) => _shopTile(context, game, item, isPattern: false)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary)),
      );

  Widget _shopTile(BuildContext context, GameState game, ShopItem item,
      {required bool isPattern}) {
    final owned = game.ownsCosmetic(item.id);
    final equipped = isPattern
        ? game.equippedPattern == item.id
        : game.equippedAccessory == item.id;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.color.withOpacity(0.2),
          child: Icon(item.icon, color: item.color),
        ),
        title: Text(item.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: owned
            ? Text(equipped ? 'Equipped' : 'Owned — tap to equip')
            : Row(
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppTheme.coin, size: 18),
                  const SizedBox(width: 4),
                  Text('${item.price}'),
                ],
              ),
        trailing: _trailing(context, game, item, owned, equipped, isPattern),
      ),
    );
  }

  Widget _trailing(BuildContext context, GameState game, ShopItem item,
      bool owned, bool equipped, bool isPattern) {
    if (!owned) {
      final canAfford = game.coins >= item.price;
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: canAfford ? AppTheme.accent : Colors.grey),
        onPressed: canAfford
            ? () {
                final ok = game.buyCosmetic(item.id, item.price);
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bought ${item.name}!')),
                  );
                }
              }
            : null,
        child: const Text('Buy'),
      );
    }
    if (equipped) {
      return OutlinedButton(
        onPressed: () => isPattern
            ? game.equipPattern(null)
            : game.equipAccessory(null),
        child: const Text('Remove'),
      );
    }
    return OutlinedButton(
      onPressed: () => isPattern
          ? game.equipPattern(item.id)
          : game.equipAccessory(item.id),
      child: const Text('Equip'),
    );
  }
}
