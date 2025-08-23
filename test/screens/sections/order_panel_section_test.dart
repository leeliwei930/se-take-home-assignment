import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/providers/order_queue_provider.dart';
import 'package:food_order_simulator/providers/order_queue_state.dart';
import 'package:food_order_simulator/screens/sections/order_panel_section.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('OrderPanelSection Widget Tests', () {
    late MockOrderQueue mockOrderQueue;

    setUp(() {
      mockOrderQueue = MockOrderQueue();

      // Set up the mock's build method to return a default state
      when(() => mockOrderQueue.build()).thenReturn(
        OrderQueueState(
          vipOrdersQueue: {},
          normalOrdersQueue: {},
          orderIdCounter: 0,
        ),
      );
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          orderQueueProvider.overrideWith(() => mockOrderQueue),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: OrderPanelSection(),
          ),
        ),
      );
    }

    testWidgets('should display both FilledButton texts correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check that both button texts are visible
      expect(find.text('New Normal Order'), findsOneWidget);
      expect(find.text('New VIP Order'), findsOneWidget);
    });

    testWidgets('should display FilledButton icons correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check that both buttons have add icons
      expect(find.byIcon(Icons.add), findsNWidgets(2));
    });

    testWidgets('should call addNormalOrder when New Normal Order button is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find the specific "New Normal Order" button text and tap it
      final normalOrderText = find.text('New Normal Order');
      expect(normalOrderText, findsOneWidget);

      // Act
      await tester.tap(normalOrderText);
      await tester.pump();

      // Assert
      verify(() => mockOrderQueue.addNormalOrder()).called(1);
    });

    testWidgets('should call addVIPOrder when New VIP Order button is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Find the specific "New VIP Order" button text and tap it
      final vipOrderText = find.text('New VIP Order');
      expect(vipOrderText, findsOneWidget);

      // Act
      await tester.tap(vipOrderText);
      await tester.pump();

      // Assert
      verify(() => mockOrderQueue.addVIPOrder()).called(1);
    });

    testWidgets('should not call any methods on initial render', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Verify no methods were called during initial render
      verifyNever(() => mockOrderQueue.addNormalOrder());
      verifyNever(() => mockOrderQueue.addVIPOrder());
    });

    testWidgets('should handle multiple button taps correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      final normalOrderText = find.text('New Normal Order');
      final vipOrderText = find.text('New VIP Order');

      // Act - Tap normal order button twice
      await tester.tap(normalOrderText);
      await tester.pump();
      await tester.tap(normalOrderText);
      await tester.pump();

      // Act - Tap VIP order button once
      await tester.tap(vipOrderText);
      await tester.pump();

      // Assert
      verify(() => mockOrderQueue.addNormalOrder()).called(2);
      verify(() => mockOrderQueue.addVIPOrder()).called(1);
    });
  });
}
