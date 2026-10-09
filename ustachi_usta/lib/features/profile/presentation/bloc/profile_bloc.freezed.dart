
part of 'profile_bloc.dart';

T _$identity<T>(T value) => value;

mixin _$ProfileState {
  Statuses get getUserDataStatus;
  UserModel? get userModel;
  Failure? get failure;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      _$ProfileStateCopyWithImpl<ProfileState>(
          this as ProfileState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileState &&
            (identical(other.getUserDataStatus, getUserDataStatus) ||
                other.getUserDataStatus == getUserDataStatus) &&
            (identical(other.userModel, userModel) ||
                other.userModel == userModel) &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, getUserDataStatus, userModel, failure);

  @override
  String toString() {
    return 'ProfileState(getUserDataStatus: $getUserDataStatus, userModel: $userModel, failure: $failure)';
  }
}

abstract mixin class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) _then) =
      _$ProfileStateCopyWithImpl;
  @useResult
  $Res call(
      {Statuses getUserDataStatus, UserModel? userModel, Failure? failure});
}

class _$ProfileStateCopyWithImpl<$Res> implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? getUserDataStatus = null,
    Object? userModel = freezed,
    Object? failure = freezed,
  }) {
    return _then(_self.copyWith(
      getUserDataStatus: null == getUserDataStatus
          ? _self.getUserDataStatus
          : getUserDataStatus 
              as Statuses,
      userModel: freezed == userModel
          ? _self.userModel
          : userModel 
              as UserModel?,
      failure: freezed == failure
          ? _self.failure
          : failure 
              as Failure?,
    ));
  }
}

extension ProfileStatePatterns on ProfileState {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProfileState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProfileState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProfileState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            Statuses getUserDataStatus, UserModel? userModel, Failure? failure)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
        return $default(
            _that.getUserDataStatus, _that.userModel, _that.failure);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            Statuses getUserDataStatus, UserModel? userModel, Failure? failure)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState():
        return $default(
            _that.getUserDataStatus, _that.userModel, _that.failure);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            Statuses getUserDataStatus, UserModel? userModel, Failure? failure)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
        return $default(
            _that.getUserDataStatus, _that.userModel, _that.failure);
      case _:
        return null;
    }
  }
}

class _ProfileState implements ProfileState {
  const _ProfileState(
      {this.getUserDataStatus = Statuses.initial,
      this.userModel,
      this.failure});

  @override
  @JsonKey()
  final Statuses getUserDataStatus;
  @override
  final UserModel? userModel;
  @override
  final Failure? failure;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileStateCopyWith<_ProfileState> get copyWith =>
      __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileState &&
            (identical(other.getUserDataStatus, getUserDataStatus) ||
                other.getUserDataStatus == getUserDataStatus) &&
            (identical(other.userModel, userModel) ||
                other.userModel == userModel) &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, getUserDataStatus, userModel, failure);

  @override
  String toString() {
    return 'ProfileState(getUserDataStatus: $getUserDataStatus, userModel: $userModel, failure: $failure)';
  }
}

abstract mixin class _$ProfileStateCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(
          _ProfileState value, $Res Function(_ProfileState) _then) =
      __$ProfileStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Statuses getUserDataStatus, UserModel? userModel, Failure? failure});
}

class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? getUserDataStatus = null,
    Object? userModel = freezed,
    Object? failure = freezed,
  }) {
    return _then(_ProfileState(
      getUserDataStatus: null == getUserDataStatus
          ? _self.getUserDataStatus
          : getUserDataStatus 
              as Statuses,
      userModel: freezed == userModel
          ? _self.userModel
          : userModel 
              as UserModel?,
      failure: freezed == failure
          ? _self.failure
          : failure 
              as Failure?,
    ));
  }
}
