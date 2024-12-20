import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slashplus/core/dependency_injection.dart';
import 'package:slashplus/data/model/user_information.dart';
import 'package:slashplus/services/hive_services.dart';
import '../../../data/model/device_layout.dart';

import '../../../data/usecases/generate_token.dart';
import '../../../resources/color_manager.dart';
import '../../../resources/constants.dart';
import '../../../services/utils.dart';
import '../bloc/token/token_bloc.dart';

class TokenButtonWidget extends StatefulWidget {
  final DeviceLayout layoutInfo;
  const TokenButtonWidget({super.key, required this.layoutInfo});

  @override
  State<TokenButtonWidget> createState() => _TokenButtonWidgetState();
}

class _TokenButtonWidgetState extends State<TokenButtonWidget> {
  late final TextEditingController _deviceCodeController;

  @override
  void initState() {
    super.initState();
    _deviceCodeController = TextEditingController(text: HiveService.getTokenDeviceCode());
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
        child: SizedBox(
          height: double.maxFinite,
          child: BlocBuilder<TokenBloc, TokenState>(
            builder: (context, state) {
              if (state is TokenInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorManager.secondary),
                );
              }
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
              if (state is TokenButtonLoaded) {
                const String qrString =
                    '1:4dbb23a8-b525-4a91-8954-a7fc153b57e2;2:PP;3:PP_RENEWAL;4:DOP;5:2024-06-09 12:00;7:30017006350;8:2070-06-06;9:KVR;11:0138132708;12:LAMA TAMANG;13:BINOD;14:M;15:1996-03-03;16:2052-11-20;17:KVR;18:NPL;19:+977 9860776914;20:binodghongba@gmail.com;22:RAYALE;23:01;24:KVR-PNT00A;25:KVR;26:BGM;27:NPL;28:TAMANG;29:TIRTHA BAHADUR;30:TAMANG;31:CHINI MAYA;32:NPL;33:09935553;34:2016-08-07;35:KVK;43:TAMANG;44:CHINI MAYA;46:RAYALE;47:01;48:KVR-PNT00A;49:KVR;50:BGM;51:NPL;52:9745962792;CHECKSUM:68a80443fdc90eab6b869b2984cda0443489c9b5fc98225da51a3bb7593b2e22;';

                List<String> keyValuePairs = qrString.split(';');

                Map<String, String> dataMap = {};

                for (String pair in keyValuePairs) {
                  int delimiterIndex = pair.indexOf(':');
                  if (delimiterIndex != -1) {
                    String key = pair.substring(0, delimiterIndex).trim();
                    String value = pair.substring(delimiterIndex + 1).trim();
                    dataMap[key] = value;
                  }
                }

                return SingleChildScrollView(
                  child: SizedBox(
                    height: AppConstants.deviceHeight * 0.9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              showDialog(context: context, builder: (context) => const EditDeviceCodePopup());
                            },
                            icon: const Icon(Icons.edit)),
                        SizedBox(height: AppConstants.deviceHeight * 0.2),
                        Column(
                          children: [
                            const Text("User Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                            const SizedBox(height: 30),
                            const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${dataMap['13']} ${dataMap['12']}'),
                            const SizedBox(height: 10),
                            const Text('Allotted Date and Time', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${dataMap['5']}'),
                          ],
                        ),
                        const Spacer(),
                        const AutoSizeText(
                          "Generate Token\nटोकन लिनुहोस्",
                          minFontSize: 20,
                          maxFontSize: 20,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  side: const BorderSide(width: 1.0, color: Colors.green),
                                  backgroundColor: Colors.green,
                                  // backgroundColor: e.settings?.backgroundColor.toColor ?? Colors.green,
                                  elevation: 0,
                                  fixedSize: Size(AppConstants.deviceWidth * 0.25, AppConstants.deviceHeight * 0.12)),
                              onPressed: () async {
                                if (dataMap['1'] == null || dataMap['5'] == null) {
                                  Utils.showErrSnackbar(context, "Invalid Data");
                                  return;
                                }
                                // final result = await BluetoothThermalPrinter.connectionStatus == "true";

                                // if (!result && context.mounted) {
                                //   Utils.showErrSnackbar(context, "Please connect to a printer");
                                //   return;
                                // }
                                if (context.mounted) {
                                  if (context.read<TokenBloc>().isTokenPrinting) {
                                    Utils.showErrSnackbar(context, "Printing in progress. Please wait...");
                                    return;
                                  }
                                  context.read<TokenBloc>().isTokenPrinting = true;
                                  String id = dataMap['1']!;
                                  String name = '${dataMap['13']} ${dataMap['12']}';
                                  final slotStart = DateTime.parse(dataMap['5']!);
                                  final ApplicantInfoRequest info = ApplicantInfoRequest(
                                    applicationId: id,
                                    applicantName: name,
                                    slotStart: slotStart,
                                  );

                                  final res = await getInstance<GenerateToken>().call(info);

                                  res.fold((error) {
                                    Utils.showErrSnackbar(context, error.message);
                                    if (context.mounted) context.read<TokenBloc>().isTokenPrinting = false;
                                  }, (token) {
                                    Utils.printTokenTicket(
                                        'Passport Office', token.number.toString(), token.prioritizeAfter, token.issuedAt == token.prioritizeAfter);
                                    Future.delayed(const Duration(seconds: 2), () {
                                      if (context.mounted) context.read<TokenBloc>().isTokenPrinting = false;
                                    });
                                  });
                                }
                              },
                              child: const AutoSizeText(
                                "Generate Token",
                                minFontSize: 20,
                                maxFontSize: 30,
                                // style: TextStyle(color: e.settings?.textColor.toColor ?? ColorManager.white),
                                style: TextStyle(color: ColorManager.white),
                                textAlign: TextAlign.center,
                              )),
                        ),
                      ],
                    ),
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
        ));
  }
}

class EditDeviceCodePopup extends StatefulWidget {
  const EditDeviceCodePopup({super.key});

  @override
  State<EditDeviceCodePopup> createState() => _EditDeviceCodePopupState();
}

class _EditDeviceCodePopupState extends State<EditDeviceCodePopup> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: HiveService.getTokenDeviceCode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: textEditingController,
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
            onPressed: () {
              HiveService.addTokenDeviceCode(textEditingController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              side: const BorderSide(width: 1.0, color: Colors.green),
              backgroundColor: Colors.green,
              elevation: 0,
            ),
            child: const Text('Edit Code'),
          )
        ]),
      ),
    );
  }
}
