import 'dart:convert';
import 'dart:developer';

import 'package:ebroker/utils/Extensions/lib/adaptive_type.dart';
import 'package:ebroker/utils/admob/native_ad_manager.dart';
import 'package:ebroker/utils/helper_utils.dart';

class PropertyModel implements NativeAdWidgetContainer {
  PropertyModel({
    this.id,
    this.title,
    this.customerName,
    this.customerEmail,
    this.customerNumber,
    this.customerProfile,
    this.price,
    this.category,
    this.builtUpArea,
    this.plotArea,
    this.hectaArea,
    this.acre,
    this.houseType,
    this.furnished,
    this.unitType,
    this.description,
    this.address,
    this.clientAddress,
    this.properyType,
    this.titleImage,
    this.postCreated,
    this.gallery,
    this.totalView,
    this.status,
    this.requestStatus,
    this.state,
    this.city,
    this.country,
    this.addedBy,
    this.inquiry,
    this.promoted,
    this.isFavourite,
    this.rentduration,
    this.isInterested,
    this.favouriteUsers,
    this.interestedUsers,
    this.totalInterestedUsers,
    this.totalFavouriteUsers,
    this.parameters,
    this.latitude,
    this.longitude,
    this.threeDImage,
    this.advertisment,
    this.video,
    this.assignedOutdoorFacility,
    this.slugId,
    this.allPropData,
    this.titleimagehash,
    this.documents,
    this.isVerified,
    this.isFeatureAvailable,
    this.advertisementId,
    this.advertisementStatus,
    this.advertisementType,
    this.isBlockedByUser,
    this.isBlockedByMe,
    this.rejectReason,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> rawjson) {
    try {
      final list =
          (rawjson['parameters'] as List).map((e) => e['image']).toList();
      HelperUtils.precacheSVG(List.from(list));
    } catch (e) {
      log('Error is $e');
    }
    return PropertyModel(
      id: rawjson['id'] as int,
      allPropData: rawjson,
      slugId: rawjson['slug_id']?.toString(),
      rentduration: rawjson['rentduration']?.toString(),
      customerEmail: rawjson['email']?.toString(),
      customerProfile: rawjson['profile']?.toString(),
      customerNumber: rawjson['mobile']?.toString(),
      customerName: rawjson['customer_name']?.toString(),
      video: rawjson['video_link']?.toString(),
      threeDImage: rawjson['three_d_image']?.toString(),
      latitude: rawjson['latitude']?.toString(),
      longitude: rawjson['longitude']?.toString(),
      title: rawjson['title']?.toString(),
      price: rawjson['price']?.toString(),
      category: rawjson['category'] == null
          ? null
          : Categorys.fromMap(rawjson['category'] as Map<String, dynamic>),
      builtUpArea: rawjson['built_up_area'],
      plotArea: rawjson['plot_area'],
      hectaArea: rawjson['hecta_area'],
      acre: rawjson['acre'],
      houseType: rawjson['house_type'],
      furnished: rawjson['furnished'],
      advertisment: rawjson['advertisement'],
      unitType: rawjson['unit_type'] == null
          ? null
          : UnitType.fromMap(rawjson['unit_type'] as Map<String, dynamic>),
      description: rawjson['description']?.toString(),
      address: rawjson['address']?.toString(),
      clientAddress: rawjson['client_address']?.toString(),
      properyType: rawjson['property_type']?.toString(),
      titleImage: rawjson['title_image']?.toString(),
      postCreated: rawjson['post_created']?.toString(),
      gallery: List<Gallery>.from(
        (rawjson['gallery'] as List).map(
          (x) => Gallery.fromMap(
            (x is String ? json.decode(x) : x) as Map<String, dynamic>,
          ),
        ),
      ),
      documents: List<PropertyDocuments>.from(
        (rawjson['documents'] as List).map(
          (x) => PropertyDocuments.fromMap(
            (x is String ? json.decode(x) : x) as Map<String, dynamic>,
          ),
        ),
      ),
      totalView: Adapter.forceInt(rawjson['total_view'] as dynamic),
      status: Adapter.forceInt(rawjson['status']),
      requestStatus: rawjson['request_status']?.toString(),
      state: rawjson['state']?.toString(),
      city: rawjson['city']?.toString(),
      country: rawjson['country']?.toString(),
      addedBy: Adapter.forceInt(rawjson['added_by'] as dynamic),
      inquiry: rawjson['inquiry'] as bool? ?? false,
      promoted: rawjson['promoted'] as bool? ?? false,
      isFavourite: Adapter.forceInt(rawjson['is_favourite']),
      isInterested: Adapter.forceInt(rawjson['is_interested']),
      favouriteUsers: (rawjson['favourite_users'] as List<dynamic>?)
              ?.map((x) => x)
              .toList() ??
          [],
      interestedUsers: (rawjson['interested_users'] as List<dynamic>?)
              ?.map((x) => x)
              .toList() ??
          [],
      totalInterestedUsers: Adapter.forceInt(rawjson['total_interested_users']),
      totalFavouriteUsers: Adapter.forceInt(rawjson['total_favourite_users']),
      parameters: rawjson['parameters'] == null
          ? []
          : List<Parameter>.from(
              (rawjson['parameters'] as List).map((x) {
                return Parameter.fromMap(x as Map<String, dynamic>);
              }),
            ),
      assignedOutdoorFacility: rawjson['assign_facilities'] == null
          ? []
          : List<AssignedOutdoorFacility>.from(
              (rawjson['assign_facilities'] as List).map((x) {
                return AssignedOutdoorFacility.fromJson(
                  x as Map<String, dynamic>,
                );
              }),
            ),
      titleimagehash: rawjson['title_image_hash']?.toString(),
      isVerified: rawjson['is_verified'] as bool? ?? false,
      isFeatureAvailable: rawjson['is_feature_available'] as bool? ?? false,
      advertisementId: rawjson['advertisement_id'] as int?,
      advertisementStatus: rawjson['advertisement_status'] as int?,
      advertisementType: rawjson['advertisement_type']?.toString(),
      isBlockedByUser: rawjson['is_blocked_by_user'] as bool? ?? false,
      isBlockedByMe: rawjson['is_blocked_by_me'] as bool? ?? false,
      rejectReason: rawjson['reject_reason']?.toString() ?? '',
    );
  }

  final int? id;
  final String? title;
  final String? price;
  final String? customerName;
  final String? customerEmail;
  final String? customerProfile;
  final String? customerNumber;
  final String? rentduration;
  final Categorys? category;
  final dynamic builtUpArea;
  final dynamic plotArea;
  final dynamic hectaArea;
  final dynamic acre;
  final dynamic houseType;
  final dynamic furnished;
  final UnitType? unitType;
  final String? description;
  final String? address;
  final String? clientAddress;
  String? properyType;
  final String? titleImage;
  final String? titleimagehash;
  final String? postCreated;
  final List<Gallery>? gallery;
  final List<PropertyDocuments>? documents;
  final int? totalView;
  final int? status;
  final String? requestStatus;
  final String? state;
  final String? city;
  final String? country;
  final int? addedBy;
  final bool? inquiry;
  final bool? promoted;
  final int? isFavourite;
  final int? isInterested;
  final List<dynamic>? favouriteUsers;
  final List<dynamic>? interestedUsers;
  final int? totalInterestedUsers;
  final int? totalFavouriteUsers;
  final List<Parameter>? parameters;
  final List<AssignedOutdoorFacility>? assignedOutdoorFacility;
  final String? latitude;
  final String? longitude;
  final String? threeDImage;
  final String? video;
  final dynamic advertisment;
  final String? slugId;
  final dynamic allPropData;
  final bool? isVerified;
  final bool? isFeatureAvailable;
  final int? advertisementId;
  final int? advertisementStatus;
  final String? advertisementType;
  final bool? isBlockedByUser;
  final bool? isBlockedByMe;
  final String? rejectReason;

  PropertyModel copyWith({
    int? id,
    String? title,
    String? price,
    Categorys? category,
    dynamic builtUpArea,
    dynamic plotArea,
    dynamic hectaArea,
    dynamic acre,
    dynamic houseType,
    dynamic furnished,
    UnitType? unitType,
    String? description,
    String? address,
    String? clientAddress,
    String? properyType,
    String? titleImage,
    String? postCreated,
    List<Gallery>? gallery,
    int? totalView,
    int? status,
    String? requestStatus,
    String? state,
    String? city,
    String? country,
    int? addedBy,
    bool? inquiry,
    bool? promoted,
    int? isFavourite,
    int? isInterested,
    List<dynamic>? favouriteUsers,
    List<dynamic>? interestedUsers,
    int? totalInterestedUsers,
    int? totalFavouriteUsers,
    List<Parameter>? parameters,
    List<AssignedOutdoorFacility>? assignedOutdoorFacility,
    String? latitude,
    String? longitude,
    String? threeDImage,
    String? video,
    dynamic advertisment,
    String? rentduration,
    String? titleImageHash,
    List<PropertyDocuments>? documents,
    bool? isVerified,
    bool? isFeatureAvailable,
    int? advertisementId,
    int? advertisementStatus,
    String? advertisementType,
    bool? isBlockedByUser,
    bool? isBlockedByMe,
    String? rejectReason,
  }) =>
      PropertyModel(
        id: id ?? this.id,
        rentduration: rentduration ?? this.rentduration,
        advertisment: advertisment ?? this.advertisment,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        title: title ?? this.title,
        price: price ?? this.price,
        category: category ?? this.category,
        builtUpArea: builtUpArea ?? this.builtUpArea,
        plotArea: plotArea ?? this.plotArea,
        hectaArea: hectaArea ?? this.hectaArea,
        acre: acre ?? this.acre,
        houseType: houseType ?? this.houseType,
        furnished: furnished ?? this.furnished,
        unitType: unitType ?? this.unitType,
        description: description ?? this.description,
        address: address ?? this.address,
        clientAddress: clientAddress ?? this.clientAddress,
        properyType: properyType ?? this.properyType,
        titleImage: titleImage ?? this.titleImage,
        postCreated: postCreated ?? this.postCreated,
        gallery: gallery ?? this.gallery,
        totalView: totalView ?? this.totalView,
        status: status ?? this.status,
        requestStatus: requestStatus ?? this.requestStatus,
        state: state ?? this.state,
        city: city ?? this.city,
        country: country ?? this.country,
        addedBy: addedBy ?? this.addedBy,
        inquiry: inquiry ?? this.inquiry,
        promoted: promoted ?? this.promoted,
        isFavourite: isFavourite ?? this.isFavourite,
        isInterested: isInterested ?? this.isInterested,
        favouriteUsers: favouriteUsers ?? this.favouriteUsers,
        interestedUsers: interestedUsers ?? this.interestedUsers,
        totalInterestedUsers: totalInterestedUsers ?? this.totalInterestedUsers,
        totalFavouriteUsers: totalFavouriteUsers ?? this.totalFavouriteUsers,
        parameters: parameters ?? this.parameters,
        threeDImage: threeDImage ?? threeDImage,
        video: video ?? this.video,
        assignedOutdoorFacility:
            assignedOutdoorFacility ?? this.assignedOutdoorFacility,
        titleimagehash: titleImageHash ?? titleimagehash,
        documents: documents ?? this.documents,
        isVerified: isVerified ?? this.isVerified,
        isFeatureAvailable: isFeatureAvailable ?? this.isFeatureAvailable,
        advertisementId: advertisementId ?? this.advertisementId,
        advertisementStatus: advertisementStatus ?? this.advertisementStatus,
        advertisementType: advertisementType ?? this.advertisementType,
        isBlockedByUser: isBlockedByUser ?? this.isBlockedByUser,
        isBlockedByMe: isBlockedByMe ?? this.isBlockedByMe,
        rejectReason: rejectReason ?? this.rejectReason,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'allPropData': allPropData,
        'rentduration': rentduration,
        'mobile': customerNumber,
        'email': customerEmail,
        'customer_name': customerName,
        'profile': customerProfile,
        'three_d_image': threeDImage,
        'title': title,
        'latitude': latitude,
        'longitude': longitude,
        'advertisment': advertisment,
        'video_link': video,
        'price': price,
        'category': category?.toMap() ?? {},
        'built_up_area': builtUpArea,
        'plot_area': plotArea,
        'hecta_area': hectaArea,
        'acre': acre,
        'house_type': houseType,
        'furnished': furnished,
        'unit_type': unitType?.toMap() ?? {},
        'description': description,
        'address': address,
        'client_address': clientAddress,
        'property_type': properyType,
        'title_image': titleImage,
        'post_created': postCreated,
        'gallery': List<Gallery>.from(gallery?.map((x) => x) ?? []),
        'documents':
            List<PropertyDocuments>.from(documents?.map((x) => x) ?? []),
        'total_view': totalView,
        'status': status,
        'request_status': requestStatus,
        'state': state,
        'city': city,
        'country': country,
        'added_by': addedBy,
        'inquiry': inquiry,
        'promoted': promoted,
        'is_favourite': isFavourite,
        'is_interested': isInterested,
        'favourite_users': favouriteUsers == null
            ? null
            : List<dynamic>.from(favouriteUsers?.map((x) => x) ?? []),
        'interested_users': interestedUsers == null
            ? null
            : List<dynamic>.from(interestedUsers?.map((x) => x) ?? []),
        'total_interested_users': totalInterestedUsers,
        'total_favourite_users': totalFavouriteUsers,
        'assign_facilities': assignedOutdoorFacility == null
            ? null
            : List<dynamic>.from(
                assignedOutdoorFacility?.map((e) => e.toJson()) ?? [],
              ),
        'parameters': parameters == null
            ? null
            : List<dynamic>.from(parameters?.map((x) => x.toMap()) ?? []),
        'title_image_hash': titleimagehash,
        'is_verified': isVerified,
        'is_feature_available': isFeatureAvailable,
        'advertisement_id': advertisementId,
        'advertisement_status': advertisementStatus,
        'advertisement_type': advertisementType,
        'is_blocked_by_user': isBlockedByUser,
        'is_blocked_by_me': isBlockedByMe,
        'reject_reason': rejectReason,
      };

  @override
  String toString() {
    return 'PropertyModel(id: $id,rentduration:$rentduration , title: $title,assigned_facilities:[$assignedOutdoorFacility]  advertisment:$advertisment, price: $price, category: $category,, builtUpArea: $builtUpArea, plotArea: $plotArea, hectaArea: $hectaArea, acre: $acre, houseType: $houseType, furnished: $furnished, unitType: $unitType, description: $description, address: $address, clientAddress: $clientAddress, properyType: $properyType, titleImage: $titleImage, title_image_hash: $titleimagehash, postCreated: $postCreated, gallery: $gallery, documents: $documents, totalView: $totalView, status: $status,requestStatus: $requestStatus, state: $state, city: $city, country: $country, addedBy: $addedBy, inquiry: $inquiry, promoted: $promoted, isFavourite: $isFavourite, isInterested: $isInterested, favouriteUsers: $favouriteUsers, interestedUsers: $interestedUsers, totalInterestedUsers: $totalInterestedUsers, totalFavouriteUsers: $totalFavouriteUsers, parameters: $parameters, latitude: $latitude, longitude: $longitude, threeDImage: $threeDImage, video: $video, isVerified: $isVerified, rejectReason: $rejectReason)';
  }
}

class Categorys {
  Categorys({
    this.id,
    this.category,
    this.image,
  });

  factory Categorys.fromJson(String str) =>
      Categorys.fromMap(json.decode(str) as Map<String, dynamic>);

  factory Categorys.fromMap(Map<String, dynamic> json) => Categorys(
        id: json['id'] as int?,
        category: json['category']?.toString(),
        image: json['image']?.toString(),
      );

  final int? id;
  final String? category;
  final String? image;

  Categorys copyWith({
    int? id,
    String? category,
    String? image,
  }) =>
      Categorys(
        id: id ?? this.id,
        category: category ?? this.category,
        image: image ?? this.image,
      );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'image': image,
      };
}

class Parameter {
  Parameter({
    this.id,
    this.name,
    this.typeOfParameter,
    this.typeValues,
    this.image,
    this.value,
    this.isRequired,
  });

  factory Parameter.fromMap(Map<String, dynamic> json) {
    return Parameter(
      id: json['id'] as int,
      name: json['name']?.toString(),
      typeOfParameter: json['type_of_parameter']?.toString(),
      typeValues: json['type_values'],
      image: json['image']?.toString(),
      value: ifListConvertToString(json['value']),
      isRequired: json['is_required'] as int?,
    );
  }

  final int? id;
  final String? name;
  final String? typeOfParameter;
  final dynamic typeValues;
  final String? image;
  final dynamic value;
  final int? isRequired;

  Parameter copyWith({
    int? id,
    String? name,
    String? typeOfParameter,
    dynamic typeValues,
    String? image,
    dynamic value,
    int? isRequired,
  }) =>
      Parameter(
        id: id ?? this.id,
        name: name ?? this.name,
        typeOfParameter: typeOfParameter ?? this.typeOfParameter,
        typeValues: typeValues ?? this.typeValues,
        image: image ?? this.image,
        value: value ?? this.value,
        isRequired: isRequired ?? this.isRequired,
      );

  static dynamic ifListConvertToString(dynamic value) {
    if (value is List) {
      return value.join(',');
    }

    return value;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type_of_parameter': typeOfParameter,
        'type_values': typeValues,
        'image': image,
        'value': value,
        'is_required': isRequired,
      };

  @override
  String toString() {
    return 'Parameter(id: $id, name: $name, typeOfParameter: $typeOfParameter, typeValues: $typeValues, image: $image, value: $value, isRequired: $isRequired)';
  }
}

class UnitType {
  UnitType({
    this.id,
    this.measurement,
  });

  factory UnitType.fromJson(String str) =>
      UnitType.fromMap(json.decode(str) as Map<String, dynamic>);

  factory UnitType.fromMap(Map<String, dynamic> json) => UnitType(
        id: json['id'] as int?,
        measurement: json['measurement']?.toString(),
      );

  final int? id;
  final String? measurement;

  UnitType copyWith({
    int? id,
    String? measurement,
  }) =>
      UnitType(
        id: id ?? this.id,
        measurement: measurement ?? this.measurement,
      );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        'id': id,
        'measurement': measurement,
      };
}

class Gallery {
  Gallery({
    required this.id,
    required this.image,
    required this.imageUrl,
    this.isVideo,
  });

  factory Gallery.fromMap(Map<String, dynamic> map) {
    return Gallery(
      id: map['id'] as int,
      image: map['image'] as String,
      imageUrl: map['image_url']?.toString() ?? '',
    );
  }

  factory Gallery.fromJson(String source) =>
      Gallery.fromMap(json.decode(source) as Map<String, dynamic>);
  final int id;
  final String image;
  final String imageUrl;
  final bool? isVideo;

  Gallery copyWith({
    int? id,
    String? image,
    String? imageUrl,
  }) {
    return Gallery(
      id: id ?? this.id,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'image': image,
      'image_url': imageUrl,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'Gallery(id: $id, image: $image, imageUrl: $imageUrl)';

  @override
  bool operator ==(covariant Gallery other) {
    if (identical(this, other)) return true;

    return other.id == id && other.image == image && other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => id.hashCode ^ image.hashCode ^ imageUrl.hashCode;
}

class AssignedOutdoorFacility {
  AssignedOutdoorFacility({
    this.id,
    this.propertyId,
    this.facilityId,
    this.distance,
    this.createdAt,
    this.name,
    this.image,
    this.updatedAt,
  });

  AssignedOutdoorFacility.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    propertyId = Adapter.forceInt(json['property_id']);
    facilityId = Adapter.forceInt(json['facility_id']);
    distance = json['distance'].toString();
    createdAt = json['created_at']?.toString();
    image = json['image']?.toString();
    name = json['name']?.toString();
    updatedAt = json['updated_at']?.toString();
  }
  int? id;
  int? propertyId;
  int? facilityId;
  String? distance;
  String? image;
  String? name;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['property_id'] = propertyId;
    data['facility_id'] = facilityId;
    data['distance'] = distance.toString();
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image'] = image;
    data['name'] = name;
    return data;
  }

  @override
  String toString() {
    return 'AssignedOutdoorFacility{id: $id, propertyId: $propertyId, facilityId: $facilityId, distance: $distance, image: $image, name: $name, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

class PropertyDocuments {
  PropertyDocuments({
    required this.name,
    this.id,
    this.type,
    this.file,
    this.propertyId,
  });

  factory PropertyDocuments.fromMap(Map<String, dynamic> json) {
    return PropertyDocuments(
      id: json['id'] as int?,
      name: json['file_name']?.toString() ?? '',
      type: json['type']?.toString(),
      file: json['file']?.toString(),
      propertyId: json['property_id'] as int?,
    );
  }

  factory PropertyDocuments.fromJson(String source) =>
      PropertyDocuments.fromMap(json.decode(source) as Map<String, dynamic>);

  int? id;
  String name;
  String? type;
  String? file;
  int? propertyId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_name': name,
      'type': type,
      'file': file,
      'property_id': propertyId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'PropertyDocuments(id: $id, name: $name, type: $type, file: $file, propertyId: $propertyId)';
  }
}
