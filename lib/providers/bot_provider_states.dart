import 'package:food_order_simulator/models/bot.dart';

class BotNotifierState {
  final Map<int, Bot> bots;
  final int botIdCounter;

  BotNotifierState({
    required this.bots,
    required this.botIdCounter,
  });

  BotNotifierState copyWith({
    Map<int, Bot>? bots,
    int? botIdCounter,
  }) {
    return BotNotifierState(
      bots: bots ?? this.bots,
      botIdCounter: botIdCounter ?? this.botIdCounter,
    );
  }
}
