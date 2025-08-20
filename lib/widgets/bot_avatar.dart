import 'package:flutter/material.dart';

class BotAvatar extends StatelessWidget {
  final String caption;
  final double size;
  final TextStyle? captionStyle;

  const BotAvatar({
    Key? key,
    required this.caption,
    this.size = 64.0,
    this.captionStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.blue[200],
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
    );
  }
}
