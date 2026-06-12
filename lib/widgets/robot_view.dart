import 'package:flutter/material.dart';

import '../data/shop_data.dart';
import '../models/component.dart';

/// Draws the player's robot from the components mounted on the chassis plus any
/// equipped cosmetic pattern/accessory.
class RobotView extends StatelessWidget {
  final Map<SlotType, RobotComponent?> equipped;
  final String? patternId;
  final String? accessoryId;
  final double size;

  const RobotView({
    super.key,
    required this.equipped,
    this.patternId,
    this.accessoryId,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    final hasChassis = equipped[SlotType.chassis] != null;
    final bodyColor = patternId != null
        ? shopItemById(patternId!).color
        : const Color(0xFF607D8B);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Wheels (drawn behind the body).
          if (equipped[SlotType.wheel] != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: _wheel(size * 0.18),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _wheel(size * 0.18),
            ),
          ],

          // Chassis body.
          if (hasChassis)
            Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                color: bodyColor,
                borderRadius: BorderRadius.circular(size * 0.1),
                border: Border.all(color: Colors.black26, width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Eyes / face.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _eye(size * 0.08),
                      SizedBox(width: size * 0.08),
                      _eye(size * 0.08),
                    ],
                  ),
                  SizedBox(height: size * 0.04),
                  // Tool / sensor indicators.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (equipped[SlotType.sensor] != null)
                        Icon(equipped[SlotType.sensor]!.icon,
                            color: Colors.white, size: size * 0.12),
                      if (equipped[SlotType.tool] != null)
                        Icon(equipped[SlotType.tool]!.icon,
                            color: Colors.white, size: size * 0.12),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(size * 0.1),
                border: Border.all(
                    color: Colors.grey,
                    width: 2,
                    style: BorderStyle.solid),
              ),
              child: const Center(
                child: Text('Add a\nchassis',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
              ),
            ),

          // Accessory on top of the head.
          if (accessoryId != null)
            Positioned(
              top: 0,
              child: Icon(
                shopItemById(accessoryId!).icon,
                color: shopItemById(accessoryId!).color,
                size: size * 0.22,
              ),
            ),
        ],
      ),
    );
  }

  Widget _wheel(double d) => Container(
        width: d,
        height: d * 1.6,
        decoration: BoxDecoration(
          color: const Color(0xFF37474F),
          borderRadius: BorderRadius.circular(d * 0.3),
          border: Border.all(color: Colors.black54, width: 2),
        ),
      );

  Widget _eye(double d) => Container(
        width: d,
        height: d,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: d * 0.5,
            height: d * 0.5,
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
}
