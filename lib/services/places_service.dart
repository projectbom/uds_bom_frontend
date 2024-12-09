import 'dart:js' as js;
import '../models/location.dart';
import '../models/place.dart';

class PlacesService {
  Future<Place> getPlaceDetails(String placeId) async {
    try {
      final service = js.context['google']['maps']['places']['PlacesService'](js.context['map']);
      final request = {
        'placeId': placeId,
        'fields': [
          'name',
          'geometry',
          'formatted_address',
          'rating',
          'user_ratings_total',
          'price_level',
          'photos',
          'types'
        ]
      };

      final result = await js.context.callMethod('getPlaceDetails', [service, request]);
      
      return Place(
        id: placeId,
        name: result['name'],
        location: Location(
          latitude: result['geometry']['location']['lat'],
          longitude: result['geometry']['location']['lng'],
          address: result['formatted_address'],
        ),
        rating: result['rating']?.toDouble() ?? 0.0,
        userRatingsTotal: result['user_ratings_total'] ?? 0,
        priceLevel: result['price_level']?.toInt() ?? 0,
        imageUrl: _getPlacePhotoUrl(result),
        address: result['formatted_address'],
        type: result['types']?[0] ?? '',
      );
    } catch (e) {
      throw Exception('장소 상세 정보 오류: $e');
    }
  }

  Future<List<Place>> searchNearbyPlaces(
    Location location, {
    String? type,
    int radius = 1500,
  }) async {
    try {
      final service = js.context['google']['maps']['places']['PlacesService'](js.context['map']);
      final request = {
        'location': {'lat': location.latitude, 'lng': location.longitude},
        'radius': radius,
        'type': type,
        'language': 'ko',
        'rankBy': js.context['google']['maps']['places']['RankBy']['RATING']
      };

      final results = await js.context.callMethod('searchNearbyPlaces', [service, request]);
      
      if (results != null) {
        return List<Place>.from(results.map((place) => Place(
          id: place['place_id'],
          name: place['name'],
          location: Location(
            latitude: place['geometry']['location']['lat'],
            longitude: place['geometry']['location']['lng'],
            address: place['vicinity'] ?? '',
          ),
          rating: place['rating']?.toDouble() ?? 0.0,
          userRatingsTotal: place['user_ratings_total'] ?? 0,
          priceLevel: place['price_level']?.toInt() ?? 0,
          imageUrl: _getPlacePhotoUrl(place),
          address: place['vicinity'] ?? '',
          type: place['types']?[0] ?? '',
        )));
      }
      return [];
    } catch (e) {
      throw Exception('주변 장소 검색 오류: $e');
    }
  }

  String? _getPlacePhotoUrl(dynamic place) {
    if (place['photos'] != null && place['photos'].isNotEmpty) {
      return place['photos'][0]['getUrl']?.call() as String?;
    }
    return null;
  }
}