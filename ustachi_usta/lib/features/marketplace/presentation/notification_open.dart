library;

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/features/marketplace/domain/entities/notification_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/features/marketplace/presentation/view/chat_page.dart';
import 'package:ustachi/features/orders/presentation/bloc/orders_bloc.dart';

enum NotificationDestination {
  openRequest,

  ownOrder,

  chat,

  none,
}

NotificationDestination notificationDestinationFor(AppNotificationType type) =>
    switch (type) {
      AppNotificationType.orderPublished ||
      AppNotificationType.orderInvite =>
        NotificationDestination.openRequest,
      AppNotificationType.chatMessage => NotificationDestination.chat,
      AppNotificationType.orderChosen ||
      AppNotificationType.orderNotChosen ||
      AppNotificationType.orderStage ||
      AppNotificationType.orderCompleted ||
      AppNotificationType.orderCancelled ||
      AppNotificationType.reviewReceived ||
      AppNotificationType.orderResponse =>
        NotificationDestination.ownOrder,
      AppNotificationType.orderInviteDeclined ||
      AppNotificationType.unknown =>
        NotificationDestination.none,
    };

bool _hasOpenRequest(String requestId) =>
    sl<OrdersBloc>().state.requests.any((request) => request.id == requestId);

Future<void> _refreshOrders() async {
  final bloc = sl<OrdersBloc>();
  final loaded = bloc.stream
      .firstWhere((state) => !state.loadStatus.isLoading)
      .timeout(const Duration(seconds: 8), onTimeout: () => bloc.state);
  bloc.add(OrdersLoadRequested());
  await loaded;
}

Future<void> openNotification(
  BuildContext context,
  AppNotificationEntity item,
) async {
  final orderId = item.orderId;
  final destination = notificationDestinationFor(item.type);
  if (destination == NotificationDestination.none || orderId == null) return;

  switch (destination) {
    case NotificationDestination.openRequest:
      await _loadAndOpenRequest(context, orderId);

    case NotificationDestination.ownOrder:
      await _loadAndShowOrder(context, orderId);

    case NotificationDestination.chat:
      await _openChat(context, orderId);

    case NotificationDestination.none:
      return;
  }
}

Future<void> _loadAndOpenRequest(BuildContext context, int orderId) async {
  final orderIdStr = orderId.toString();
  await _refreshOrders();
  if (!context.mounted) return;

  if (_hasOpenRequest(orderIdStr)) {
    context.router.push(OrderRequestPageRoute(requestId: orderIdStr));
    return;
  }

  context.router.push(OrderDetailPageRoute(orderId: orderIdStr));
}

Future<void> _loadAndShowOrder(BuildContext context, int orderId) async {
  final orderIdStr = orderId.toString();
  await _refreshOrders();
  if (!context.mounted) return;

  context.router.push(OrderDetailPageRoute(orderId: orderIdStr));
}

Future<void> _openChat(BuildContext context, int orderId) async {
  final result = await sl<MarketplaceRepository>().threads(orderId: orderId);
  if (!context.mounted) return;

  final threads = result.isRight ? result.right : const [];
  if (threads.isEmpty) {
    context.router.push(OrderDetailPageRoute(orderId: '$orderId'));
    return;
  }

  final thread = threads.first;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChatPage(
        threadId: thread.id,
        title: thread.peer.displayName,
        orderId: orderId,
      ),
    ),
  );
}
