// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/exports/main_export.dart';

class GMap {
  static Future<List<PropertyModel>> getNearByProperty(
    String city,
    String latitude,
    String longitude,
  ) async {
    try {
      final response = await Api.get(
        url: Api.getNearByProperties,
        queryParameters: {
          'city': city,
          'latitude': latitude,
          'longitude': longitude,
        },
        useAuthToken: false,
      );
      response.mlog('City response');
      final points = (response['data'] as List).map((e) {
        return PropertyModel.fromMap(e as Map<String, dynamic>? ?? {});
      }).toList();
      return points;
    } catch (e) {
      rethrow;
    }
  }
}

// class MapPoint {
//   final String price;
//   final String latitude;
//   final String longitude;
//   final int propertyId;
//   final String propertyType;
//   final String addedBy;
//   MapPoint({
//     required this.price,
//     required this.latitude,
//     required this.longitude,
//     required this.propertyId,
//     required this.propertyType,
//     required this.addedBy,
//   });

//   @override
//   String toString() {
//     return 'MapPoint(price: $price, latitude: $latitude, longitude: $longitude, propertyId: $propertyId, propertyType: $propertyType)';
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'price': price,
//       'latitude': latitude,
//       'longitude': longitude,
//       'id': propertyId,
//       'property_type': propertyType,
//     };
//   }

//   factory MapPoint.fromMap(Map<String, dynamic> map) {
//     return MapPoint(
//       price: map['price'].toString(),
//       latitude: map['latitude'].toString(),
//       longitude: map['longitude'].toString(),
//       propertyId: map['id'] as int,
//       propertyType: map['property_type'].toString(),
//       addedBy: map['added_by'].toString(),
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory MapPoint.fromJson(String source) =>
//       MapPoint.fromMap(json.decode(source) as Map<String, dynamic>);
// }
