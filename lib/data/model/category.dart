// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ebroker/utils/api.dart';

class Category {
  int? id;
  String? category;
  String? image;
  List<dynamic>? parameterTypes;
  Category({this.id, this.category, this.image, this.parameterTypes});

  Category.fromJson(Map<String, dynamic> json) {
    id = json[Api.id] as int?;
    category = json[Api.category]?.toString() ?? '';
    image = json[Api.image]?.toString() ?? '';
    parameterTypes = json[Api.parameterTypes] is Map
        ? json[Api.parameterTypes]['parameters'] as List? ?? []
        : ((json[Api.parameterTypes] as List?) ?? []);
  }

  Category.fromProperty(Map<String, dynamic> json) {
    id = json[Api.id] as int?;
    category = json[Api.category]?.toString() ?? '';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'image': image,
      'parameterTypes': parameterTypes,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      category: map['category'] != null ? map['category'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      parameterTypes: map['parameterTypes'] as List? ?? [],
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Category(id: $id, category: $category, image: $image, parameterTypes: $parameterTypes)';
  }
}

class Type {
  String? id;
  String? type;

  Type({this.id, this.type});

  Type.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    type = json[Api.type]?.toString() ?? '';
  }
}
