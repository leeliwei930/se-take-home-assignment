import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/screens/constants/radius.dart';
import 'package:food_order_simulator/screens/constants/spacing.dart';

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
              crossAxisCount: 4,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: 12,
            itemBuilder: (context, index) {
              return Container(
                height: 10,
                width: 120,
                decoration: BoxDecoration(color: Colors.orange[100]),
                child: Center(child: Text('Order $index')),
              );
            },
          ),
        ),
      ],
    );
  }
}
