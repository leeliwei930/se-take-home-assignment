import 'package:flutter/material.dart';

class BotAvatar extends StatelessWidget {
  final String caption;
  final double size;
  final TextStyle? captionStyle;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const BotAvatar({
    super.key,
    required this.caption,
    this.size = 64.0,
    this.captionStyle,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: backgroundColor ?? Colors.blue[200],
            child: Text(
              'BOT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size / 3,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style:
                captionStyle ??
                TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
