import 'package:flutter/material.dart';

/// A cosmetic the player can buy with coins to decorate their robot.
class ShopItem {
  final String id;
  final String name;
  final int price;
  final Color color;
  final IconData icon;
  final String kind; // 'pattern' or 'accessory'

  const ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.color,
    required this.icon,
    required this.kind,
  });
}

const List<ShopItem> kShopItems = [
  ShopItem(
    id: 'pattern_blue',
    name: 'Ocean Blue',
    price: 10,
    color: Color(0xFF2196F3),
    icon: Icons.palette,
    kind: 'pattern',
  ),
  ShopItem(
    id: 'pattern_red',
    name: 'Lava Red',
    price: 10,
    color: Color(0xFFF44336),
    icon: Icons.palette,
    kind: 'pattern',
  ),
  ShopItem(
    id: 'pattern_green',
    name: 'Slime Green',
    price: 15,
    color: Color(0xFF4CAF50),
    icon: Icons.palette,
    kind: 'pattern',
  ),
  ShopItem(
    id: 'pattern_purple',
    name: 'Galaxy Purple',
    price: 20,
    color: Color(0xFF9C27B0),
    icon: Icons.palette,
    kind: 'pattern',
  ),
  ShopItem(
    id: 'acc_antenna',
    name: 'Antenna',
    price: 15,
    color: Color(0xFFFFC107),
    icon: Icons.settings_input_antenna,
    kind: 'accessory',
  ),
  ShopItem(
    id: 'acc_star',
    name: 'Star Badge',
    price: 25,
    color: Color(0xFFFFD700),
    icon: Icons.star,
    kind: 'accessory',
  ),
  ShopItem(
    id: 'acc_crown',
    name: 'Champion Crown',
    price: 40,
    color: Color(0xFFFFB300),
    icon: Icons.emoji_events,
    kind: 'accessory',
  ),
];

ShopItem shopItemById(String id) => kShopItems.firstWhere((i) => i.id == id);
