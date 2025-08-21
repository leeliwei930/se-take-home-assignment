import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/order_notifier_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_providers.g.dart';

@riverpod
class CompletedOrders extends _$CompletedOrders {
  @override
  List<Order> build() {
    final orderState = ref.watch(orderNotifierProvider);
    final vipOrders = orderState.vipOrdersQueue.where((order) => order.status == OrderStatus.completed);
    final normalOrders = orderState.normalOrdersQueue.where((order) => order.status == OrderStatus.completed);
    return [...vipOrders, ...normalOrders];
  }
}

@riverpod
class PendingOrders extends _$PendingOrders {
  @override
  List<Order> build() {
    final orderState = ref.watch(orderNotifierProvider);
    final vipOrders = orderState.vipOrdersQueue.where((order) => order.status == OrderStatus.pending);
    final normalOrders = orderState.normalOrdersQueue.where((order) => order.status == OrderStatus.pending);
    return [...vipOrders, ...normalOrders];
  }
}
