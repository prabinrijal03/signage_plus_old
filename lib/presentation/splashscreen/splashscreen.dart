import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/dependency_injection.dart';
import '../../resources/color_manager.dart';
import '../../resources/constants.dart';
import 'cubit/splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(hiveService: getInstance())..init(context),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {},
        child: Scaffold(
          backgroundColor: ColorManager.grey,
          body: Center(
              child: Column(
            children: [
              const Spacer(),
              SvgPicture.asset("assets/images/logo.svg", height: AppConstants.deviceHeight * 0.4),
              SizedBox(height: AppConstants.deviceHeight * 0.15),
              const CircularProgressIndicator(color: ColorManager.secondary),
              SizedBox(height: AppConstants.deviceHeight * 0.1),
            ],
          )),
        ),
      ),
    );
  }
}
