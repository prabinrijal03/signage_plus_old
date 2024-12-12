import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slashplus/data/model/feedback_request.dart';
import 'package:slashplus/presentation/homescreen/bloc/feedback/feedback_cubit.dart';
import 'package:slashplus/resources/color_manager.dart';
import 'package:slashplus/resources/constants.dart';
import 'package:slashplus/services/hive_services.dart';
// import 'package:slashplus/services/utils.dart';

import '../../../data/model/feedback_questions.dart';

List<String> feedbacks = ['एकदम खराब', "खराब", "न्यून", "राम्रो", "अत्यन्तै राम्रो"];

class FlipFeedbackWidget extends StatelessWidget {
  final Widget child;
  final FeedbackCubit feedbackCubit;
  final bool showFrontSide;

  const FlipFeedbackWidget({super.key, required this.child, required this.feedbackCubit, required this.showFrontSide});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        transitionBuilder: _transitionBuilder,
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        switchInCurve: Curves.easeInBack,
        switchOutCurve: Curves.easeInBack.flipped,
        child: showFrontSide
            ? SizedBox(
                key: ValueKey(showFrontSide),
                child:
                    // Stack(
                    //   children: [
                    //     child,
                    //     Positioned(
                    //       bottom: 20,
                    //       child: ElevatedButton(
                    //           style: ElevatedButton.styleFrom(
                    //               backgroundColor: ColorManager.secondary.withOpacity(0.6),
                    //               shape: const RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)))),
                    //           onPressed: () => feedbackCubit.flipCard(),
                    //           child: Padding(
                    //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //             child: Column(
                    //               children: [
                    //                 const Text("Want to give a feedback ?", style: TextStyle(fontSize: 20, color: ColorManager.black)),
                    //                 SvgPicture.asset('assets/images/feedback.svg', height: 40),
                    //               ],
                    //             ),
                    //           )),
                    //     ),
                    //   ],
                    // ))
                    Row(
                  children: [
                    Expanded(flex: 3, child: child),
                    Container(
                      width: AppConstants.deviceWidth * 0.25,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/images/feedback_banner.png'),
                        fit: BoxFit.cover,
                      )),
                      child: Column(
                        children: [
                          const Spacer(),
                          const Text(
                            "We value your feedback\non our service",
                            style: TextStyle(fontSize: 20, color: ColorManager.white, height: 1.1),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppConstants.deviceHeight * 0.03),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            onPressed: () => feedbackCubit.flipCard(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text("Get Started", style: TextStyle(fontSize: 20, color: ColorManager.white)),
                            ),
                          ),
                          SizedBox(height: AppConstants.deviceHeight * 0.08),
                        ],
                      ),
                    )
                  ],
                ))
            : _buildFeedbackForm(context));
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(showFrontSide) != widget?.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: (Matrix4.rotationY(value)..setEntry(3, 0, tilt)),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  Widget _buildFeedbackForm(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: ColorManager.white,
          key: ValueKey(showFrontSide),
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset('assets/images/bank_banner.png', height: AppConstants.deviceHeight * 0.1)),
              const Divider(thickness: 10, color: ColorManager.darkRed),

              const SizedBox(height: 40),
              // Expanded(
              //   child: ListView.builder(
              //       padding: EdgeInsets.symmetric(horizontal: AppConstants.deviceWidth * 0.03),
              //       itemCount: feedbackCubit.feedbackQuestions.feedbackQuestions.length + 2,
              //       itemBuilder: (context, index) {
              //         if (index == 0) {
              //           return Row(
              //             children: [
              //               SizedBox(width: AppConstants.deviceWidth * 0.25),
              //               for (int i = 1; i <= 5; i++) ...[
              //                 const Spacer(),
              //                 SizedBox(width: AppConstants.deviceWidth * 0.04, child: Image.asset('assets/images/$i.png', height: 30)),
              //               ]
              //             ],
              //           );
              //         }
              //         if (index == feedbackCubit.feedbackQuestions.feedbackQuestions.length + 1) {
              //           return ElevatedButton(
              //               onPressed: () async {
              //                 showDialog(
              //                   context: context,
              //                   builder: (context) => InputPersonalInformationDialog(feedbackCubit: feedbackCubit),
              //                 );
              //               },
              //               child: const Text("Next"));
              //         }
              //         return QuestionsRadioButtonRow(
              //             feedbackQuestions: feedbackCubit.feedbackQuestions.feedbackQuestions, index: index, feedbackCubit: feedbackCubit);
              //       }),
              // ),
              Expanded(
                  child: Column(
                children: [
                  Column(
                    children: [
                      const Text(
                        "तपाईलाई हाम्रो सेवा कस्तो लाग्यो ?",
                        style: TextStyle(fontSize: 50),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          for (int i = 1; i <= 5; i++) ...[
                            Expanded(
                                child: GestureDetector(
                              onTap: () => feedbackCubit.selectFeedbackIndex(i - 1),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (feedbackCubit.selectedFeedbackIndex == i - 1)
                                        const CircleAvatar(radius: 47, backgroundColor: ColorManager.secondary),
                                      Image.asset('assets/images/$i.png', height: 100),
                                    ],
                                  ),
                                  Text(feedbacks.elementAt(i - 1), style: const TextStyle(fontSize: 25)),
                                ],
                              ),
                            )),
                          ]
                        ],
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            fixedSize: const Size(150, 50),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            if ((context.read<FeedbackCubit>().state as FeedbackLoaded).selectedFeedbackIndex == null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.error_outline_outlined, color: Colors.white, size: 24),
                                    SizedBox(width: 20),
                                    Text(
                                      "Please select a feedback",
                                      style: TextStyle(color: ColorManager.white, fontSize: 24),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                width: AppConstants.deviceWidth * 0.5,
                                backgroundColor: ColorManager.darkRed,
                                behavior: SnackBarBehavior.floating,
                              ));
                              return;
                            }
                            showDialog(
                              context: context,
                              builder: (context) => InputPersonalInformationDialog(feedbackCubit: feedbackCubit),
                            );
                          },
                          child: const Text("Next")),
                    ],
                  ),
                ],
              )),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 20,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ColorManager.darkRed, shape: const CircleBorder()),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Are you sure you want to cancel?"),
                    content: const Text("Your feedback will not be submitted."),
                    actions: [
                      ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                      ElevatedButton(
                        onPressed: () => feedbackCubit.reset(context),
                        style: ElevatedButton.styleFrom(backgroundColor: ColorManager.errorRed),
                        child: const Text("Yes"),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.close)),
        ),
      ],
    );
  }
}

class InputPersonalInformationDialog extends StatefulWidget {
  const InputPersonalInformationDialog({super.key, required this.feedbackCubit});

  final FeedbackCubit feedbackCubit;

  @override
  State<InputPersonalInformationDialog> createState() => _InputPersonalInformationDialogState();
}

class _InputPersonalInformationDialogState extends State<InputPersonalInformationDialog> {
  bool isLoading = false;
  bool isSubmitted = false;
  String ticketNumber = 'Error!';

  @override
  void initState() {
    super.initState();
    widget.feedbackCubit.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (isSubmitted) {
      return AlertDialog(
        title: const Text("Thank you for your feedback!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your feedback has been submitted successfully.${ticketNumber.trim().isNotEmpty ? "\nYour ticket number is $ticketNumber." : ''}"),
            const SizedBox(height: 20),
            const TimerText(),
          ],
        ),
        actions: [ElevatedButton(onPressed: () => widget.feedbackCubit.reset(context), child: const Text("Close"))],
      );
    }
    return AlertDialog(
      elevation: 0,
      title: const Text("Please input your personal information"),
      content: SizedBox(
        height: AppConstants.deviceHeight * 0.3,
        width: AppConstants.deviceWidth * 0.8,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: ColorManager.secondary, strokeWidth: 3))
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: "Name (Optional)",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: ColorManager.secondary),
                                )),
                            controller: widget.feedbackCubit.nameTextController,
                            keyboardType: TextInputType.text,
                            autofocus: true,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: "Email (Optional)",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: ColorManager.secondary),
                                )),
                            controller: widget.feedbackCubit.emailTextController,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: "Phone Number (Optional)",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: ColorManager.secondary),
                                )),
                            controller: widget.feedbackCubit.phoneTextController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "What should we change in order to live up to your expectations?",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: ColorManager.secondary),
                          )),
                      controller: widget.feedbackCubit.noteTextController,
                      maxLines: 8,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Are you sure you want to cancel?"),
                                content: const Text("Your feedback will not be submitted."),
                                actions: [
                                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: ColorManager.errorRed),
                                    child: const Text("Yes"),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: ColorManager.darkRed, fixedSize: const Size(100, 20)),
                          child: const Text("Cancel", style: TextStyle(color: ColorManager.white))),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () async {
                            final FeedbackRequest feedbackRequest = FeedbackRequest(
                              name: widget.feedbackCubit.nameTextController.text.isNotEmpty ? widget.feedbackCubit.nameTextController.text : null,
                              email: widget.feedbackCubit.emailTextController.text.isNotEmpty ? widget.feedbackCubit.emailTextController.text : null,
                              phone: widget.feedbackCubit.phoneTextController.text.isNotEmpty ? widget.feedbackCubit.phoneTextController.text : null,
                              answers: widget.feedbackCubit.answers,
                              message: widget.feedbackCubit.noteTextController.text.isNotEmpty ? widget.feedbackCubit.noteTextController.text : null,
                              orgId: HiveService().getOrganizationId() ?? 'err',
                            );
                            setState(() => isLoading = true);
                            final result = await widget.feedbackCubit.submitFeedback(feedbackRequest);

                            Future.delayed(const Duration(seconds: 5), () {
                              widget.feedbackCubit.reset(context);
                            });

                            result.fold((left) {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("There was an error processing your request. Please try again later.\nError: ${left.message}")));
                              Navigator.pop(context);
                            },
                                (right) => setState(() {
                                      ticketNumber = right;
                                      isLoading = false;
                                      isSubmitted = true;
                                    }));

                            // if ((widget.feedbackCubit.phoneTextController.text.isNotEmpty ||
                            //     widget.feedbackCubit.emailTextController.text.isNotEmpty)) {
                            //   final res = await Utils.printFeedbackTicket(ticketNumber, widget.feedbackCubit.deviceName);
                            //   if (!res && context.mounted) {
                            //     ScaffoldMessenger.of(context)
                            //         .showSnackBar(const SnackBar(content: Text("There was an error printing your ticket number")));
                            //   }
                            // }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, fixedSize: const Size(100, 20)),
                          child: const Text("Submit", style: TextStyle(color: ColorManager.black))),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class TimerText extends StatefulWidget {
  const TimerText({super.key});

  @override
  State<TimerText> createState() => TimerTextState();
}

class TimerTextState extends State<TimerText> {
  int _counter = 5;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() {
          _counter--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('This dialog will close in ${_counter.toString()} seconds',
        style: const TextStyle(color: ColorManager.darkRed, fontSize: 20, fontWeight: FontWeight.w700));
  }
}

class QuestionsRadioButtonRow extends StatefulWidget {
  const QuestionsRadioButtonRow({
    super.key,
    required this.feedbackQuestions,
    required this.index,
    required this.feedbackCubit,
  });

  final List<FeedbackQuestion> feedbackQuestions;
  final FeedbackCubit feedbackCubit;
  final int index;

  @override
  State<QuestionsRadioButtonRow> createState() => _QuestionsRadioButtonRowState();
}

class _QuestionsRadioButtonRowState extends State<QuestionsRadioButtonRow> {
  int? selectedValue;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: AppConstants.deviceWidth * 0.25, child: Text(widget.feedbackQuestions[widget.index - 1].question)),
        for (int i = 1; i <= 5; i++) ...[
          const Spacer(),
          SizedBox(
              width: AppConstants.deviceWidth * 0.04,
              child: Center(
                  child: Radio(
                value: i,
                groupValue: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value ?? 3;
                    widget.feedbackCubit.addAnswer(widget.feedbackQuestions[widget.index - 1].id, value ?? 3);
                  });
                },
              ))),
        ],
      ],
    );
  }
}
