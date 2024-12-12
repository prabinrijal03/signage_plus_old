import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/model/ward_details.dart';

part 'wards_personnel_event.dart';
part 'wards_personnel_state.dart';

class WardsPersonnelBloc extends Bloc<WardsPersonnelEvent, WardsPersonnelState> {
  List<WardPersonnel> _wardPersonnel = <WardPersonnel>[];
  WardsPersonnelBloc() : super(WardsPersonnelLoading()) {
    on<InitializeWardPersonnel>((event, emit) {
      _wardPersonnel = event.wardPersonnel;
      emit(WardsPersonnelLoaded(_wardPersonnel));
    });
    on<AddWardPersonnel>((event, emit) {
      emit(WardsPersonnelLoading());
      _wardPersonnel.add(event.wardPersonnel);
      emit(WardsPersonnelLoaded(_wardPersonnel));
    });
    on<UpdateWardPersonnel>((event, emit) {
      emit(WardsPersonnelLoading());
      _wardPersonnel[_wardPersonnel.indexWhere((element) => element.id == event.wardPersonnel.id)] = event.wardPersonnel;
      emit(WardsPersonnelLoaded(_wardPersonnel));
    });

    on<RemoveWardPersonnel>((event, emit) {
      emit(WardsPersonnelLoading());
      _wardPersonnel.removeWhere((element) => element.id == event.id);
      emit(WardsPersonnelLoaded(_wardPersonnel));
    });
  }
}
