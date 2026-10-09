
part of 'orders_bloc.dart';

T _$identity<T>(T value) => value;

mixin _$OrdersState {
  Statuses get loadStatus;

  Statuses get actionStatus;
  OrdersSegment get segment;
  List<OrderRequestEntity> get requests;
  List<MasterOrderEntity> get orders;
  Failure? get failure;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OrdersStateCopyWith<OrdersState> get copyWith =>
      _$OrdersStateCopyWithImpl<OrdersState>(this as OrdersState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OrdersState &&
            (identical(other.loadStatus, loadStatus) ||
                other.loadStatus == loadStatus) &&
            (identical(other.actionStatus, actionStatus) ||
                other.actionStatus == actionStatus) &&
            (identical(other.segment, segment) || other.segment == segment) &&
            const DeepCollectionEquality().equals(other.requests, requests) &&
            const DeepCollectionEquality().equals(other.orders, orders) &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      loadStatus,
      actionStatus,
      segment,
      const DeepCollectionEquality().hash(requests),
      const DeepCollectionEquality().hash(orders),
      failure);

  @override
  String toString() {
    return 'OrdersState(loadStatus: $loadStatus, actionStatus: $actionStatus, segment: $segment, requests: $requests, orders: $orders, failure: $failure)';
  }
}

abstract mixin class $OrdersStateCopyWith<$Res> {
  factory $OrdersStateCopyWith(
          OrdersState value, $Res Function(OrdersState) _then) =
      _$OrdersStateCopyWithImpl;
  @useResult
  $Res call(
      {Statuses loadStatus,
      Statuses actionStatus,
      OrdersSegment segment,
      List<OrderRequestEntity> requests,
      List<MasterOrderEntity> orders,
      Failure? failure});
}

class _$OrdersStateCopyWithImpl<$Res> implements $OrdersStateCopyWith<$Res> {
  _$OrdersStateCopyWithImpl(this._self, this._then);

  final OrdersState _self;
  final $Res Function(OrdersState) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loadStatus = null,
    Object? actionStatus = null,
    Object? segment = null,
    Object? requests = null,
    Object? orders = null,
    Object? failure = freezed,
  }) {
    return _then(_self.copyWith(
      loadStatus: null == loadStatus
          ? _self.loadStatus
          : loadStatus 
              as Statuses,
      actionStatus: null == actionStatus
          ? _self.actionStatus
          : actionStatus 
              as Statuses,
      segment: null == segment
          ? _self.segment
          : segment 
              as OrdersSegment,
      requests: null == requests
          ? _self.requests
          : requests 
              as List<OrderRequestEntity>,
      orders: null == orders
          ? _self.orders
          : orders 
              as List<MasterOrderEntity>,
      failure: freezed == failure
          ? _self.failure
          : failure 
              as Failure?,
    ));
  }
}

extension OrdersStatePatterns on OrdersState {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OrdersState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrdersState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OrdersState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrdersState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OrdersState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrdersState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            Statuses loadStatus,
            Statuses actionStatus,
            OrdersSegment segment,
            List<OrderRequestEntity> requests,
            List<MasterOrderEntity> orders,
            Failure? failure)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrdersState() when $default != null:
        return $default(_that.loadStatus, _that.actionStatus, _that.segment,
            _that.requests, _that.orders, _that.failure);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            Statuses loadStatus,
            Statuses actionStatus,
            OrdersSegment segment,
            List<OrderRequestEntity> requests,
            List<MasterOrderEntity> orders,
            Failure? failure)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrdersState():
        return $default(_that.loadStatus, _that.actionStatus, _that.segment,
            _that.requests, _that.orders, _that.failure);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            Statuses loadStatus,
            Statuses actionStatus,
            OrdersSegment segment,
            List<OrderRequestEntity> requests,
            List<MasterOrderEntity> orders,
            Failure? failure)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrdersState() when $default != null:
        return $default(_that.loadStatus, _that.actionStatus, _that.segment,
            _that.requests, _that.orders, _that.failure);
      case _:
        return null;
    }
  }
}

class _OrdersState extends OrdersState {
  const _OrdersState(
      {this.loadStatus = Statuses.initial,
      this.actionStatus = Statuses.initial,
      this.segment = OrdersSegment.fresh,
      final List<OrderRequestEntity> requests = const <OrderRequestEntity>[],
      final List<MasterOrderEntity> orders = const <MasterOrderEntity>[],
      this.failure})
      : _requests = requests,
        _orders = orders,
        super._();

  @override
  @JsonKey()
  final Statuses loadStatus;

  @override
  @JsonKey()
  final Statuses actionStatus;
  @override
  @JsonKey()
  final OrdersSegment segment;
  final List<OrderRequestEntity> _requests;
  @override
  @JsonKey()
  List<OrderRequestEntity> get requests {
    if (_requests is EqualUnmodifiableListView) return _requests;
    return EqualUnmodifiableListView(_requests);
  }

  final List<MasterOrderEntity> _orders;
  @override
  @JsonKey()
  List<MasterOrderEntity> get orders {
    if (_orders is EqualUnmodifiableListView) return _orders;
    return EqualUnmodifiableListView(_orders);
  }

  @override
  final Failure? failure;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OrdersStateCopyWith<_OrdersState> get copyWith =>
      __$OrdersStateCopyWithImpl<_OrdersState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OrdersState &&
            (identical(other.loadStatus, loadStatus) ||
                other.loadStatus == loadStatus) &&
            (identical(other.actionStatus, actionStatus) ||
                other.actionStatus == actionStatus) &&
            (identical(other.segment, segment) || other.segment == segment) &&
            const DeepCollectionEquality().equals(other._requests, _requests) &&
            const DeepCollectionEquality().equals(other._orders, _orders) &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      loadStatus,
      actionStatus,
      segment,
      const DeepCollectionEquality().hash(_requests),
      const DeepCollectionEquality().hash(_orders),
      failure);

  @override
  String toString() {
    return 'OrdersState(loadStatus: $loadStatus, actionStatus: $actionStatus, segment: $segment, requests: $requests, orders: $orders, failure: $failure)';
  }
}

abstract mixin class _$OrdersStateCopyWith<$Res>
    implements $OrdersStateCopyWith<$Res> {
  factory _$OrdersStateCopyWith(
          _OrdersState value, $Res Function(_OrdersState) _then) =
      __$OrdersStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Statuses loadStatus,
      Statuses actionStatus,
      OrdersSegment segment,
      List<OrderRequestEntity> requests,
      List<MasterOrderEntity> orders,
      Failure? failure});
}

class __$OrdersStateCopyWithImpl<$Res> implements _$OrdersStateCopyWith<$Res> {
  __$OrdersStateCopyWithImpl(this._self, this._then);

  final _OrdersState _self;
  final $Res Function(_OrdersState) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? loadStatus = null,
    Object? actionStatus = null,
    Object? segment = null,
    Object? requests = null,
    Object? orders = null,
    Object? failure = freezed,
  }) {
    return _then(_OrdersState(
      loadStatus: null == loadStatus
          ? _self.loadStatus
          : loadStatus 
              as Statuses,
      actionStatus: null == actionStatus
          ? _self.actionStatus
          : actionStatus 
              as Statuses,
      segment: null == segment
          ? _self.segment
          : segment 
              as OrdersSegment,
      requests: null == requests
          ? _self._requests
          : requests 
              as List<OrderRequestEntity>,
      orders: null == orders
          ? _self._orders
          : orders 
              as List<MasterOrderEntity>,
      failure: freezed == failure
          ? _self.failure
          : failure 
              as Failure?,
    ));
  }
}
