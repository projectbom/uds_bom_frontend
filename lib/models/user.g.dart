// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      transportType: $enumDecodeNullable(
              _$TransportationTypeEnumMap, json['transportType']) ??
          TransportationType.car,
      isLocationSelected: json['isLocationSelected'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profileImageUrl': instance.profileImageUrl,
      'location': instance.location,
      'transportType': _$TransportationTypeEnumMap[instance.transportType]!,
      'isLocationSelected': instance.isLocationSelected,
    };

const _$TransportationTypeEnumMap = {
  TransportationType.public: 'public',
  TransportationType.car: 'car',
};
