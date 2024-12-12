import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/device_layout.dart';
import '../../../resources/constants.dart';
import '../cubit/quiz/quiz_cubit.dart';
import '../home_screen.dart';

class QuizWidget extends StatelessWidget {
  final DeviceLayout layoutInfo;
  final GlobalKey<FormState> formStateKey;
  const QuizWidget({super.key, required this.layoutInfo, required this.formStateKey});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizCubit(),
      child: Expanded(
        flex: layoutInfo.flex ?? 1,
        child: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) {
            if (state is QuizInitial) {
              return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text("Start a Quiz",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          )),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Form(
                          key: formStateKey,
                          child: TextFormField(
                            controller: context.read<QuizCubit>().nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Please enter your name";
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              labelText: 'Enter your name',
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            side: const BorderSide(width: 1.0, color: Colors.green),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.green,
                            elevation: 0,
                            fixedSize: Size(AppConstants.deviceWidth * 0.25, AppConstants.deviceHeight * 0.15)),
                        onPressed: () {
                          if (formStateKey.currentState!.validate()) {
                            context.read<QuizCubit>().startQuiz();
                          }
                        },
                        child: const Text("Start Quiz", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ));
            }

            if (state is QuizPlaying) {
              return QuizPlayingWidget(state: state);
            }

            if (state is QuizFinished) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Congratulations ${state.name}! You have finished the quiz.",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text("Score: ${state.score}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        side: const BorderSide(width: 1.0, color: Colors.green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.green,
                        elevation: 0,
                        fixedSize: Size(AppConstants.deviceWidth * 0.25, AppConstants.deviceHeight * 0.15)),
                    onPressed: () => context.read<QuizCubit>().resetQuiz(),
                    child: const Text("Start Again"),
                  )
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
