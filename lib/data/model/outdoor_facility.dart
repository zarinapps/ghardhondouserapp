class OutdoorFacility {
  OutdoorFacility({
    this.id,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.distance,
  });

  OutdoorFacility.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name']?.toString() ?? '';
    image = json['image']?.toString() ?? '';
    createdAt = json['created_at']?.toString() ?? '';
    updatedAt = json['updated_at']?.toString() ?? '';
    distance = json['distance']?.toString() ?? '';
  }
  int? id;
  String? name;
  String? image;
  String? distance;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['distance'] = distance.toString();
    return data;
  }

  @override
  String toString() {
    return 'OutdoorFacility{id: $id, name: $name, image: $image, distance: $distance, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
