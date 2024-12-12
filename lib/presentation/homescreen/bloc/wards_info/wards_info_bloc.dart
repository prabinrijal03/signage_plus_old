import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/model/ward_details.dart';
import '../../../../data/usecases/download_video.dart';
import '../../../../resources/constants.dart';
import '../../../../services/hive_services.dart';
import '../../../../services/socket_services.dart';
import '../../../../services/utils.dart';

part 'wards_info_event.dart';
part 'wards_info_state.dart';

class WardsInfoBloc extends Bloc<WardsInfoEvent, WardsInfoState> {
  List<WardInfo> _wardInfo = <WardInfo>[];
  List<WardContent>? _wardContent;

  final Donwload downloadVideo;
  WardsInfoBloc({required this.downloadVideo}) : super(WardsInfoLoading()) {
    on<InitializeWardInfo>((event, emit) {
      init();
      _wardInfo = event.wardInfo;

      _wardContent = event.wardContent.where((element) {
        final now = DateTime(AppConstants.now.year, AppConstants.now.month, AppConstants.now.day, AppConstants.now.hour, AppConstants.now.minute);
        final startDate = element.startDate;
        final endDate = element.endDate;
        return now.isAfter(startDate) && now.isBefore(endDate) && element.status;
      }).toList();

      emit(WardsInfoLoaded(_wardInfo, wardContent));
    });

    on<AddWardInfo>((event, emit) {
      _wardInfo.add(event.wardInfo);
      emit(WardsInfoLoading());
      emit(WardsInfoLoaded(_wardInfo, wardContent));
    });
    on<UpdateWardInfo>((event, emit) {
      _wardInfo[_wardInfo.indexWhere((element) => element.id == event.wardInfo.id)] = event.wardInfo;
      emit(WardsInfoLoading());
      emit(WardsInfoLoaded(_wardInfo, wardContent));
    });

    on<RemoveWardInfo>((event, emit) {
      try {
        final deletedInfo = _wardInfo.firstWhere((element) => element.id == event.id);

        final deletedOrder = deletedInfo.order;
        _wardInfo.removeWhere((element) => element.id == event.id);

        for (WardInfo info in _wardInfo) {
          if (info.order > deletedOrder) {
            info.order--;
          }
        }
      } on StateError catch (_) {}
      emit(WardsInfoLoading());
      emit(WardsInfoLoaded(_wardInfo, wardContent));
    });

    on<WardOrderChanged>((event, emit) {
      for (WardInfo info in _wardInfo) {
        info.order = event.wardOrder[info.id] ?? info.order;
      }
      _wardInfo.sort((a, b) => a.order.compareTo(b.order));
      emit(WardsInfoLoading());
      emit(WardsInfoLoaded(_wardInfo, wardContent));
    });

    on<AddWardContent>((event, emit) async {
      List<String> imageUrls = [];
      List<String> videoUrls = [];

      if (event.wardContent.type == 'video') {
        videoUrls.add(event.wardContent.source);
      } else {
        imageUrls.add(event.wardContent.source);
      }
      await Utils.downloadWardContents(downloadVideo, imageUrls, videoUrls);

      HiveService().addWardContentsToBox([event.wardContent]);
      _wardContent?.add(event.wardContent);
      emit(WardsInfoLoaded(_wardInfo, wardContent));
    });

    on<UpdateWardContent>((event, emit) {
      HiveService().updateWardContentInBox([event.wardContent]);
      _wardContent?[_wardContent!.indexWhere((element) => element.id == event.wardContent.id)] = event.wardContent;
      emit(WardsInfoLoaded(_wardInfo, wardContent));
    });

    on<RemoveWardContent>((event, emit) {
      HiveService().deleteWardContentFromBox(event.id);
      _wardContent?.removeWhere((element) => element.id == event.id);
      emit(WardsInfoLoaded(_wardInfo, wardContent));
    });
  }

  void init() {
    SocketService().wardOrder.listen((event) {
      add(WardOrderChanged(event));
    });
  }

  List<WardContent> get wardContent {
    return _wardContent ?? <WardContent>[];
  }
}
