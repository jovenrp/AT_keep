// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'application_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$ApplicationStateTearOff {
  const _$ApplicationStateTearOff();

  _ApplicationState call(
      {String deviceNotificationToken = '', bool isNetworkError = false}) {
    return _ApplicationState(
      deviceNotificationToken: deviceNotificationToken,
      isNetworkError: isNetworkError,
    );
  }
}

/// @nodoc
const $ApplicationState = _$ApplicationStateTearOff();

/// @nodoc
mixin _$ApplicationState {
  String get deviceNotificationToken => throw _privateConstructorUsedError;
  bool get isNetworkError => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ApplicationStateCopyWith<ApplicationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApplicationStateCopyWith<$Res> {
  factory $ApplicationStateCopyWith(
          ApplicationState value, $Res Function(ApplicationState) then) =
      _$ApplicationStateCopyWithImpl<$Res>;
  $Res call({String deviceNotificationToken, bool isNetworkError});
}

/// @nodoc
class _$ApplicationStateCopyWithImpl<$Res>
    implements $ApplicationStateCopyWith<$Res> {
  _$ApplicationStateCopyWithImpl(this._value, this._then);

  final ApplicationState _value;
  // ignore: unused_field
  final $Res Function(ApplicationState) _then;

  @override
  $Res call({
    Object? deviceNotificationToken = freezed,
    Object? isNetworkError = freezed,
  }) {
    return _then(_value.copyWith(
      deviceNotificationToken: deviceNotificationToken == freezed
          ? _value.deviceNotificationToken
          : deviceNotificationToken // ignore: cast_nullable_to_non_nullable
              as String,
      isNetworkError: isNetworkError == freezed
          ? _value.isNetworkError
          : isNetworkError // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$ApplicationStateCopyWith<$Res>
    implements $ApplicationStateCopyWith<$Res> {
  factory _$ApplicationStateCopyWith(
          _ApplicationState value, $Res Function(_ApplicationState) then) =
      __$ApplicationStateCopyWithImpl<$Res>;
  @override
  $Res call({String deviceNotificationToken, bool isNetworkError});
}

/// @nodoc
class __$ApplicationStateCopyWithImpl<$Res>
    extends _$ApplicationStateCopyWithImpl<$Res>
    implements _$ApplicationStateCopyWith<$Res> {
  __$ApplicationStateCopyWithImpl(
      _ApplicationState _value, $Res Function(_ApplicationState) _then)
      : super(_value, (v) => _then(v as _ApplicationState));

  @override
  _ApplicationState get _value => super._value as _ApplicationState;

  @override
  $Res call({
    Object? deviceNotificationToken = freezed,
    Object? isNetworkError = freezed,
  }) {
    return _then(_ApplicationState(
      deviceNotificationToken: deviceNotificationToken == freezed
          ? _value.deviceNotificationToken
          : deviceNotificationToken // ignore: cast_nullable_to_non_nullable
              as String,
      isNetworkError: isNetworkError == freezed
          ? _value.isNetworkError
          : isNetworkError // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_ApplicationState implements _ApplicationState {
  _$_ApplicationState(
      {this.deviceNotificationToken = '', this.isNetworkError = false});

  @JsonKey(defaultValue: '')
  @override
  final String deviceNotificationToken;
  @JsonKey(defaultValue: false)
  @override
  final bool isNetworkError;

  @override
  String toString() {
    return 'ApplicationState(deviceNotificationToken: $deviceNotificationToken, isNetworkError: $isNetworkError)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ApplicationState &&
            (identical(
                    other.deviceNotificationToken, deviceNotificationToken) ||
                const DeepCollectionEquality().equals(
                    other.deviceNotificationToken, deviceNotificationToken)) &&
            (identical(other.isNetworkError, isNetworkError) ||
                const DeepCollectionEquality()
                    .equals(other.isNetworkError, isNetworkError)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(deviceNotificationToken) ^
      const DeepCollectionEquality().hash(isNetworkError);

  @JsonKey(ignore: true)
  @override
  _$ApplicationStateCopyWith<_ApplicationState> get copyWith =>
      __$ApplicationStateCopyWithImpl<_ApplicationState>(this, _$identity);
}

abstract class _ApplicationState implements ApplicationState {
  factory _ApplicationState(
      {String deviceNotificationToken,
      bool isNetworkError}) = _$_ApplicationState;

  @override
  String get deviceNotificationToken => throw _privateConstructorUsedError;
  @override
  bool get isNetworkError => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$ApplicationStateCopyWith<_ApplicationState> get copyWith =>
      throw _privateConstructorUsedError;
}
