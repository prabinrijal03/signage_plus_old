import 'dart:async';
import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:slashplus/data/model/devices.dart';
import 'package:slashplus/services/hive_services.dart';
import '../../../../resources/constants.dart';
import '../../../../services/token_services.dart';
import '../../../../services/utils.dart';

part 'token_event.dart';
part 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final Device device;

  bool isTokenPrinting = false;
  bool hasFeedbackOption = false;

  final TokenService tokenService = TokenService();
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();

  final StreamController<AudioEvent> _audioStreamController = StreamController<AudioEvent>.broadcast();
  Stream<AudioEvent> get audioStream => _audioStreamController.stream;

  late StreamSubscription<AudioEvent> audioListener;
  late StreamSubscription<Counter> changeTokenListener;

  Queue<AudioEvent> audioQueue = Queue<AudioEvent>();
  bool isAudioPlaying = false;

  TokenBloc({required this.device}) : super(TokenInitial()) {
    Counters counters = const Counters(counters: []);
    // Issuers issuers = const Issuers(issuers: []);

    on<PlayAudio>((event, emit) async {
      isAudioPlaying = true;
      while (audioQueue.isNotEmpty) {
        final audioEvent = audioQueue.removeFirst();
        await audioPlayer.play(AssetSource('audio/token_number.wav'), mode: PlayerMode.lowLatency);
        await Future.delayed(const Duration(milliseconds: 1200));

        for (int i in audioEvent.tokenIntToPlay) {
          if (i == 0) continue;
          await audioPlayer.play(AssetSource('audio/$i.wav'), mode: PlayerMode.lowLatency);
          await Future.delayed(Duration(milliseconds: i == audioEvent.tokenIntToPlay.last ? 1000 : 700));
        }

        await audioPlayer.play(AssetSource('audio/counter_number.wav'), mode: PlayerMode.lowLatency);
        await Future.delayed(const Duration(milliseconds: 1200));

        for (int i in audioEvent.counterIntToPlay) {
          if (i == 0) continue;
          await audioPlayer.play(AssetSource('audio/$i.wav'), mode: PlayerMode.lowLatency);
          await Future.delayed(const Duration(seconds: 1));
        }

        audioPlayer.release();
        await Future.delayed(const Duration(seconds: 1));
        flutterTts.setSpeechRate(0.4);
        flutterTts.setPitch(1.5);
        await flutterTts.speak(audioEvent.nameToSpeak);
      }
      isAudioPlaying = false;
    });

    on<LoadToken>((event, emit) async {
      if (event.type == AppConstants.layoutToken) {
        final deviceCode = HiveService.getTokenDeviceCode();
        if (deviceCode == null) {
          emit(const TokenButtonEmptyDeviceCode());
        } else {
          final counters = await tokenService.getCounters();

          if (counters == null) {
            emit(const TokenDisplayLoaded(counters: Counters(counters: <Counter>[])));
            return;
          }

          emit(TokenDisplayLoaded(counters: counters));
        }
        try {
          await tokenService.connectDisplaySocket(AppConstants.deviceId ?? "", event.type);
        } catch (e) {
          emit(TokenError(e.toString()));
          return;
        }

        audioStream.listen((event) async {
          audioQueue.add(event);
          if (isAudioPlaying) return;
          add(const PlayAudio());
        });

        tokenService.counterStream.listen((event) {
          add(ChangeToken(counter: event));
        });

        tokenService.deleteCounterStream.listen((event) {
          add(DeleteCounter(id: event));
        });
      }

      if (event.type == AppConstants.layoutTokenButton) {
        final deviceCode = HiveService.getTokenDeviceCode();
        if (deviceCode == null) {
          emit(const TokenButtonEmptyDeviceCode());
        } else {
          emit(TokenButtonLoaded(deviceCode: deviceCode));
        }
        // try {
        //   await tokenService.connectButtonSocket(AppConstants.deviceId ?? "", event.type);
        // } catch (e) {
        //   emit(TokenError(e.toString()));
        //   return;
        // }

        // await HiveService.addDefaultPrinter

        // issuers = tokenService.issuers;
      }
    });

    on<ChangeToken>(
      (event, emit) async {
        if (state is! TokenDisplayLoaded) return;

        final currentState = state as TokenDisplayLoaded;
        emit(TokenInitial());

        final updatedCounters = List<Counter>.from(currentState.counters.counters);
        final index = updatedCounters.indexWhere((element) => element.serverId == event.counter.serverId);
        if (index != -1) {
          updatedCounters[index] = updatedCounters[index].copyWith(number: event.counter.number);
        } else {
          updatedCounters.add(event.counter);
        }
        emit(TokenDisplayLoaded(counters: Counters(counters: updatedCounters)));
        if (event.counter.number == 0) return;
        final tokenIntToPlay = Utils.splitIntegerWithPlaceValues(event.counter.number);
        final counterIntToPlay = Utils.splitIntegerWithPlaceValues(event.counter.serverId ?? 0);

        _audioStreamController
            .add(AudioEvent(tokenIntToPlay: tokenIntToPlay, counterIntToPlay: counterIntToPlay, nameToSpeak: event.counter.applicantName));
      },
    );

    on<DeleteCounter>((event, emit) {
      if (state is! TokenDisplayLoaded) return;

      final currentState = state as TokenDisplayLoaded;
      emit(TokenInitial());

      final updatedCounters = List<Counter>.from(currentState.counters.counters);
      updatedCounters.removeWhere((e) => e.id == event.id);

      emit(TokenDisplayLoaded(counters: Counters(counters: updatedCounters)));
    });

    on<DisconnectToken>((event, emit) async {
      await Future.wait([TokenService().dispose(), audioListener.cancel(), changeTokenListener.cancel()]);
      emit(const TokenError("Disconnected from the device. Please reconnect to continue."));
    });

    on<IncrementToken>((event, emit) {
      emit(TokenInitial());
      emit(TokenDisplayLoaded(counters: counters));
    });
  }

  Future<void> loadToken(String type) async {
    add(LoadToken(type: type));
  }

  void disconnectToken() {
    add(const DisconnectToken());
  }

  void saveDeviceToken(String code) {
    HiveService.addTokenDeviceCode(code);
    add(LoadToken(type: AppConstants.layoutTokenButton));
  }

  Future<bool> incrementToken(BuildContext context, String id) async {
    try {
      await tokenService.counterDio.post(UrlConstants.getCounterCount(id));

      // final String issuserId = res.data["data"]["issuserId"];
      // final int newCount = res.data["data"]["count"];
      // add(ChangeCount(id: issuserId, count: newCount));
      return true;
    } catch (e) {
      if (context.mounted) {
        Utils.showErrSnackbar(context, 'An error occurred. Please try again.');
      }
      return false;
    }
  }
}
