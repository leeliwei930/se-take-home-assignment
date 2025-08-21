import 'package:equatable/equatable.dart';
import 'package:food_order_simulator/models/bot.dart';

class BotNotifierState extends Equatable {
  const BotNotifierState({
    required this.bots,
    required this.botIdCounter,
  });

  final Map<int, Bot> bots;
  final int botIdCounter;

  @override
  List<Object?> get props => [bots, botIdCounter];

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
