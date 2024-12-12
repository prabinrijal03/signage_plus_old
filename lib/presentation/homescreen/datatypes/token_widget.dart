import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slashplus/resources/color_manager.dart';

import '../../../data/model/device_layout.dart';
import '../../../resources/constants.dart';
import '../bloc/token/token_bloc.dart';
import '../widgets/token_viewer.dart';

class TokenWidget extends StatefulWidget {
  final DeviceLayout layoutInfo;
  const TokenWidget({super.key, required this.layoutInfo});

  @override
  State<TokenWidget> createState() => _TokenWidgetState();
}

class _TokenWidgetState extends State<TokenWidget> {
  late final TextEditingController _deviceCodeController;

  @override
  void initState() {
    super.initState();
    _deviceCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _deviceCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.layoutInfo.flex ?? 1,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<TokenBloc, TokenState>(
          builder: (context, state) {
            if (state is TokenButtonEmptyDeviceCode) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _deviceCodeController,
                      decoration: InputDecoration(
                          labelText: "Device Code",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: ColorManager.secondary),
                          )),
                      keyboardType: TextInputType.text,
                      autofocus: true,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => context.read<TokenBloc>().saveDeviceToken(_deviceCodeController.text),
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(width: 1.0, color: Colors.green),
                        backgroundColor: Colors.green,
                        elevation: 0,
                      ),
                      child: const Text('Save Code'),
                    )
                  ],
                ),
              );
            }
            if (state is TokenInitial) {
              return const SizedBox(
                  height: double.maxFinite,
                  child: Center(
                    child: CircularProgressIndicator(color: ColorManager.secondary),
                  ));
            }
            if (state is TokenDisplayLoaded) {
              var itemCount = state.counters.counters.length;
              state.counters.counters.sort((a, b) {
                return a.serverId!.compareTo(b.serverId!);
              });

              Map<int, (int, double)> itemCountRatio = {
                1: (1, 0.8),
                2: (1, 1.9),
                3: (2, 0.94),
                4: (2, 0.94),
                5: (2, 1.4),
                6: (2, 1.4),
                7: (3, 0.93),
                8: (3, 0.93),
                9: (3, 0.93),
              };

              return Center(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: itemCountRatio[itemCount]?.$1 ?? 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: itemCountRatio[itemCount]?.$2 ?? 0.8,
                  children: List.generate(itemCount, (index) {
                    final i = index % itemCount;
                    return TokenViewer(counter: state.counters.counters[i]);
                  }),
                ),
              );
            }
            if (state is TokenError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/no_internet.png', height: AppConstants.deviceHeight * 0.3),
                  Divider(
                    height: 20,
                    thickness: 1,
                    endIndent: AppConstants.deviceWidth * 0.35,
                    indent: AppConstants.deviceWidth * 0.35,
                    color: ColorManager.primary,
                  ),
                  SizedBox(height: AppConstants.deviceHeight * 0.02),
                  const Text('Could not communicate with the servers',
                      style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Please check the server and try again!', style: TextStyle(color: Colors.black, fontSize: 18)),
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
