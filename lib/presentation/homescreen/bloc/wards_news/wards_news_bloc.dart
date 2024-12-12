import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/model/ward_details.dart';

part 'wards_news_event.dart';
part 'wards_news_state.dart';

class WardsNewsBloc extends Bloc<WardsNewsEvent, WardsNewsState> {
  List<WardNews> _wardNews = <WardNews>[];

  WardsNewsBloc() : super(WardsNewsLoading()) {
    on<InitializeWardNews>((event, emit) {
      _wardNews = event.wardNews;
      emit(WardsNewsLoaded(_wardNews));
    });
    on<AddWardNews>((event, emit) {
      emit(WardsNewsLoading());
      _wardNews.add(event.wardNews);
      emit(WardsNewsLoaded(_wardNews));
    });
    on<UpdateWardNews>((event, emit) {
      emit(WardsNewsLoading());
      _wardNews[_wardNews.indexWhere((element) => element.id == event.wardNews.id)] = event.wardNews;
      emit(WardsNewsLoaded(_wardNews));
    });

    on<RemoveWardNews>((event, emit) {
      emit(WardsNewsLoading());
      _wardNews.removeWhere((element) => element.id == event.id);
      emit(WardsNewsLoaded(_wardNews));
    });
  }
}
