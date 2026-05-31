// firmware_upload_cubit.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/firmware_upload/firmware_upload_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FirmwareUploadCubit extends Cubit<FirmwareUploadState> {
  FirmwareUploadCubit() : super(FirmwareUploadInitialState());

  void uploadFirmware({required UseCase useCase, dynamic params}) async {
    emit(FirmwareUploadLoadingState());
    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(FirmwareUploadErrorState(errorMessage: error));
        },
        (data) {
          emit(
            FirmwareUploadSuccessState(
              message: 'Firmware uploaded successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(FirmwareUploadErrorState(errorMessage: e.toString()));
    }
  }

  void resetState() {
    emit(FirmwareUploadInitialState());
  }
}
