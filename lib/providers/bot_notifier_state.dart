import 'package:equatable/equatable.dart';
import 'package:food_order_simulator/models/bot.dart';

class BotNotifierState extends Equatable {
  const BotNotifierState({
    required this.bots,
    required this.botIdCounter,
  });

  final List<Bot> bots;
  final int botIdCounter;

  @override
  List<Object?> get props => [bots, botIdCounter];

  BotNotifierState copyWith({
    List<Bot>? bots,
    int? botIdCounter,
  }) {
    return BotNotifierState(
      bots: bots ?? this.bots,
      botIdCounter: botIdCounter ?? this.botIdCounter,
    );
  }
}
