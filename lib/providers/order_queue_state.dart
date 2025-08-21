import 'package:equatable/equatable.dart';
import 'package:food_order_simulator/models/order.dart';

class OrderQueueState extends Equatable {
  const OrderQueueState({
    required this.orderIdCounter,
    required this.vipOrdersQueue,
    required this.normalOrdersQueue,
  });

  final int orderIdCounter;
  final Map<int, Order> vipOrdersQueue;
  final Map<int, Order> normalOrdersQueue;

  @override
  List<Object?> get props => [orderIdCounter, vipOrdersQueue, normalOrdersQueue];

  OrderQueueState copyWith({
    int? orderIdCounter,
    Map<int, Order>? vipOrdersQueue,
    Map<int, Order>? normalOrdersQueue,
  }) {
    return OrderQueueState(
      orderIdCounter: orderIdCounter ?? this.orderIdCounter,
      vipOrdersQueue: vipOrdersQueue ?? this.vipOrdersQueue,
      normalOrdersQueue: normalOrdersQueue ?? this.normalOrdersQueue,
    );
  }
}
