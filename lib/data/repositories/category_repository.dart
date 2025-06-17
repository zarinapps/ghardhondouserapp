import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/utils/api.dart';

class CategoryRepository {
  Future<DataOutput<Category>> fetchCategories({
    required int offset,
    int? id,
  }) async {
    final parameters = <String, dynamic>{
      if (id != null) 'id': id,
      Api.offset: offset,
      Api.limit: 50,
    };
    try {
      final response = await Api.get(
        url: Api.apiGetCategories,
        queryParameters: parameters,
      );

      final modelList = (response['data'] as List).map(
        (e) {
          return Category.fromJson(e as Map<String, dynamic>? ?? {});
        },
      ).toList();
      return DataOutput(
        total: int.parse(response['total']?.toString() ?? '0'),
        modelList: modelList,
      );
    } catch (e) {
      rethrow;
    }
  }
}
