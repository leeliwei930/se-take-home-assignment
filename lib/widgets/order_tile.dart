import 'package:flutter/material.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/screens/constants/radius.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.order,
    required this.onTap,
  });

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          color: Colors.orange[100],
          borderRadius: BorderRadius.all(
            Radius.circular(kRadiusSmall),
          ),
        ),

        child: Center(child: Text('ORDER ${order.id}')),
      ),
    );
  }
}
