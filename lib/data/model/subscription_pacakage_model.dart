class PackageResponseModel {
  PackageResponseModel({
    required this.subscriptionPackage,
    required this.activePackage,
    required this.allFeature,
  });

  factory PackageResponseModel.fromJson(Map<String, dynamic> json) =>
      PackageResponseModel(
        subscriptionPackage: (json['data'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(SubscriptionPackageModel.fromJson)
            .toList(),
        activePackage: (json['active_packages'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(ActivePackage.fromJson)
            .toList(),
        allFeature: (json['all_features'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AllFeature.fromJson)
            .toList(),
      );

  List<SubscriptionPackageModel> subscriptionPackage;
  List<ActivePackage> activePackage;
  List<AllFeature> allFeature;
}

class SubscriptionPackageModel {
  SubscriptionPackageModel({
    required this.id,
    required this.iosProductId,
    required this.name,
    required this.packageType,
    required this.price,
    required this.duration,
    required this.createdAt,
    required this.features,
  });

  factory SubscriptionPackageModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionPackageModel(
        id: json['id'] as int,
        iosProductId: json['ios_product_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        packageType: json['package_type']?.toString() ?? '',
        price: json['price'] as num? ?? 0,
        duration: json['duration'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
        features: List<PackageFeatures>.from(
          (json['features'] as List? ?? []).map(
            (x) => PackageFeatures.fromJson(x as Map<String, dynamic>? ?? {}),
          ),
        ),
      );

  int id;
  String name;
  String iosProductId;
  String packageType;
  num price;
  int duration;
  DateTime createdAt;
  List<PackageFeatures> features;

  SubscriptionPackageModel copyWith({
    int? id,
    String? iosProductId,
    String? name,
    String? packageType,
    num? price,
    int? duration,
    DateTime? createdAt,
    List<PackageFeatures>? features,
  }) =>
      SubscriptionPackageModel(
        id: id ?? this.id,
        iosProductId: iosProductId ?? this.iosProductId,
        name: name ?? this.name,
        packageType: packageType ?? this.packageType,
        price: price ?? this.price,
        duration: duration ?? this.duration,
        createdAt: createdAt ?? this.createdAt,
        features: features ?? this.features,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ios_product_id': iosProductId,
        'name': name,
        'package_type': packageType,
        'price': price,
        'duration': duration,
        'created_at': createdAt.toIso8601String(),
        'features': List<dynamic>.from(features.map((x) => x.toJson())),
      };
}

class ActivePackage {
  ActivePackage({
    required this.id,
    required this.name,
    required this.packageType,
    required this.price,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.features,
    required this.isActive,
    required this.validUntil,
  });

  factory ActivePackage.fromJson(Map<String, dynamic> json) => ActivePackage(
        id: json['id'] as int,
        name: json['name']?.toString() ?? '',
        packageType: json['package_type']?.toString() ?? '',
        price: json['price'] as num? ?? 0,
        duration: json['duration'] as int? ?? 0,
        startDate: DateTime.parse(json['start_date']?.toString() ?? ''),
        endDate: DateTime.parse(json['end_date']?.toString() ?? ''),
        createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
        features: List<ActivePackageFeature>.from(
          (json['features'] as List? ?? []).map(
            (x) =>
                ActivePackageFeature.fromJson(x as Map<String, dynamic>? ?? {}),
          ),
        ),
        isActive: json['is_active'] as int? ?? 0,
        validUntil: json['valid_until']?.toString() ?? '',
      );

  int id;
  String name;
  String packageType;
  num price;
  int duration;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;
  List<ActivePackageFeature> features;
  int isActive;
  String validUntil;

  ActivePackage copyWith({
    int? id,
    String? name,
    String? packageType,
    num? price,
    int? duration,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    List<ActivePackageFeature>? features,
    int? isActive,
    String? validUntil,
  }) =>
      ActivePackage(
        id: id ?? this.id,
        name: name ?? this.name,
        packageType: packageType ?? this.packageType,
        price: price ?? this.price,
        duration: duration ?? this.duration,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        createdAt: createdAt ?? this.createdAt,
        features: features ?? this.features,
        isActive: isActive ?? this.isActive,
        validUntil: validUntil ?? this.validUntil,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'package_type': packageType,
        'price': price,
        'duration': duration,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'features': List<dynamic>.from(features.map((x) => x.toJson())),
        'is_active': isActive,
        'valid_until': validUntil,
      };
}

class ActivePackageFeature {
  ActivePackageFeature({
    required this.id,
    required this.name,
    required this.limitType,
    required this.limit,
    required this.usedLimit,
    required this.totalLimit,
  });

  factory ActivePackageFeature.fromJson(Map<String, dynamic> json) =>
      ActivePackageFeature(
        id: json['id'] as int,
        name: json['name']?.toString() ?? '',
        limitType: AdvertisementLimit.values.firstWhere(
          (e) => e.toString() == 'AdvertisementLimit.${json["limit_type"]}',
        ),
        limit: json['limit'] as int? ?? 0,
        usedLimit: json['used_limit'] as int? ?? 0,
        totalLimit: json['total_limit'] as int? ?? 0,
      );

  int id;
  String name;
  AdvertisementLimit limitType;
  int? limit;
  int? usedLimit;
  int? totalLimit;

  ActivePackageFeature copyWith({
    int? id,
    String? name,
    AdvertisementLimit? limitType,
    int? limit,
    int? usedLimit,
    int? totalLimit,
  }) =>
      ActivePackageFeature(
        id: id ?? this.id,
        name: name ?? this.name,
        limitType: limitType ?? this.limitType,
        limit: limit ?? this.limit,
        usedLimit: usedLimit ?? this.usedLimit,
        totalLimit: totalLimit ?? this.totalLimit,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'limit_type': limitType.toString().split('.').last,
        'limit': limit,
        'used_limit': usedLimit,
        'total_limit': totalLimit,
      };
}

enum AdvertisementLimit { limited, unlimited }

class AllFeature {
  AllFeature({
    required this.id,
    required this.name,
    required this.status,
  });

  factory AllFeature.fromJson(Map<String, dynamic> json) => AllFeature(
        id: json['id'] as int,
        name: json['name']?.toString() ?? '',
        status: json['status'] as int? ?? 0,
      );

  int id;
  String name;
  int status;

  AllFeature copyWith({
    int? id,
    String? name,
    int? status,
  }) =>
      AllFeature(
        id: id ?? this.id,
        name: name ?? this.name,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
      };
}

class PackageFeatures {
  PackageFeatures({
    required this.id,
    required this.name,
    required this.limitType,
    required this.limit,
  });

  factory PackageFeatures.fromJson(Map<String, dynamic> json) =>
      PackageFeatures(
        id: json['id'] as int,
        name: json['name']?.toString() ?? '',
        limitType: AdvertisementLimit.values.firstWhere(
          (e) => e.toString() == 'AdvertisementLimit.${json["limit_type"]}',
        ),
        limit: json['limit'] as int? ?? 0,
      );

  int id;
  String name;
  AdvertisementLimit limitType;
  int? limit;

  PackageFeatures copyWith({
    int? id,
    String? name,
    AdvertisementLimit? limitType,
    int? limit,
  }) =>
      PackageFeatures(
        id: id ?? this.id,
        name: name ?? this.name,
        limitType: limitType ?? this.limitType,
        limit: limit ?? this.limit,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'limit_type': limitType.toString().split('.').last,
        'limit': limit,
      };
}
