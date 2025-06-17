import 'dart:developer';

import 'package:ebroker/data/helper/filter.dart';
import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/model/compare_property_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PropertyRepository {
  ///This method will add property
  Future<dynamic> createProperty({
    required Map<String, dynamic> parameters,
  }) async {
    var api = Api.apiPostProperty;
    if (parameters['action_type'] == '0') {
      api = Api.apiUpdateProperty;

      if (parameters.containsKey('gallery_images')) {
        if ((parameters['gallery_images'] as List).isEmpty) {
          parameters.remove('gallery_images');
        }
      }
      if (parameters.containsKey('documents')) {
        if ((parameters['documents'] as List).isEmpty) {
          parameters.remove('documents');
        }
      }
      if (parameters['title_image'] == null ||
          parameters['title_image'] == '') {
        parameters.remove('title_image');
      }
      if (parameters['three_d_image'] == null ||
          parameters['three_d_image'] == '') {
        parameters.remove('three_d_image');
      }
    }

    return Api.post(url: api, parameter: parameters);
  }

  Future<PropertyModel> fetchPropertyFromPropertyId({
    required int id,
    required bool isMyProperty,
  }) async {
    try {
      final parameters = <String, dynamic>{
        Api.id: id,
        if (!isMyProperty) 'current_user': HiveUtils.getUserId(),
      };

      final response = await Api.get(
        url: isMyProperty ? Api.getAddedProperties : Api.apiGetPropertyDetails,
        queryParameters: parameters,
        useAuthToken: true,
      );
      if (response['error'] == true) {
        await Fluttertoast.showToast(msg: response['message'].toString());
        throw Exception(response['message'].toString());
      }

      final data = response['data'];

      // If data is a List, take the first item
      if (data is List && data.isNotEmpty) {
        return PropertyModel.fromMap(data.first as Map<String, dynamic>);
      }
      // If data is a Map
      else if (data is Map<String, dynamic>) {
        return PropertyModel.fromMap(data);
      }

      throw Exception('Invalid data format received from API');
    } catch (e) {
      log('Error is $e');
      await Fluttertoast.showToast(msg: e.toString());
    }
    return PropertyModel.fromMap({});
  }

  Future<void> deleteProperty(
    int id,
  ) async {
    await Api.post(
      url: Api.apiDeleteProperty,
      parameter: {Api.id: id},
    );
  }

  ///fetch most viewed properties
  Future<DataOutput<PropertyModel>> fetchMostViewedProperty({
    required int offset,
    required String latitude,
    required String longitude,
    required String radius,
  }) async {
    final parameters = <String, dynamic>{
      Api.mostViewed: '1',
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      Api.latitude: latitude,
      Api.longitude: longitude,
      Api.radius: radius,
    }..removeWhere((key, value) => value == null);

    try {
      final response = await Api.get(
        url: Api.apiGetPropertyList,
        queryParameters: parameters,
      );

      final modelList = (response['data'] as List)
          .cast<Map<String, dynamic>>()
          .map<PropertyModel>(PropertyModel.fromMap)
          .toList();
      return DataOutput(
        total: int.parse(response['total']?.toString() ?? '0'),
        modelList: modelList,
      );
    } catch (e) {
      rethrow;
    }
  }

  ///fetch advertised properties
  Future<DataOutput<PropertyModel>> fetchPromotedProperty({
    required int offset,
    required String latitude,
    required String longitude,
    required String radius,
    required bool sendCityName,
  }) async {
    ///
    final parameters = <String, dynamic>{
      Api.promoted: 1,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      'current_user': HiveUtils.getUserId(),
      Api.latitude: latitude,
      Api.longitude: longitude,
      Api.radius: radius,
    }..removeWhere((key, value) => value == null);

    final response = await Api.get(
      url: Api.apiGetPropertyList,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();

    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<DataOutput<PropertyModel>> fetchNearByProperty({
    required int offset,
    required String latitude,
    required String longitude,
    required String radius,
  }) async {
    try {
      if (HiveUtils.getCityName() == null ||
          HiveUtils.getCityName().toString().isEmpty) {
        return Future.value(
          DataOutput(
            total: 0,
            modelList: [],
          ),
        );
      }
      final result = await Api.get(
        url: Api.apiGetPropertyList,
        queryParameters: {
          'id': HiveUtils.getUserId(),
          'city': HiveUtils.getCityName(),
          Api.offset: offset,
          'limit': Constant.loadLimit,
          'current_user': HiveUtils.getUserId(),
          Api.latitude: latitude,
          Api.longitude: longitude,
          Api.radius: radius,
        }..removeWhere((key, value) => value == null),
      );

      final dataList = (result['data'] as List).map((e) {
        final data = e as Map<String, dynamic>?;

        return PropertyModel.fromMap(data ?? {});
      }).toList();

      return DataOutput<PropertyModel>(
        total: int.parse(result['total']?.toString() ?? '0'),
        modelList: dataList,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<PropertyModel>> fetchMostLikeProperty({
    required int offset,
    required String latitude,
    required String longitude,
    required String radius,
    required bool sendCityName,
  }) async {
    final parameters = <String, dynamic>{
      'most_liked': 1,
      'limit': Constant.loadLimit,
      'offset': offset,
      'current_user': HiveUtils.getUserId(),
      Api.latitude: latitude,
      Api.longitude: longitude,
      Api.radius: radius,
    }..removeWhere((key, value) => value == null);
    if (sendCityName) {}
    final response = await Api.get(
      url: Api.apiGetPropertyList,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List).map((e) {
      final data = e as Map<String, dynamic>?;
      return PropertyModel.fromMap(data ?? {});
    }).toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<DataOutput<AdvertisementProperty>> fetchMyPromotedProeprties({
    required int offset,
  }) async {
    try {
      final parameters = <String, dynamic>{
        Api.offset: offset,
        Api.limit: Constant.loadLimit,
        Api.type: 'property',
        // "current_user": HiveUtils.getUserId()
      };

      final response = await Api.get(
        url: Api.getFeaturedData,
        queryParameters: parameters,
      );
      final modelList = (response['data'] as List)
          .cast<Map<String, dynamic>>()
          .map<AdvertisementProperty>(AdvertisementProperty.fromJson)
          .toList();

      return DataOutput(
        total: int.parse(response['total']?.toString() ?? '0'),
        modelList: modelList,
      );
    } catch (e) {
      rethrow;
    }
  }

  ///Search property
  Future<DataOutput<PropertyModel>> searchProperty(
    String searchQuery, {
    required int offset,
    FilterApply? filter,
  }) async {
    final parameters = <String, dynamic>{
      Api.search: searchQuery,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      'current_user': HiveUtils.getUserId(),
      ...filter?.getFilter().cast<String, dynamic>() ?? <String, dynamic>{},
    }..removeWhere((key, value) => value == null);

    final response = await Api.get(
      url: Api.apiGetPropertyList,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();

    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  ///to get my properties which i had added to sell or rent
  Future<DataOutput<PropertyModel>> fetchMyProperties({
    required int offset,
    required String type,
    required String status,
  }) async {
    try {
      final propertyType = _findPropertyType(type.toLowerCase());

      final parameters = <String, dynamic>{
        Api.offset: offset,
        Api.limit: Constant.loadLimit,
        // Api.userid: HiveUtils.getUserId(),
        Api.propertyType: propertyType,
        'request_status': status,
        // "current_user": HiveUtils.getUserId()
      };

      if (status == 'all') {
        parameters.remove('request_status');
      }
      final response = await Api.get(
        url: Api.getAddedProperties,
        queryParameters: parameters,
        useAuthToken: true,
      );
      final modelList = (response['data'] as List)
          .cast<Map<String, dynamic>>()
          .map<PropertyModel>(PropertyModel.fromMap)
          .toList();

      return DataOutput(
        total: int.parse(response['total']?.toString() ?? '0'),
        modelList: modelList,
      );
    } catch (e, st) {
      log('Error in my properties $e');
      log('$st');
    }
    return DataOutput(total: 0, modelList: []);
  }

  String? _findPropertyType(String type) {
    if (type.toLowerCase() == 'sell') {
      return '0';
    } else if (type.toLowerCase() == 'rent') {
      return '1';
    } else if (type.toLowerCase() == 'sold') {
      return '2';
    } else if (type.toLowerCase() == 'rented') {
      return '3';
    }
    return null;
  }

  Future<DataOutput<PropertyModel>> fetchPropertyFromCategoryId({
    required int id,
    required int offset,
    FilterApply? filter,
    bool? showPropertyType,
  }) async {
    final parameters = <String, dynamic>{
      Api.categoryId: id,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      'current_user': HiveUtils.getUserId(),
      ...filter?.getFilter().cast<String, dynamic>() ?? <String, dynamic>{},
    }..removeWhere((key, value) => value == null);

    final response = await Api.get(
      url: Api.apiGetPropertyList,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<dynamic> updatePropertyStatus({
    required propertyId,
    required status,
  }) async {
    await Api.post(
      url: Api.updatePropertyStatus,
      parameter: {'status': status, 'property_id': propertyId},
    );
  }

  Future<DataOutput<PropertyModel>> fetchPropertiesFromCityName(
    String cityName, {
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.apiGetPropertyList,
      queryParameters: {
        'city': cityName,
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
        'current_user': HiveUtils.getUserId(),
      }..removeWhere((key, value) => value == null),
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<DataOutput<PropertyModel>> fetchAllProperties({
    required int offset,
    required String latitude,
    required String longitude,
    required String radius,
  }) async {
    final parameters = <String, dynamic>{
      Api.limit: Constant.loadLimit,
      Api.offset: offset,
      Api.latitude: latitude,
      Api.longitude: longitude,
      Api.radius: radius,
    }..removeWhere((key, value) => value == null);
    try {
      final response = await Api.get(
        url: Api.apiGetPropertyList,
        queryParameters: parameters,
      );

      final modelList = (response['data'] as List)
          .cast<Map<String, dynamic>>()
          .map<PropertyModel>(PropertyModel.fromMap)
          .toList();
      return DataOutput(
        total: int.parse(response['total']?.toString() ?? '0'),
        modelList: modelList,
      );
    } catch (e) {
      log('Error is $e');
    }
    return DataOutput(total: 0, modelList: []);
  }

  Future<Map<String, dynamic>> changePropertyStatus({
    required int propertyId,
    required int status,
  }) async {
    final parameters = <String, dynamic>{
      Api.propertyId: propertyId,
      Api.status: status,
    };
    final response = await Api.post(
      url: Api.changePropertyStatus,
      parameter: parameters,
    );
    return response;
  }

  Future<PropertyModel> fetchBySlug(String slug) async {
    final apiUrl = Api.apiGetPropertyDetails;
    final result = await Api.get(
      url: apiUrl,
      queryParameters: {'slug_id': slug},
    );

    // Ensure 'data' is a List and safely extract the first item
    final data = result['data'];
    if (data is List && data.isNotEmpty) {
      final firstItem = data.first;
      if (firstItem is Map<String, dynamic>) {
        return PropertyModel.fromMap(firstItem);
      }
    }

    // Handle cases where data is null or in an unexpected format
    throw Exception('Invalid data format received');
  }

  Future<DataOutput<PropertyModel>> fetchSimilarProperty({
    required int propertyId,
  }) async {
    final parameters = <String, dynamic>{
      Api.propertyId: propertyId,
    };
    final response = await Api.get(
      url: Api.getAllSimilarProperties,
      queryParameters: parameters,
    );
    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<ComparePropertyModel> compareProperties({
    required int sourcePropertyId,
    required int targetPropertyId,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'source_property_id': sourcePropertyId,
        'target_property_id': targetPropertyId,
      };
      final response = await Api.get(
        url: Api.compareProperties,
        queryParameters: parameters,
      );
      final result = ComparePropertyModel.fromJson(
        response['data'] as Map<String, dynamic>? ?? {},
      );
      return result;
    } catch (e, st) {
      log('Error is $e $st');
      return ComparePropertyModel();
    }
  }

  Future<DataOutput<PropertyModel>> fetchPremiumProperty({
    required int offset,
    required String latitude,
    required String longitude,
    required String radius,
  }) async {
    final parameters = <String, dynamic>{
      'get_all_premium_properties': 1,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      'current_user': HiveUtils.getUserId(),
      Api.latitude: latitude,
      Api.longitude: longitude,
      Api.radius: radius,
    }..removeWhere((key, value) => value == null);

    final response = await Api.get(
      url: Api.apiGetPropertyList,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();

    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }
}
