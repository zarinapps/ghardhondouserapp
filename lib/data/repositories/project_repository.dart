import 'package:dio/dio.dart';
import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/exports/main_export.dart';

class ProjectRepository {
  Future<Map<String, dynamic>?> createProject(Map projectPayload) async {
    try {
      final multipartData = _multipartImages(projectPayload);
      final images = projectPayload['gallery_images'];
      multipartData.remove('gallery_images');
      var galleryImages = <String, dynamic>{};
      if (images != null) {
        galleryImages =
            (images as MultiValue).value.fold({}, (previousValue, element) {
          if (element.value is! String) {
            previousValue.addAll({
              'gallery_images[${previousValue.length}]':
                  MultipartFile.fromFileSync((element.value as File).path),
            });
          }

          return previousValue;
        });
      }

      multipartData.addAll(galleryImages);
      final map = await Api.post(
        url: Api.postProject,
        parameter: multipartData,
      );
      return map;
    } catch (e) {
      return null;
      // throw e;
    }
  }

  Future<DataOutput<ProjectModel>> fetchAllProjects({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.getProjects,
      queryParameters: {
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
      },
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<DataOutput<ProjectModel>> getMyProjects({
    required int offset,
  }) async {
    final result = await Api.get(
      url: Api.getAddedProjects,
      queryParameters: {'offset': offset},
    );
    final list = (result['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();

    return DataOutput(
      total: int.parse(result['total']?.toString() ?? '0'),
      modelList: list,
    );
  }

  Future<DataOutput<ProjectModel>> getProjects({
    int? offset,
  }) async {
    final result = await Api.get(
      url: Api.getProjects,
      queryParameters: {'offset': offset},
      useAuthToken: true,
    );
    final list = (result['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();

    return DataOutput(
      total: int.parse(result['total']?.toString() ?? '0'),
      modelList: list,
    );
  }

  Future<ProjectModel> getProjectDetails({
    required int id,
    required bool isMyProject,
  }) async {
    final result = await Api.get(
      url: isMyProject ? Api.getAddedProjects : Api.getProjectDetails,
      queryParameters: {'id': id},
      useAuthToken: true,
    );
    if (result['error'] == true) {
      throw ApiException(result['message'].toString());
    }
    return ProjectModel.fromMap(result['data'] as Map<String, dynamic>? ?? {});
  }

  Map<String, dynamic> _multipartImages(Map data) {
    return data.map((key, value) {
      if (value is FileValue) {
        return MapEntry(
          key?.toString() ?? '',
          MultipartFile.fromFileSync(value.value.path),
        );
      }
      if (value is MultiValue && key != 'gallery_images') {
        final images = value.value.map((image) {
          if (image is FileValue) {
            return MultipartFile.fromFileSync(image.value.path);
          }
        }).toList();
        return MapEntry(key?.toString() ?? '', images);
      }
      if (value is List<File>) {
        final files =
            value.map((e) => MultipartFile.fromFileSync(e.path)).toList();
        return MapEntry(key?.toString() ?? '', files);
      }
      if (value is Map) {
        final v = _multipartImages(value);
        return MapEntry(key?.toString() ?? '', v);
      }
      if (value is List) {
        final list = value.map((e) {
          if (e is Map) {
            return _multipartImages(e);
          }
          return {};
        }).toList();
        return MapEntry(key?.toString() ?? '', list);
      }

      return MapEntry(key?.toString() ?? '', value);
    });
  }

  Future<DataOutput<ProjectModel>> fetchProjectFromProjectId(dynamic id) async {
    final parameters = <String, dynamic>{
      Api.id: id,
    };

    final response = await Api.get(
      url: Api.getProjects,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();

    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<Map<String, dynamic>> changeProjectStatus({
    required int projectId,
    required int status,
  }) async {
    final parameters = <String, dynamic>{
      'project_id': projectId,
      Api.status: status,
    };
    final response = await Api.post(
      url: Api.changeProjectStatus,
      parameter: parameters,
    );
    return response;
  }

  Future<DataOutput<AdvertisementProject>> fetchMyPromotedProjects() async {
    final parameters = <String, dynamic>{
      Api.type: 'project',
    };

    final response = await Api.get(
      url: Api.getFeaturedData,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<AdvertisementProject>(AdvertisementProject.fromJson)
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }
}
