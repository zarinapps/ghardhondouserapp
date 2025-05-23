import 'package:ebroker/utils/Extensions/lib/adaptive_type.dart';

class ArticleModel {
  ArticleModel({this.id, this.image, this.title, this.description, this.date});

  ArticleModel.fromJson(Map<String, dynamic> json) {
    id = Adapter.forceInt(json['id']);
    image = json['image']?.toString() ?? '';
    title = json['title']?.toString() ?? '';
    description = json['description']?.toString() ?? '';
    date = json['created_at']?.toString() ?? '';
  }
  int? id;
  String? image;
  String? title;
  String? description;
  String? date;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['title'] = title;
    data['description'] = description;
    data['created_at'] = date;
    return data;
  }
}
