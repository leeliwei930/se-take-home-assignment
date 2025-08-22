import 'dart:async';

import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/order_queue_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_notifier_provider.g.dart';

const kCookingDuration = 10;

@Riverpod(keepAlive: true)
class OrderNotifier extends _$OrderNotifier {
  @override
  OrderQueueState build() {
    return OrderQueueState(
      vipOrdersQueue: {},
      normalOrdersQueue: {},
      orderIdCounter: 0,
    );
  }

  void addVIPOrder() {
    final orderId = state.orderIdCounter;
    final order = Order(
      id: orderId,
      status: OrderStatus.pending,
      type: OrderPriority.vip,
    );
    state = state.copyWith(vipOrdersQueue: {...state.vipOrdersQueue, order.id: order}, orderIdCounter: order.id + 1);
  }

  void addNormalOrder() {
    final order = Order(
      id: state.orderIdCounter,
      status: OrderStatus.pending,
      type: OrderPriority.normal,
    );
    state = state.copyWith(
      normalOrdersQueue: {...state.normalOrdersQueue, order.id: order},
      orderIdCounter: order.id + 1,
    );
  }

  void updateOrderById(
    int orderId, {
    OrderStatus? status,
    Bot? preparedBy,
    DateTime? completedAt,
  }) {
    final order = state.vipOrdersQueue[orderId] ?? state.normalOrdersQueue[orderId];
    if (order == null) return;

    final orderType = order.type;
    final newOrder = order.copyWith(
      status: status,
      preparedBy: preparedBy,
      completedAt: completedAt,
    );
    if (orderType == OrderPriority.vip) {
      state = state.copyWith(
        vipOrdersQueue: {...state.vipOrdersQueue, order.id: newOrder},
      );
    } else {
      state = state.copyWith(normalOrdersQueue: {...state.normalOrdersQueue, order.id: newOrder});
    }
  }
}
