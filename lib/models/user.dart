import 'package:freezed_annotation/freezed_annotation.dart';
import 'location.dart';
import 'transportation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  factory User({
    required String id,
    required String name,
    String? profileImageUrl,  // profileImage를 profileImageUrl로 변경
    Location? location,
    @Default(TransportationType.car) TransportationType transportType,
    @Default(false) bool isLocationSelected,  // 위치 선택 여부 추가
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}