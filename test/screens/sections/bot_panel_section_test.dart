import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/providers/bot_providers.dart';
import 'package:food_order_simulator/providers/bot_provider_states.dart';
import 'package:food_order_simulator/providers/order_queue_provider.dart';
import 'package:food_order_simulator/providers/order_queue_state.dart';
import 'package:food_order_simulator/screens/sections/bot_panel_section.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('BotPanelSection Widget Tests', () {
    late MockBotsOrchestrator mockBotsOrchestrator;
    late MockOrderQueue mockOrderQueue;

    setUp(() {
      mockBotsOrchestrator = MockBotsOrchestrator();
      mockOrderQueue = MockOrderQueue();

      // Set up the order queue mock to return an empty state
      when(() => mockOrderQueue.build()).thenReturn(
        OrderQueueState(
          vipOrdersQueue: {},
          normalOrdersQueue: {},
          orderIdCounter: 0,
        ),
      );
    });

    Widget createTestWidget({
      required BotsOrchestratorState orchestratorState,
    }) {
      // Set up the orchestrator mock to return the provided state
      when(() => mockBotsOrchestrator.build()).thenReturn(orchestratorState);

      return ProviderScope(
        overrides: [
          botsOrchestratorProvider.overrideWith(() => mockBotsOrchestrator),
          orderQueueProvider.overrideWith(() => mockOrderQueue),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BotPanelSection(),
          ),
        ),
      );
    }

    testWidgets('should display BOT Control Panel title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(
          orchestratorState: BotsOrchestratorState(botIdCounter: 0, botIds: {}),
        ),
      );

      // Assert
      expect(find.text('BOT Control Panel'), findsOneWidget);
    });

    testWidgets('should display Add Bot and Remove Bot buttons', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(
          orchestratorState: BotsOrchestratorState(botIdCounter: 0, botIds: {}),
        ),
      );

      // Assert - Check button texts
      expect(find.text('Bot'), findsNWidgets(2));

      // Assert - Check button icons
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('should display bots when they exist', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(
          orchestratorState: BotsOrchestratorState(
            botIdCounter: 2,
            botIds: {0: true, 1: true},
          ),
        ),
      );

      // Assert - Check that bot captions are displayed
      expect(find.text('Bot 1'), findsOneWidget);
      expect(find.text('Bot 2'), findsOneWidget);
    });

    testWidgets('should call addBot when Add Bot button is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          orchestratorState: BotsOrchestratorState(botIdCounter: 0, botIds: {}),
        ),
      );

      // Find the add button by locating the add icon within BotPanelSection
      final addIcon = find.descendant(
        of: find.byType(BotPanelSection),
        matching: find.byIcon(Icons.add),
      );
      expect(addIcon, findsOneWidget);

      // Act
      await tester.tap(addIcon);
      await tester.pump();

      // Assert
      verify(() => mockBotsOrchestrator.addBot()).called(1);
    });

    testWidgets('should call removeLastAddedBot when Remove Bot button is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          orchestratorState: BotsOrchestratorState(
            botIdCounter: 1,
            botIds: {0: true},
          ),
        ),
      );

      // Find the remove button by locating the remove icon within BotPanelSection
      final removeIcon = find.descendant(
        of: find.byType(BotPanelSection),
        matching: find.byIcon(Icons.remove),
      );
      expect(removeIcon, findsOneWidget);

      // Act
      await tester.tap(removeIcon);
      await tester.pump();

      // Assert
      verify(() => mockBotsOrchestrator.removeLastAddedBot()).called(1);
    });

    testWidgets('should not call any methods on initial render', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(
          orchestratorState: BotsOrchestratorState(botIdCounter: 0, botIds: {}),
        ),
      );

      // Assert - Verify no methods were called during initial render
      verifyNever(() => mockBotsOrchestrator.addBot());
      verifyNever(() => mockBotsOrchestrator.removeLastAddedBot());
    });

    testWidgets('should handle multiple button taps correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          orchestratorState: BotsOrchestratorState(
            botIdCounter: 1,
            botIds: {0: true},
          ),
        ),
      );

      // Find buttons by their icons within BotPanelSection
      final addIcon = find.descendant(
        of: find.byType(BotPanelSection),
        matching: find.byIcon(Icons.add),
      );
      final removeIcon = find.descendant(
        of: find.byType(BotPanelSection),
        matching: find.byIcon(Icons.remove),
      );

      // Act - Tap add button twice
      await tester.tap(addIcon);
      await tester.pump();
      await tester.tap(addIcon);
      await tester.pump();

      // Act - Tap remove button once
      await tester.tap(removeIcon);
      await tester.pump();

      // Assert
      verify(() => mockBotsOrchestrator.addBot()).called(2);
      verify(() => mockBotsOrchestrator.removeLastAddedBot()).called(1);
    });
  });
}
