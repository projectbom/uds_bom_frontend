// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceImpl _$$PlaceImplFromJson(Map<String, dynamic> json) => _$PlaceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      address: json['address'] as String,
      distance: (json['distance'] as num?)?.toDouble(),
      userRatingsTotal: (json['userRatingsTotal'] as num?)?.toInt() ?? 0,
      priceLevel: (json['priceLevel'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PlaceImplToJson(_$PlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'location': instance.location,
      'rating': instance.rating,
      'imageUrl': instance.imageUrl,
      'address': instance.address,
      'distance': instance.distance,
      'userRatingsTotal': instance.userRatingsTotal,
      'priceLevel': instance.priceLevel,
    };
