import 'dart:async';

import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/bot_notifier_state.dart';
import 'package:food_order_simulator/providers/order_notifier_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bot_notifier_provider.g.dart';

const kMaxParallelOrders = 1;

@Riverpod(keepAlive: true)
class BotNotifier extends _$BotNotifier {
  @override
  BotNotifierState build() {
    return BotNotifierState(bots: {}, botIdCounter: 0);
  }

  // Two approach to trigger
  // New bot get added
  // New order get added
  // When bot complete order, it will check if there is any order in the queue

  void addBot() {
    final bot = Bot(
      id: state.botIdCounter,
      orderQueue: [],
      status: BotStatus.idle,
    );

    // Look for any unprocessed VIP orders
    final orderNotifier = ref.read(orderNotifierProvider);
    for (var i = 0; i < kMaxParallelOrders; i++) {
      final vipOrder = orderNotifier.vipOrdersQueue.values
          .where((order) => order.status == OrderStatus.pending)
          .firstOrNull;
      final normalOrder = orderNotifier.normalOrdersQueue.values
          .where((order) => order.status == OrderStatus.pending)
          .firstOrNull;
      if (vipOrder != null) {
        bot.orderQueue.add(vipOrder);
      } else if (normalOrder != null) {
        bot.orderQueue.add(normalOrder);
      }
    }

    state = state.copyWith(
      bots: {...state.bots, bot.id: bot},
      botIdCounter: state.botIdCounter + 1,
    );
  }

  void removeLastAddedBot() {
    if (state.bots.values.isEmpty) return;

    final lastBot = state.bots.values.last;
    state = state.copyWith(
      bots: Map.from(state.bots)..remove(lastBot.id),
    );
  }
}
