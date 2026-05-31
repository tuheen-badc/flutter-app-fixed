import 'package:demo_app/core/usecase/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'complaint_state.dart';

class ComplaintCubit extends Cubit<ComplaintState> {
  ComplaintCubit() : super(ComplaintInitialState());

  void submitComplaint({required UseCase useCase, dynamic params}) async {
    emit(ComplaintSubmittingState());

    try {
      var result = await useCase.call(param: params);

      result.fold(
        (error) {
          emit(ComplaintErrorState(errorMessage: error));
        },
        (data) {
          emit(
            ComplaintSubmittedState(
              message: 'Complaint submitted successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(ComplaintErrorState(errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(ComplaintInitialState());
  }
}
