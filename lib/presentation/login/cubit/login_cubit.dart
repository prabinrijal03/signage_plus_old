import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/devices.dart';

import '../../../data/usecases/login_device.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginDevice loginDevice;
  LoginCubit({required this.loginDevice}) : super(const LoginInitial());

  final TextEditingController loginCodeController =
      TextEditingController(text: kDebugMode ? 'VM994X' : null);

  Future<void> login() async {
    emit(LoginLoading());
    final result =
        await loginDevice(Params(loginCode: loginCodeController.text));
    result.fold(
      (failure) => emit(LoginInitial(error: failure.message)),
      (device) async {
        emit(LoginSuccess(device));
      },
    );
  }
}
