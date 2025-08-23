import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/bot_providers.dart';
import 'package:food_order_simulator/providers/order_queue_provider.dart';
import 'package:food_order_simulator/providers/order_queue_state.dart';
import 'package:food_order_simulator/screens/modals/bot_detail_modal.dart';
import 'package:food_order_simulator/widgets/bot_avatar.dart';
import 'package:food_order_simulator/widgets/job_timer.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('BotDetailModal Widget Tests', () {
    late MockBotFactory mockBotFactory;
    late MockOrderQueue mockOrderQueue;

    setUp(() {
      mockBotFactory = MockBotFactory();
      mockOrderQueue = MockOrderQueue();
    });

    /// Helper method to create test orders
    Order createTestOrder({
      required int id,
      OrderStatus status = OrderStatus.processing,
      OrderPriority type = OrderPriority.normal,
      DateTime? completedAt,
    }) {
      return Order(
        id: id,
        status: status,
        type: type,
        completedAt: completedAt,
      );
    }

    /// Helper method to create test bot
    Bot createTestBot({
      required int id,
      Map<int, Timer>? orderTimerQueue,
    }) {
      return Bot(
        id: id,
        orderTimerQueue: orderTimerQueue ?? {},
      );
    }

    Widget createTestWidget({
      required int botId,
      required int index,
      Bot? mockBot,
      OrderQueueState? mockOrderQueueState,
    }) {
      // Set up bot factory mock
      when(() => mockBotFactory.build(id: botId)).thenReturn(
        mockBot ?? createTestBot(id: botId),
      );

      // Set up order queue mock
      when(() => mockOrderQueue.build()).thenReturn(
        mockOrderQueueState ??
            OrderQueueState(
              vipOrdersQueue: {},
              normalOrdersQueue: {},
              orderIdCounter: 0,
            ),
      );

      return ProviderScope(
        overrides: [
          botFactoryProvider(id: botId).overrideWith(() => mockBotFactory),
          orderQueueProvider.overrideWith(() => mockOrderQueue),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BotDetailModal(
              botId: botId,
              index: index,
            ),
          ),
        ),
      );
    }

    testWidgets('should display bot avatar with correct caption', (WidgetTester tester) async {
      // Arrange
      const botId = 1;
      const index = 2;
      final testBot = createTestBot(id: botId);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          botId: botId,
          index: index,
          mockBot: testBot,
        ),
      );

      // Assert
      expect(find.byType(BotAvatar), findsOneWidget);
      expect(find.text('Bot $index'), findsOneWidget);
    });

    testWidgets('should display idle status for idle bot', (WidgetTester tester) async {
      // Arrange
      const botId = 1;
      const index = 1;
      final idleBot = createTestBot(id: botId, orderTimerQueue: {});

      // Act
      await tester.pumpWidget(
        createTestWidget(
          botId: botId,
          index: index,
          mockBot: idleBot,
        ),
      );

      // Assert
      expect(find.text('Idle'), findsOneWidget);
      expect(find.text('0 orders in job queue'), findsOneWidget);
    });

    testWidgets('should display cooking status for busy bot', (WidgetTester tester) async {
      // Arrange
      const botId = 1;
      const index = 1;
      // Create a timer to simulate an order being processed
      final timer = Timer(const Duration(seconds: 10), () {});
      final busyBot = createTestBot(
        id: botId,
        orderTimerQueue: {101: timer},
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          botId: botId,
          index: index,
          mockBot: busyBot,
        ),
      );

      // Assert
      expect(find.text('Cooking'), findsOneWidget);
      expect(find.text('1 orders in job queue'), findsOneWidget);

      // Clean up
      timer.cancel();
    });

    testWidgets('should display correct order count for multiple orders', (WidgetTester tester) async {
      // Arrange
      const botId = 1;
      const index = 1;
      final timer1 = Timer(const Duration(seconds: 10), () {});
      final timer2 = Timer(const Duration(seconds: 15), () {});
      final timer3 = Timer(const Duration(seconds: 20), () {});

      final busyBot = createTestBot(
        id: botId,
        orderTimerQueue: {101: timer1, 102: timer2, 103: timer3},
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          botId: botId,
          index: index,
          mockBot: busyBot,
        ),
      );

      // Assert
      expect(find.text('Cooking'), findsOneWidget);
      expect(find.text('3 orders in job queue'), findsOneWidget);

      // Clean up
      timer1.cancel();
      timer2.cancel();
      timer3.cancel();
    });

    testWidgets('should display order list with job timers', (WidgetTester tester) async {
      // Arrange
      const botId = 1;
      const index = 1;
      final now = DateTime.now();
      final completedAt = now.add(const Duration(seconds: 30));

      final timer = Timer(const Duration(seconds: 30), () {});
      final busyBot = createTestBot(
        id: botId,
        orderTimerQueue: {101: timer},
      );

      final testOrder = createTestOrder(
        id: 101,
        completedAt: completedAt,
      );

      final orderQueueState = OrderQueueState(
        vipOrdersQueue: {},
        normalOrdersQueue: {101: testOrder},
        orderIdCounter: 1,
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          botId: botId,
          index: index,
          mockBot: busyBot,
          mockOrderQueueState: orderQueueState,
        ),
      );

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Order 101'), findsOneWidget);
      expect(find.byType(JobTimer), findsOneWidget);

      // Clean up
      timer.cancel();
    });

    testWidgets('should handle VIP orders in queue', (WidgetTester tester) async {
      // Arrange
      const botId = 1;
      const index = 1;
      final now = DateTime.now();
      final completedAt = now.add(const Duration(seconds: 45));

      final timer = Timer(const Duration(seconds: 45), () {});
      final busyBot = createTestBot(
        id: botId,
        orderTimerQueue: {201: timer},
      );

      final vipOrder = createTestOrder(
        id: 201,
        type: OrderPriority.vip,
        completedAt: completedAt,
      );

      final orderQueueState = OrderQueueState(
        vipOrdersQueue: {201: vipOrder},
        normalOrdersQueue: {},
        orderIdCounter: 1,
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          botId: botId,
          index: index,
          mockBot: busyBot,
          mockOrderQueueState: orderQueueState,
        ),
      );

      // Assert
      expect(find.text('Order 201'), findsOneWidget);
      expect(find.byType(JobTimer), findsOneWidget);

      // Clean up
      timer.cancel();
    });

    testWidgets('should not display orders without completedAt', (WidgetTester tester) async {
      // Arrange
      const botId = 1;
      const index = 1;

      final timer = Timer(const Duration(seconds: 30), () {});
      final busyBot = createTestBot(
        id: botId,
        orderTimerQueue: {101: timer},
      );

      final incompleteOrder = createTestOrder(
        id: 101,
        completedAt: null, // No completedAt
      );

      final orderQueueState = OrderQueueState(
        vipOrdersQueue: {},
        normalOrdersQueue: {101: incompleteOrder},
        orderIdCounter: 1,
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          botId: botId,
          index: index,
          mockBot: busyBot,
          mockOrderQueueState: orderQueueState,
        ),
      );

      // Assert
      expect(find.text('1 orders in job queue'), findsOneWidget);
      expect(find.text('Order 101'), findsNothing); // Should not display
      expect(find.byType(JobTimer), findsNothing);

      // Clean up
      timer.cancel();
    });

    testWidgets('should display multiple orders correctly', (WidgetTester tester) async {
      // Arrange
      const botId = 1;
      const index = 1;
      final now = DateTime.now();

      final timer1 = Timer(const Duration(seconds: 30), () {});
      final timer2 = Timer(const Duration(seconds: 45), () {});
      final busyBot = createTestBot(
        id: botId,
        orderTimerQueue: {101: timer1, 102: timer2},
      );

      final order1 = createTestOrder(
        id: 101,
        completedAt: now.add(const Duration(seconds: 30)),
      );
      final order2 = createTestOrder(
        id: 102,
        type: OrderPriority.vip,
        completedAt: now.add(const Duration(seconds: 45)),
      );

      final orderQueueState = OrderQueueState(
        vipOrdersQueue: {102: order2},
        normalOrdersQueue: {101: order1},
        orderIdCounter: 2,
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          botId: botId,
          index: index,
          mockBot: busyBot,
          mockOrderQueueState: orderQueueState,
        ),
      );

      // Assert
      expect(find.text('2 orders in job queue'), findsOneWidget);
      expect(find.text('Order 101'), findsOneWidget);
      expect(find.text('Order 102'), findsOneWidget);
      expect(find.byType(JobTimer), findsNWidgets(2));

      // Clean up
      timer1.cancel();
      timer2.cancel();
    });

    testWidgets('should show modal when static show method is called', (WidgetTester tester) async {
      // Arrange
      const botId = 1;
      const index = 1;
      final testBot = createTestBot(id: botId);

      // Set up mocks for the modal content
      when(() => mockBotFactory.build(id: botId)).thenReturn(testBot);
      when(() => mockOrderQueue.build()).thenReturn(
        OrderQueueState(
          vipOrdersQueue: {},
          normalOrdersQueue: {},
          orderIdCounter: 0,
        ),
      );

      Widget testApp = ProviderScope(
        overrides: [
          botFactoryProvider(id: botId).overrideWith(() => mockBotFactory),
          orderQueueProvider.overrideWith(() => mockOrderQueue),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => BotDetailModal.show(
                  context,
                  botId: botId,
                  index: index,
                ),
                child: const Text('Show Modal'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(testApp);
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle(); // Wait for modal animation

      // Assert
      expect(find.byType(BotDetailModal), findsOneWidget);
      expect(find.text('Bot $index'), findsOneWidget);
    });

    testWidgets('should handle edge case with empty order queue and no timers', (WidgetTester tester) async {
      // Arrange
      const botId = 999;
      const index = 5;
      final emptyBot = createTestBot(id: botId, orderTimerQueue: {});
      final emptyOrderQueue = OrderQueueState(
        vipOrdersQueue: {},
        normalOrdersQueue: {},
        orderIdCounter: 0,
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          botId: botId,
          index: index,
          mockBot: emptyBot,
          mockOrderQueueState: emptyOrderQueue,
        ),
      );

      // Assert
      expect(find.text('Bot $index'), findsOneWidget);
      expect(find.text('Idle'), findsOneWidget);
      expect(find.text('0 orders in job queue'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      expect(find.byType(JobTimer), findsNothing);
    });
  });
}
