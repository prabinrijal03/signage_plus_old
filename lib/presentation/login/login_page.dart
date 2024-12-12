import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/dependency_injection.dart';
import '../../resources/asset_manager.dart';
import '../../resources/color_manager.dart';
import '../../resources/constants.dart';
import 'cubit/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final passwordFocusNode = FocusNode(debugLabel: 'login_code');
    final buttonFocusNode = FocusNode(debugLabel: 'login');

    return BlocProvider(
      create: (context) => LoginCubit(loginDevice: getInstance()),
      child: Scaffold(
          backgroundColor: ColorManager.black,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: AppConstants.deviceHeight / 1.5,
                        width: AppConstants.deviceWidth / 3,
                        decoration: const BoxDecoration(
                          color: ColorManager.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                        ),
                        child: BlocConsumer<LoginCubit, LoginState>(
                          listener: (context, state) {
                            if (state is LoginSuccess) {
                              Navigator.pushReplacementNamed(
                                  context, "/homescreen",
                                  arguments: state.device);
                            }
                          },
                          builder: (context, state) {
                            if (state is LoginLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state is LoginInitial) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: AppConstants.deviceHeight / 20,
                                    horizontal: AppConstants.deviceWidth / 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Welcome",
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold)),
                                    const Text("Please enter your details",
                                        style: TextStyle(fontSize: 15)),
                                    SizedBox(
                                        height: AppConstants.deviceHeight / 30),
                                    SizedBox(
                                        height: AppConstants.deviceHeight / 30),
                                    TextField(
                                      focusNode: passwordFocusNode,
                                      controller: context
                                          .read<LoginCubit>()
                                          .loginCodeController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Login Code',
                                      ),
                                      onEditingComplete: () =>
                                          buttonFocusNode.requestFocus(),
                                    ),
                                    if ((state).error != null) ...[
                                      SizedBox(
                                          height:
                                              AppConstants.deviceHeight / 30),
                                      Text(state.error!,
                                          style: const TextStyle(
                                              color: ColorManager.errorRed)),
                                    ],
                                    SizedBox(
                                        height: AppConstants.deviceHeight / 30),
                                    Focus(
                                      onKey: (node, event) {
                                        if (event is RawKeyDownEvent &&
                                            event.logicalKey ==
                                                LogicalKeyboardKey.select) {
                                          context.read<LoginCubit>().login();
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                      child: ElevatedButton(
                                        focusNode: buttonFocusNode,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              ColorManager.secondary,
                                          fixedSize: Size(
                                              AppConstants.deviceWidth / 3,
                                              AppConstants.deviceHeight / 20),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 50, vertical: 10),
                                          textStyle:
                                              const TextStyle(fontSize: 15),
                                        ),
                                        onPressed: () =>
                                            context.read<LoginCubit>().login(),
                                        child: const Text('Login'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                      Container(
                        height: AppConstants.deviceHeight / 1.5,
                        width: AppConstants.deviceWidth / 3,
                        decoration: const BoxDecoration(
                          color: ColorManager.grey,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Container(
                          padding:
                              EdgeInsets.all(AppConstants.deviceHeight / 7),
                          child: SvgPicture.asset(SvgAssets.logo),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
