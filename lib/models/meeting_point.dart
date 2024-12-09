import 'package:freezed_annotation/freezed_annotation.dart';
import 'location.dart';
import 'place.dart';

part 'meeting_point.freezed.dart';
part 'meeting_point.g.dart';

@freezed
class MeetingPoint with _$MeetingPoint {
  factory MeetingPoint({
    required Location location,
    required List<Place> nearbyPlaces,
    required Map<String, Duration> travelTimes,
    @Default(false) bool isCalculated,
  }) = _MeetingPoint;

  factory MeetingPoint.fromJson(Map<String, dynamic> json) =>
      _$MeetingPointFromJson(json);
}