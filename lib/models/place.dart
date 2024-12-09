import 'package:freezed_annotation/freezed_annotation.dart';
import 'location.dart';

part 'place.freezed.dart';
part 'place.g.dart';

@freezed
class Place with _$Place {
  factory Place({
    required String id,
    required String name,
    required String type,
    required Location location,
    required double rating,
    String? imageUrl,
    required String address,
    double? distance,
    @Default(0) int userRatingsTotal,
    @Default(0) int priceLevel,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}

enum PlaceType {
  restaurant,
  cafe,
  bar,
  park,
  all
}

extension PlaceTypeExtension on PlaceType {
  String get value {
    switch (this) {
      case PlaceType.restaurant:
        return 'restaurant';
      case PlaceType.cafe:
        return 'cafe';
      case PlaceType.bar:
        return 'bar';
      case PlaceType.park:
        return 'park';
      case PlaceType.all:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case PlaceType.restaurant:
        return '음식점';
      case PlaceType.cafe:
        return '카페';
      case PlaceType.bar:
        return '술집';
      case PlaceType.park:
        return '공원';
      case PlaceType.all:
        return '전체';
    }
  }
}