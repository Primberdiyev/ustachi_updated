
part of 'auth_bloc.dart';

T _$identity<T>(T value) => value;

mixin _$AuthState {
  Statuses get sendCodeStatus;
  Statuses get resendCodeStatus;
  Statuses get verifyCodeStatus;
  Statuses get updateProfileStatus;
  Failure? get failure;

  String get phoneNumber;

  bool get isNewUser;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthStateCopyWith<AuthState> get copyWith =>
      _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthState &&
            (identical(other.sendCodeStatus, sendCodeStatus) ||
                other.sendCodeStatus == sendCodeStatus) &&
            (identical(other.resendCodeStatus, resendCodeStatus) ||
                other.resendCodeStatus == resendCodeStatus) &&
            (identical(other.verifyCodeStatus, verifyCodeStatus) ||
                other.verifyCodeStatus == verifyCodeStatus) &&
            (identical(other.updateProfileStatus, updateProfileStatus) ||
                other.updateProfileStatus == updateProfileStatus) &&
            (identical(other.failure, failure) || other.failure == failure) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sendCodeStatus, resendCodeStatus,
      verifyCodeStatus, updateProfileStatus, failure, phoneNumber, isNewUser);

  @override
  String toString() {
    return 'AuthState(sendCodeStatus: $sendCodeStatus, resendCodeStatus: $resendCodeStatus, verifyCodeStatus: $verifyCodeStatus, updateProfileStatus: $updateProfileStatus, failure: $failure, phoneNumber: $phoneNumber, isNewUser: $isNewUser)';
  }
}

abstract mixin class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) =
      _$AuthStateCopyWithImpl;
  @useResult
  $Res call(
      {Statuses sendCodeStatus,
      Statuses resendCodeStatus,
      Statuses verifyCodeStatus,
      Statuses updateProfileStatus,
      Failure? failure,
      String phoneNumber,
      bool isNewUser});
}

class _$AuthStateCopyWithImpl<$Res> implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sendCodeStatus = null,
    Object? resendCodeStatus = null,
    Object? verifyCodeStatus = null,
    Object? updateProfileStatus = null,
    Object? failure = freezed,
    Object? phoneNumber = null,
    Object? isNewUser = null,
  }) {
    return _then(_self.copyWith(
      sendCodeStatus: null == sendCodeStatus
          ? _self.sendCodeStatus
          : sendCodeStatus 
              as Statuses,
      resendCodeStatus: null == resendCodeStatus
          ? _self.resendCodeStatus
          : resendCodeStatus 
              as Statuses,
      verifyCodeStatus: null == verifyCodeStatus
          ? _self.verifyCodeStatus
          : verifyCodeStatus 
              as Statuses,
      updateProfileStatus: null == updateProfileStatus
          ? _self.updateProfileStatus
          : updateProfileStatus 
              as Statuses,
      failure: freezed == failure
          ? _self.failure
          : failure 
              as Failure?,
      phoneNumber: null == phoneNumber
          ? _self.phoneNumber
          : phoneNumber 
              as String,
      isNewUser: null == isNewUser
          ? _self.isNewUser
          : isNewUser 
              as bool,
    ));
  }
}

extension AuthStatePatterns on AuthState {

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AuthState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AuthState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AuthState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            Statuses sendCodeStatus,
            Statuses resendCodeStatus,
            Statuses verifyCodeStatus,
            Statuses updateProfileStatus,
            Failure? failure,
            String phoneNumber,
            bool isNewUser)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthState() when $default != null:
        return $default(
            _that.sendCodeStatus,
            _that.resendCodeStatus,
            _that.verifyCodeStatus,
            _that.updateProfileStatus,
            _that.failure,
            _that.phoneNumber,
            _that.isNewUser);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            Statuses sendCodeStatus,
            Statuses resendCodeStatus,
            Statuses verifyCodeStatus,
            Statuses updateProfileStatus,
            Failure? failure,
            String phoneNumber,
            bool isNewUser)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthState():
        return $default(
            _that.sendCodeStatus,
            _that.resendCodeStatus,
            _that.verifyCodeStatus,
            _that.updateProfileStatus,
            _that.failure,
            _that.phoneNumber,
            _that.isNewUser);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            Statuses sendCodeStatus,
            Statuses resendCodeStatus,
            Statuses verifyCodeStatus,
            Statuses updateProfileStatus,
            Failure? failure,
            String phoneNumber,
            bool isNewUser)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthState() when $default != null:
        return $default(
            _that.sendCodeStatus,
            _that.resendCodeStatus,
            _that.verifyCodeStatus,
            _that.updateProfileStatus,
            _that.failure,
            _that.phoneNumber,
            _that.isNewUser);
      case _:
        return null;
    }
  }
}

class _AuthState implements AuthState {
  const _AuthState(
      {this.sendCodeStatus = Statuses.initial,
      this.resendCodeStatus = Statuses.initial,
      this.verifyCodeStatus = Statuses.initial,
      this.updateProfileStatus = Statuses.initial,
      this.failure,
      this.phoneNumber = '',
      this.isNewUser = false});

  @override
  @JsonKey()
  final Statuses sendCodeStatus;
  @override
  @JsonKey()
  final Statuses resendCodeStatus;
  @override
  @JsonKey()
  final Statuses verifyCodeStatus;
  @override
  @JsonKey()
  final Statuses updateProfileStatus;
  @override
  final Failure? failure;

  @override
  @JsonKey()
  final String phoneNumber;

  @override
  @JsonKey()
  final bool isNewUser;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthStateCopyWith<_AuthState> get copyWith =>
      __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthState &&
            (identical(other.sendCodeStatus, sendCodeStatus) ||
                other.sendCodeStatus == sendCodeStatus) &&
            (identical(other.resendCodeStatus, resendCodeStatus) ||
                other.resendCodeStatus == resendCodeStatus) &&
            (identical(other.verifyCodeStatus, verifyCodeStatus) ||
                other.verifyCodeStatus == verifyCodeStatus) &&
            (identical(other.updateProfileStatus, updateProfileStatus) ||
                other.updateProfileStatus == updateProfileStatus) &&
            (identical(other.failure, failure) || other.failure == failure) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sendCodeStatus, resendCodeStatus,
      verifyCodeStatus, updateProfileStatus, failure, phoneNumber, isNewUser);

  @override
  String toString() {
    return 'AuthState(sendCodeStatus: $sendCodeStatus, resendCodeStatus: $resendCodeStatus, verifyCodeStatus: $verifyCodeStatus, updateProfileStatus: $updateProfileStatus, failure: $failure, phoneNumber: $phoneNumber, isNewUser: $isNewUser)';
  }
}

abstract mixin class _$AuthStateCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(
          _AuthState value, $Res Function(_AuthState) _then) =
      __$AuthStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Statuses sendCodeStatus,
      Statuses resendCodeStatus,
      Statuses verifyCodeStatus,
      Statuses updateProfileStatus,
      Failure? failure,
      String phoneNumber,
      bool isNewUser});
}

class __$AuthStateCopyWithImpl<$Res> implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sendCodeStatus = null,
    Object? resendCodeStatus = null,
    Object? verifyCodeStatus = null,
    Object? updateProfileStatus = null,
    Object? failure = freezed,
    Object? phoneNumber = null,
    Object? isNewUser = null,
  }) {
    return _then(_AuthState(
      sendCodeStatus: null == sendCodeStatus
          ? _self.sendCodeStatus
          : sendCodeStatus 
              as Statuses,
      resendCodeStatus: null == resendCodeStatus
          ? _self.resendCodeStatus
          : resendCodeStatus 
              as Statuses,
      verifyCodeStatus: null == verifyCodeStatus
          ? _self.verifyCodeStatus
          : verifyCodeStatus 
              as Statuses,
      updateProfileStatus: null == updateProfileStatus
          ? _self.updateProfileStatus
          : updateProfileStatus 
              as Statuses,
      failure: freezed == failure
          ? _self.failure
          : failure 
              as Failure?,
      phoneNumber: null == phoneNumber
          ? _self.phoneNumber
          : phoneNumber 
              as String,
      isNewUser: null == isNewUser
          ? _self.isNewUser
          : isNewUser 
              as bool,
    ));
  }
}
