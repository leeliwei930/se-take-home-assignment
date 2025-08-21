import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/screens/constants/radius.dart';
import 'package:food_order_simulator/screens/constants/spacing.dart';
import 'package:food_order_simulator/widgets/order_tile.dart';

class OrderSection extends ConsumerWidget {
  const OrderSection({
    super.key,
    required this.title,
    required this.backgroundColor,
  });

  final String title;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: kSpacingSmall,
          ),
          child: Text(title),
        ),

        Container(
          height: 320,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(kRadiusMedium),
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisExtent: 120,
              crossAxisSpacing: kSpacingXxSmall,
              mainAxisSpacing: kSpacingXxSmall,
            ),

            scrollDirection: Axis.horizontal,
            itemCount: 2,
            padding: const EdgeInsets.all(kSpacingSmall),
            itemBuilder: (context, index) {
              return OrderTile(
                order: Order(
                  id: index,
                  cookTimer: Timer(const Duration(seconds: 10), () {}),
                  status: OrderStatus.pending,
                  type: OrderPriority.normal,
                ),
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}
