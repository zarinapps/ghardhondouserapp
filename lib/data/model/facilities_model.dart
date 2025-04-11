class FacilitiesModel {
  const FacilitiesModel({
    this.id,
    this.name,
    this.typeOfParameter,
    this.typeValues,
    this.image,
    this.isRequired,
  });

  FacilitiesModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name']?.toString() ?? '',
        typeOfParameter = json['type_of_parameter']?.toString() ?? '',
        typeValues = (json['type_values'] as List?)
                ?.where((element) => element != null) // Remove null values
                .map((element) => element.toString()) // Convert to string
                .toList() ??
            [], // Default to empty list if null
        image = json['image']?.toString() ?? '',
        isRequired = json['is_required'] as int? ?? 0;
  final int? id;
  final String? name;
  final String? typeOfParameter;
  final List<String>? typeValues;
  final String? image;
  final int? isRequired;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type_of_parameter': typeOfParameter,
        'type_values': typeValues,
        'image': image,
        'is_required': isRequired,
      };
}
