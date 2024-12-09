// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MeetingPoint _$MeetingPointFromJson(Map<String, dynamic> json) {
  return _MeetingPoint.fromJson(json);
}

/// @nodoc
mixin _$MeetingPoint {
  Location get location => throw _privateConstructorUsedError;
  List<Place> get nearbyPlaces => throw _privateConstructorUsedError;
  Map<String, Duration> get travelTimes => throw _privateConstructorUsedError;
  bool get isCalculated => throw _privateConstructorUsedError;

  /// Serializes this MeetingPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeetingPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingPointCopyWith<MeetingPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingPointCopyWith<$Res> {
  factory $MeetingPointCopyWith(
          MeetingPoint value, $Res Function(MeetingPoint) then) =
      _$MeetingPointCopyWithImpl<$Res, MeetingPoint>;
  @useResult
  $Res call(
      {Location location,
      List<Place> nearbyPlaces,
      Map<String, Duration> travelTimes,
      bool isCalculated});

  $LocationCopyWith<$Res> get location;
}

/// @nodoc
class _$MeetingPointCopyWithImpl<$Res, $Val extends MeetingPoint>
    implements $MeetingPointCopyWith<$Res> {
  _$MeetingPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetingPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = null,
    Object? nearbyPlaces = null,
    Object? travelTimes = null,
    Object? isCalculated = null,
  }) {
    return _then(_value.copyWith(
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location,
      nearbyPlaces: null == nearbyPlaces
          ? _value.nearbyPlaces
          : nearbyPlaces // ignore: cast_nullable_to_non_nullable
              as List<Place>,
      travelTimes: null == travelTimes
          ? _value.travelTimes
          : travelTimes // ignore: cast_nullable_to_non_nullable
              as Map<String, Duration>,
      isCalculated: null == isCalculated
          ? _value.isCalculated
          : isCalculated // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of MeetingPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res> get location {
    return $LocationCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MeetingPointImplCopyWith<$Res>
    implements $MeetingPointCopyWith<$Res> {
  factory _$$MeetingPointImplCopyWith(
          _$MeetingPointImpl value, $Res Function(_$MeetingPointImpl) then) =
      __$$MeetingPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Location location,
      List<Place> nearbyPlaces,
      Map<String, Duration> travelTimes,
      bool isCalculated});

  @override
  $LocationCopyWith<$Res> get location;
}

/// @nodoc
class __$$MeetingPointImplCopyWithImpl<$Res>
    extends _$MeetingPointCopyWithImpl<$Res, _$MeetingPointImpl>
    implements _$$MeetingPointImplCopyWith<$Res> {
  __$$MeetingPointImplCopyWithImpl(
      _$MeetingPointImpl _value, $Res Function(_$MeetingPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetingPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = null,
    Object? nearbyPlaces = null,
    Object? travelTimes = null,
    Object? isCalculated = null,
  }) {
    return _then(_$MeetingPointImpl(
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location,
      nearbyPlaces: null == nearbyPlaces
          ? _value._nearbyPlaces
          : nearbyPlaces // ignore: cast_nullable_to_non_nullable
              as List<Place>,
      travelTimes: null == travelTimes
          ? _value._travelTimes
          : travelTimes // ignore: cast_nullable_to_non_nullable
              as Map<String, Duration>,
      isCalculated: null == isCalculated
          ? _value.isCalculated
          : isCalculated // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetingPointImpl implements _MeetingPoint {
  _$MeetingPointImpl(
      {required this.location,
      required final List<Place> nearbyPlaces,
      required final Map<String, Duration> travelTimes,
      this.isCalculated = false})
      : _nearbyPlaces = nearbyPlaces,
        _travelTimes = travelTimes;

  factory _$MeetingPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetingPointImplFromJson(json);

  @override
  final Location location;
  final List<Place> _nearbyPlaces;
  @override
  List<Place> get nearbyPlaces {
    if (_nearbyPlaces is EqualUnmodifiableListView) return _nearbyPlaces;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nearbyPlaces);
  }

  final Map<String, Duration> _travelTimes;
  @override
  Map<String, Duration> get travelTimes {
    if (_travelTimes is EqualUnmodifiableMapView) return _travelTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_travelTimes);
  }

  @override
  @JsonKey()
  final bool isCalculated;

  @override
  String toString() {
    return 'MeetingPoint(location: $location, nearbyPlaces: $nearbyPlaces, travelTimes: $travelTimes, isCalculated: $isCalculated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingPointImpl &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other._nearbyPlaces, _nearbyPlaces) &&
            const DeepCollectionEquality()
                .equals(other._travelTimes, _travelTimes) &&
            (identical(other.isCalculated, isCalculated) ||
                other.isCalculated == isCalculated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      location,
      const DeepCollectionEquality().hash(_nearbyPlaces),
      const DeepCollectionEquality().hash(_travelTimes),
      isCalculated);

  /// Create a copy of MeetingPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingPointImplCopyWith<_$MeetingPointImpl> get copyWith =>
      __$$MeetingPointImplCopyWithImpl<_$MeetingPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetingPointImplToJson(
      this,
    );
  }
}

abstract class _MeetingPoint implements MeetingPoint {
  factory _MeetingPoint(
      {required final Location location,
      required final List<Place> nearbyPlaces,
      required final Map<String, Duration> travelTimes,
      final bool isCalculated}) = _$MeetingPointImpl;

  factory _MeetingPoint.fromJson(Map<String, dynamic> json) =
      _$MeetingPointImpl.fromJson;

  @override
  Location get location;
  @override
  List<Place> get nearbyPlaces;
  @override
  Map<String, Duration> get travelTimes;
  @override
  bool get isCalculated;

  /// Create a copy of MeetingPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingPointImplCopyWith<_$MeetingPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
