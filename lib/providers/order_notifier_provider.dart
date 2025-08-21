import 'dart:async';

import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/order_queue_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_notifier_provider.g.dart';

const kCookingDuration = Duration(seconds: 10);

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
    final order = Order(
      id: state.orderIdCounter,
      cookTimer: Timer(kCookingDuration, () {}),
      status: OrderStatus.pending,
      type: OrderPriority.vip,
    );
    state = state.copyWith(vipOrdersQueue: {...state.vipOrdersQueue, order.id: order}, orderIdCounter: order.id + 1);
  }

  void addNormalOrder() {
    final order = Order(
      id: state.orderIdCounter,
      cookTimer: Timer(kCookingDuration, () {}),
      status: OrderStatus.pending,
      type: OrderPriority.normal,
    );
    state = state.copyWith(
      normalOrdersQueue: {...state.normalOrdersQueue, order.id: order},
      orderIdCounter: order.id + 1,
    );
  }

  void completeOrder(Order order) {}
}
