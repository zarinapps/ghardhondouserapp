// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/repositories/advertisement_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateAdvertisementState {}

class CreateAdvertisementInitial extends CreateAdvertisementState {}

class CreateAdvertisementInProgress extends CreateAdvertisementState {}

class CreateAdvertisementSuccess extends CreateAdvertisementState {
  final String message;

  CreateAdvertisementSuccess({
    required this.message,
  });
}

class CreateAdvertisementFailure extends CreateAdvertisementState {
  final String errorMessage;
  CreateAdvertisementFailure(
    this.errorMessage,
  );
}

class CreateAdvertisementCubit extends Cubit<CreateAdvertisementState> {
  final AdvertisementRepository _advertisementRepository =
      AdvertisementRepository();

  CreateAdvertisementCubit()
      : super(
          CreateAdvertisementInitial(),
        );

  Future<void> create({
    required String featureFor,
    String? propertyId,
    String? projectId,
  }) async {
    try {
      emit(CreateAdvertisementInProgress());
      final result = await _advertisementRepository.create(
        featureFor: featureFor,
        projectId: projectId ?? '',
        propertyId: propertyId ?? '',
      );

      emit(
        CreateAdvertisementSuccess(
          message: result,
        ),
      );
    } catch (e) {
      emit(CreateAdvertisementFailure(e.toString()));
    }
  }
}
