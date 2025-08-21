import 'package:equatable/equatable.dart';
import 'package:food_order_simulator/models/order.dart';

class Bot extends Equatable {
  const Bot({
    required this.id,
    required this.orderQueue,
  });

  final int id;
  final List<Order> orderQueue;

  @override
  List<Object?> get props => [id, orderQueue];
}
