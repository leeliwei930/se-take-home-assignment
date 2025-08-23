import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/screens/sections/order_section.dart';
import 'package:food_order_simulator/widgets/order_tile.dart';

void main() {
  group('OrderSection Widget Tests', () {
    /// Helper method to create test orders
    Order createTestOrder({
      required int id,
      OrderStatus status = OrderStatus.pending,
      OrderPriority type = OrderPriority.normal,
    }) {
      return Order(
        id: id,
        status: status,
        type: type,
      );
    }

    Widget createTestWidget({
      required String title,
      required Color backgroundColor,
      required List<Order> orders,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: OrderSection(
              title: title,
              backgroundColor: backgroundColor,
              orders: orders,
            ),
          ),
        ),
      );
    }

    testWidgets('should display title correctly', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Orders';
      const testColor = Colors.blue;
      final testOrders = <Order>[];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('should display container with correct background color', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Orders';
      const testColor = Colors.red;
      final testOrders = <Order>[];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Assert
      // Find the container that contains the GridView
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(GridView),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, testColor);
    });

    testWidgets('should display GridView when orders are provided', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Orders';
      const testColor = Colors.blue;
      final testOrders = [
        createTestOrder(id: 1),
        createTestOrder(id: 2),
      ];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Assert
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should display correct number of order tiles', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Orders';
      const testColor = Colors.blue;
      final testOrders = [
        createTestOrder(id: 1),
        createTestOrder(id: 2),
        createTestOrder(id: 3),
      ];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Assert
      expect(find.byType(OrderTile), findsNWidgets(3));
    });

    testWidgets('should display order IDs correctly in tiles', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Orders';
      const testColor = Colors.blue;
      final testOrders = [
        createTestOrder(id: 101),
        createTestOrder(id: 202),
      ];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Assert
      expect(find.text('ORDER 101'), findsOneWidget);
      expect(find.text('ORDER 202'), findsOneWidget);
    });

    testWidgets('should handle empty orders list', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Empty Orders';
      const testColor = Colors.green;
      final testOrders = <Order>[];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(OrderTile), findsNothing);
    });

    testWidgets('should display different order types correctly', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Mixed Orders';
      const testColor = Colors.purple;
      final testOrders = [
        createTestOrder(id: 1, type: OrderPriority.normal),
        createTestOrder(id: 2, type: OrderPriority.vip),
      ];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Assert - Both order texts should be present
      expect(find.text('ORDER 1'), findsOneWidget);
      expect(find.text('ORDER 2'), findsOneWidget);
      expect(find.byType(OrderTile), findsNWidgets(2));
    });

    testWidgets('should handle large number of orders', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Many Orders';
      const testColor = Colors.orange;
      final testOrders = List.generate(
        10,
        (index) => createTestOrder(id: index + 1),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Assert
      expect(find.byType(OrderTile), findsNWidgets(10));
      expect(find.text('ORDER 1'), findsOneWidget);
      expect(find.text('ORDER 10'), findsOneWidget);
    });

    testWidgets('should handle tap on order tiles', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Tappable Orders';
      const testColor = Colors.cyan;
      final testOrders = [
        createTestOrder(id: 1),
        createTestOrder(id: 2),
      ];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Find the first order tile and tap it
      final firstOrderTile = find.byType(OrderTile).first;
      expect(firstOrderTile, findsOneWidget);

      // Act - Tap the order tile (should not throw)
      await tester.tap(firstOrderTile);
      await tester.pump();

      // Assert - The tap should complete without errors
      // Note: The current implementation has empty onTap, so we just verify it doesn't crash
      expect(find.byType(OrderTile), findsNWidgets(2));
    });

    testWidgets('should use correct grid configuration', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Grid Test';
      const testColor = Colors.amber;
      final testOrders = [
        createTestOrder(id: 1),
      ];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Assert - Check GridView configuration
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 6);
      expect(delegate.mainAxisExtent, 120);
      expect(gridView.scrollDirection, Axis.horizontal);
    });

    testWidgets('should have properly structured container with decoration', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Structure Test';
      const testColor = Colors.pink;
      final testOrders = [createTestOrder(id: 1)];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          title: testTitle,
          backgroundColor: testColor,
          orders: testOrders,
        ),
      );

      // Assert - Check that container exists with proper decoration
      // Find the container that contains the GridView specifically
      final containerFinder = find.ancestor(
        of: find.byType(GridView),
        matching: find.byType(Container),
      );

      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, testColor);

      // Verify GridView is inside the container
      expect(
        find.descendant(
          of: containerFinder,
          matching: find.byType(GridView),
        ),
        findsOneWidget,
      );
    });
  });
}
