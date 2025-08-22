import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/bot_provider_states.dart';
import 'package:food_order_simulator/providers/order_notifier_provider.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bot_providers.g.dart';

@riverpod
class BotsNotifier extends _$BotsNotifier {
  @override
  BotNotifierState build() {
    return BotNotifierState(bots: {}, botIdCounter: 0);
  }

  void addBot() {
    final bot = Bot(id: state.botIdCounter, orderFutureQueue: {});
    state = state.copyWith(
      bots: {...state.bots, bot.id: bot},
      botIdCounter: state.botIdCounter + 1,
    );
  }

  void removeLastAddedBot() {
    if (state.bots.isEmpty) return;
    final lastBot = state.bots.values.last;

    final bots = state.bots;
    bots.remove(lastBot.id);
    cancelAllOrderFromBot(lastBot);
    state = state.copyWith(bots: bots);
  }

  Bot? getIdleBot() {
    return state.bots.values.where((bot) => bot.status == BotStatus.idle).firstOrNull;
  }

  Bot? getBotById(int botId) {
    return state.bots[botId];
  }

  void poll() {
    final idleBot = getIdleBot();
    if (idleBot == null) return;

    final orderNotifier = ref.read(orderNotifierProvider);
    final vipOrder = orderNotifier.vipOrdersQueue.values
        .where((order) => order.status == OrderStatus.pending)
        .firstOrNull;
    final normalOrder = orderNotifier.normalOrdersQueue.values
        .where((order) => order.status == OrderStatus.pending)
        .firstOrNull;

    if (vipOrder != null) {
      assignOrderToBot(order: vipOrder, bot: idleBot);
    } else if (normalOrder != null) {
      assignOrderToBot(order: normalOrder, bot: idleBot);
    }
  }

  Future<void> assignOrderToBot({
    required Order order,
    required Bot bot,
  }) async {
    final orderNotifier = ref.read(orderNotifierProvider.notifier);

    final completedAt = DateTime.now().add(const Duration(seconds: 10));
    orderNotifier.updateOrderById(
      order.id,
      preparedBy: bot,
      completedAt: completedAt,
      status: OrderStatus.processing,
    );
    final orderId = order.id;
    final future = Future.delayed(const Duration(seconds: 10), () {
      final orderNotifier = ref.read(orderNotifierProvider.notifier);
      final _orderNotifierState = ref.read(orderNotifierProvider);
      final _order = _orderNotifierState.vipOrdersQueue[orderId] ?? _orderNotifierState.normalOrdersQueue[orderId];
      if (_order == null) {
        return;
      }
      if (_order.preparedBy == null || _order.status == OrderStatus.completed) {
        return;
      }

      final bot = ref.read(botsNotifierProvider.notifier).getBotById(_order.preparedBy!.id);
      if (bot == null) return;

      orderNotifier.updateOrderById(
        _order.id,
        status: OrderStatus.completed,
        preparedBy: _order.preparedBy,
        completedAt: _order.completedAt,
      );
      removeOrderFromBotOrderFutureQueue(_order.id, bot);
    });

    final newBot = bot.copyWith(
      orderFutureQueue: {...bot.orderFutureQueue, order.id: future},
    );
    state = state.copyWith(bots: {...state.bots, bot.id: newBot});

    return future;
  }

  void removeOrderFromBotOrderFutureQueue(int orderId, Bot bot) {
    final existingQueue = bot.orderFutureQueue;
    existingQueue.remove(orderId);
    final newBot = bot.copyWith(
      orderFutureQueue: existingQueue,
    );
    state = state.copyWith(bots: {...state.bots, bot.id: newBot});
  }

  void cancelAllOrderFromBot(Bot bot) {
    final orderNotifier = ref.read(orderNotifierProvider.notifier);
    final orderState = ref.read(orderNotifierProvider);
    bot.orderFutureQueue.forEach((orderId, future) {
      final order = orderState.vipOrdersQueue[orderId] ?? orderState.normalOrdersQueue[orderId];
      // No op if order is not found
      if (order == null) return;

      // Don't cancel any order that is completed
      if (order.status == OrderStatus.completed) return;

      orderNotifier.updateOrderById(
        orderId,
        status: OrderStatus.pending,
        preparedBy: null,
        completedAt: null,
      );
    });
    final newBot = bot.copyWith(orderFutureQueue: {});
    state = state.copyWith(bots: {...state.bots, bot.id: newBot});
  }
}
