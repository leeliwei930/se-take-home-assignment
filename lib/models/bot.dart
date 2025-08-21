import 'package:equatable/equatable.dart';
import 'package:food_order_simulator/models/order.dart';

enum BotStatus {
  idle,
  cooking,
}

class Bot extends Equatable {
  const Bot({
    required this.id,
    required this.orderQueue,
    required this.status,
  });

  final int id;
  final List<Order> orderQueue;
  final BotStatus status;

  @override
  List<Object?> get props => [id, orderQueue, status];
}
