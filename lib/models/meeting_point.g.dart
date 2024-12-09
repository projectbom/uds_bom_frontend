// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeetingPointImpl _$$MeetingPointImplFromJson(Map<String, dynamic> json) =>
    _$MeetingPointImpl(
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      nearbyPlaces: (json['nearbyPlaces'] as List<dynamic>)
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList(),
      travelTimes: (json['travelTimes'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Duration(microseconds: (e as num).toInt())),
      ),
      isCalculated: json['isCalculated'] as bool? ?? false,
    );

Map<String, dynamic> _$$MeetingPointImplToJson(_$MeetingPointImpl instance) =>
    <String, dynamic>{
      'location': instance.location,
      'nearbyPlaces': instance.nearbyPlaces,
      'travelTimes':
          instance.travelTimes.map((k, e) => MapEntry(k, e.inMicroseconds)),
      'isCalculated': instance.isCalculated,
    };
