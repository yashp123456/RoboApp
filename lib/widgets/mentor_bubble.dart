import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// "Volt", the AI robot mentor. Shows a rotating set of tips and can be given
/// a one-off [overrideMessage] (e.g. a reaction to a failed test run).
class MentorBubble extends StatefulWidget {
  final List<String> tips;
  final String? overrideMessage;

  const MentorBubble({super.key, required this.tips, this.overrideMessage});

  @override
  State<MentorBubble> createState() => _MentorBubbleState();
}

class _MentorBubbleState extends State<MentorBubble> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tips = widget.tips.isEmpty ? ['Keep going, engineer!'] : widget.tips;
    final message = widget.overrideMessage ?? tips[_index % tips.length];

    return GestureDetector(
      onTap: () {
        if (widget.overrideMessage == null) {
          setState(() => _index = (_index + 1) % tips.length);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Volt the Mentor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14, height: 1.25),
                  ),
                  if (widget.overrideMessage == null && tips.length > 1) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Tap for another tip ▸',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
