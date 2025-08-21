// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$completedOrdersHash() => r'2298f7706fc53533b98469d138b629b37979463c';

/// See also [CompletedOrders].
@ProviderFor(CompletedOrders)
final completedOrdersProvider =
    AutoDisposeNotifierProvider<CompletedOrders, List<Order>>.internal(
      CompletedOrders.new,
      name: r'completedOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$completedOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CompletedOrders = AutoDisposeNotifier<List<Order>>;
String _$pendingOrdersHash() => r'71bea335e7e9dbfda963bfa09da7c0c3df2ccf86';

/// See also [PendingOrders].
@ProviderFor(PendingOrders)
final pendingOrdersProvider =
    AutoDisposeNotifierProvider<PendingOrders, List<Order>>.internal(
      PendingOrders.new,
      name: r'pendingOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingOrders = AutoDisposeNotifier<List<Order>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
