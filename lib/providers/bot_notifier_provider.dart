import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/providers/bot_notifier_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bot_notifier_provider.g.dart';

@Riverpod(keepAlive: true)
class BotNotifier extends _$BotNotifier {
  @override
  BotNotifierState build() {
    return BotNotifierState(bots: [], botIdCounter: 0);
  }

  void addBot() {
    final bot = Bot(id: state.botIdCounter, orderQueue: [], status: BotStatus.idle);
    state = state.copyWith(
      bots: [...state.bots, bot],
      botIdCounter: bot.id + 1,
    );
  }

  void removeLastAddedBot() {
    if (state.bots.isEmpty) return;

    state = state.copyWith(
      bots: state.bots.sublist(0, state.bots.length - 1),
    );
  }
}
