import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/common/bloc/water_usages_report/water_usages_report_state.dart';
import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class WaterUsageReportCubit extends Cubit<WaterUsageReportState> {
  WaterUsageReportCubit() : super(WaterUsageReportInitialState());

  Future<void> downloadReport({
    required UseCase useCase,
    required dynamic params,
  }) async {
    final criteria = params;
    emit(
      WaterUsageReportLoadingState(month: criteria.month, year: criteria.year),
    );

    try {
      Either result = await useCase.call(param: params);
      result.fold(
        (error) {
          emit(WaterUsageReportErrorState(errorMessage: error));
        },
        (data) async {
          // data is the bytes from the Excel file
          final bytes = data as List<int>;

          // Generate file name
          final fileName =
              'water_usage_report_${criteria.year}_${criteria.month.toString().padLeft(2, '0')}.xlsx';

          // Save file to device
          final filePath = await _saveFile(bytes, fileName);

          if (filePath != null) {
            emit(
              WaterUsageReportSuccessState(
                month: criteria.month,
                year: criteria.year,
                fileName: fileName,
              ),
            );
          } else {
            emit(
              WaterUsageReportErrorState(errorMessage: 'Failed to save file'),
            );
          }
        },
      );
    } catch (e) {
      emit(WaterUsageReportErrorState(errorMessage: e.toString()));
    }
  }

  Future<String?> _saveFile(List<int> bytes, String fileName) async {
    try {
      if (kIsWeb) {
        // On web, saveFile initiates a browser download and returns null.
        await FilePicker.saveFile(
          fileName: fileName,
          bytes: Uint8List.fromList(bytes),
        );
        return fileName; // Return filename as success indicator for Web
      }

      if (Platform.isAndroid || Platform.isIOS) {
        // Use FilePicker to allow the user to save to the public Downloads folder
        // This is the most reliable way on Android 11+ and iOS
        return await FilePicker.saveFile(
          fileName: fileName,
          bytes: Uint8List.fromList(bytes),
        );
      } else {
        // For Desktop (Windows/macOS/Linux)
        final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return filePath;
      }
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  void resetState() {
    emit(WaterUsageReportInitialState());
  }
}
