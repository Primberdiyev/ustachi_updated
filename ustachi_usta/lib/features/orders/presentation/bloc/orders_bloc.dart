import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_status.dart';
import 'package:ustachi/features/orders/domain/entities/master_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/order_request_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/repositories/orders_repository.dart';
import 'package:ustachi/features/orders/domain/repositories/own_orders_repository.dart';
import 'package:ustachi/features/orders/domain/services/own_order_mapper.dart';
import 'package:ustachi/features/orders/domain/services/own_order_outbox.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

part 'orders_bloc.freezed.dart';
part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc({
    required OrdersRepository repository,
    OwnOrdersRepository? ownRepository,
    OwnOrderOutbox? outbox,
  })  : _repository = repository,
        _ownRepository = ownRepository,
        _outbox = outbox,
        super(const OrdersState()) {
    on<OrdersLoadRequested>(_onLoadRequested);
    on<OrdersSegmentChanged>(_onSegmentChanged);
    on<OrderOfferSent>(_onOfferSent);
    on<OrderRequestDeclined>(_onRequestDeclined);
    on<OrderStageCompleted>(_onStageCompleted);
    on<OwnOrderStatusChanged>(_onOwnStatusChanged);

  }

  final OrdersRepository _repository;

  final OwnOrdersRepository? _ownRepository;

  final OwnOrderOutbox? _outbox;

  Future<void> _onLoadRequested(
    OrdersLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(loadStatus: Statuses.loading, failure: null));

    await _outbox?.flush();

    final requestsFuture = _repository.requests();
    final ordersFuture = _repository.orders();

    final requestsResult = await requestsFuture;
    final ordersResult = await ordersFuture;

    if (requestsResult.isLeft && ordersResult.isLeft) {
      emit(
        state.copyWith(
          loadStatus: Statuses.failure,
          failure: requestsResult.left,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loadStatus: Statuses.success,
        requests:
            requestsResult.isRight ? requestsResult.right : state.requests,
        orders: ordersResult.isRight ? ordersResult.right : state.orders,
        failure: requestsResult.isLeft
            ? requestsResult.left
            : (ordersResult.isLeft ? ordersResult.left : null),
      ),
    );
  }

  void _onSegmentChanged(
    OrdersSegmentChanged event,
    Emitter<OrdersState> emit,
  ) {
    emit(state.copyWith(segment: event.segment));
  }

  Future<void> _onOfferSent(
    OrderOfferSent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(actionStatus: Statuses.loading, failure: null));

    final result = await _repository.sendOffer(
      requestId: event.requestId,
      note: event.note,
    );

    if (result.isLeft) {
      emit(
        state.copyWith(actionStatus: Statuses.failure, failure: result.left),
      );
      return;
    }

    emit(
      state.copyWith(
        actionStatus: Statuses.success,
        requests: [
          for (final request in state.requests)
            if (request.id == event.requestId)
              request.copyWith(offerSent: true)
            else
              request,
        ],
      ),
    );
  }

  Future<void> _onRequestDeclined(
    OrderRequestDeclined event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(actionStatus: Statuses.loading, failure: null));

    final result = await _repository.declineRequest(
      event.requestId,
      invited: event.invited,
      reason: event.reason,
    );

    emit(
      result.isRight
          ? state.copyWith(
              actionStatus: Statuses.success,
              requests: state.requests
                  .where((request) => request.id != event.requestId)
                  .toList(),
            )
          : state.copyWith(
              actionStatus: Statuses.failure,
              failure: result.left,
            ),
    );
  }

  Future<void> _onStageCompleted(
    OrderStageCompleted event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(actionStatus: Statuses.loading, failure: null));

    final result = await _repository.completeStage(event.orderId);
    if (result.isLeft) {
      emit(
        state.copyWith(actionStatus: Statuses.failure, failure: result.left),
      );
      return;
    }

    final updated = result.right;
    emit(
      state.copyWith(
        actionStatus: Statuses.success,
        orders: [
          for (final order in state.orders)
            if (order.id == updated.id) updated else order,
        ],
      ),
    );
  }

  Future<void> _onOwnStatusChanged(
    OwnOrderStatusChanged event,
    Emitter<OrdersState> emit,
  ) async {
    final id = OwnOrderMapper.serverIdOf(event.orderId);
    final repository = _ownRepository;
    if (id == null || repository == null) {
      emit(
        state.copyWith(
          actionStatus: Statuses.failure,
          failure: ParsingFailure(t.ownOrders.cannotChange),
        ),
      );
      return;
    }

    final previous = state.orders;
    emit(
      state.copyWith(
        actionStatus: Statuses.loading,
        failure: null,
        orders: [
          for (final order in previous)
            if (order.id == event.orderId)
              order.copyWith(
                ownStatus: event.status,
                stage: OwnOrderMapper.stageFor(event.status),
                completedAt: event.status.isClosed ? DateTime.now() : null,
                clearCompletedAt: !event.status.isClosed,
              )
            else
              order,
        ],
      ),
    );

    final result = await repository.setStatus(id, event.status);
    if (result.isLeft) {
      emit(
        state.copyWith(
          actionStatus: Statuses.failure,
          failure: result.left,
          orders: previous,
        ),
      );
      return;
    }

    final updated = OwnOrderMapper.toMasterOrder(result.right);
    emit(
      state.copyWith(
        actionStatus: Statuses.success,
        orders: [
          for (final order in state.orders)
            if (order.id == updated.id) updated else order,
        ],
      ),
    );
  }
}
