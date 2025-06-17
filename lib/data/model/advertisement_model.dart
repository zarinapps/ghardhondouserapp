class AdvertisementProperty {
  AdvertisementProperty({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.propertyId,
    required this.property,
  });

  factory AdvertisementProperty.fromJson(Map<String, dynamic> json) =>
      AdvertisementProperty(
        id: json['id'] as int,
        status: json['status'] as int? ?? 0,
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString() ?? '',
        propertyId: json['property_id'] as int,
        property:
            Property.fromJson(json['property'] as Map<String, dynamic>? ?? {}),
      );
  final int id;
  final int status;
  final String startDate;
  final String endDate;
  final int propertyId;
  final Property property;

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
        'property_id': propertyId,
        'property': property.toJson(),
      };
}

class Property {
  Property({
    required this.id,
    required this.categoryId,
    required this.slugId,
    required this.title,
    required this.properyType,
    required this.city,
    required this.state,
    required this.country,
    required this.price,
    required this.titleImage,
    required this.gallery,
    required this.documents,
    required this.isFavourite,
    required this.category,
  });

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        id: json['id'] as int,
        categoryId: json['category_id'] as int,
        slugId: json['slug_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        properyType: json['propery_type']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        country: json['country']?.toString() ?? '',
        price: json['price']?.toString() ?? '',
        titleImage: json['title_image']?.toString() ?? '',
        gallery:
            List<dynamic>.from((json['gallery'] as List? ?? []).map((x) => x)),
        documents: List<dynamic>.from(
          (json['documents'] as List? ?? []).map((x) => x),
        ),
        isFavourite: json['is_favourite'] as int? ?? 0,
        category:
            Category.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
      );
  final int id;
  final int categoryId;
  final String slugId;
  final String title;
  final String properyType;
  final String city;
  final String state;
  final String country;
  final String price;
  final String titleImage;
  final List<dynamic> gallery;
  final List<dynamic> documents;
  final int isFavourite;
  final Category category;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'slug_id': slugId,
        'title': title,
        'propery_type': properyType,
        'city': city,
        'state': state,
        'country': country,
        'price': price,
        'title_image': titleImage,
        'gallery': List<dynamic>.from(gallery.map((x) => x)),
        'documents': List<dynamic>.from(documents.map((x) => x)),
        'is_favourite': isFavourite,
        'category': category.toJson(),
      };
}

class Category {
  Category({
    required this.id,
    required this.category,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int,
        category: json['category']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
      );
  final int id;
  final String category;
  final String image;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'image': image,
      };
}

class AdvertisementProject {
  AdvertisementProject({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.projectId,
    required this.project,
  });

  factory AdvertisementProject.fromJson(Map<String, dynamic> json) =>
      AdvertisementProject(
        id: json['id'] as int,
        status: json['status'] as int? ?? 0,
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString() ?? '',
        projectId: json['project_id'] as int,
        project:
            Project.fromJson(json['project'] as Map<String, dynamic>? ?? {}),
      );
  final int id;
  final int status;
  final String startDate;
  final String endDate;
  final int projectId;
  final Project project;

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
        'project_id': projectId,
        'Project': project.toJson(),
      };
}

class Project {
  Project({
    required this.id,
    required this.categoryId,
    required this.slugId,
    required this.title,
    required this.projectType,
    required this.city,
    required this.state,
    required this.country,
    required this.titleImage,
    required this.isPromoted,
    required this.category,
    required this.isFeatureAvailable,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as int,
        categoryId: json['category_id'] as int,
        slugId: json['slug_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        projectType: json['type']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        country: json['country']?.toString() ?? '',
        titleImage: json['image']?.toString() ?? '',
        isPromoted: json['is_promoted'] as bool? ?? false,
        isFeatureAvailable: json['is_feature_available'] as bool? ?? false,
        category:
            Category.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
      );
  final int id;
  final int categoryId;
  final String slugId;
  final String title;
  final String projectType;
  final String city;
  final String state;
  final String country;
  final String titleImage;
  final bool isPromoted;
  final bool isFeatureAvailable;
  final Category category;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'slug_id': slugId,
        'title': title,
        'propery_type': projectType,
        'city': city,
        'state': state,
        'country': country,
        'title_image': titleImage,
        'is_promoted': isPromoted,
        'is_feature_available': isFeatureAvailable,
        'category': category.toJson(),
      };
}
