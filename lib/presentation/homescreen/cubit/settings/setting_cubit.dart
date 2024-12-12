import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:slashplus/services/hive_services.dart';

class BluetoothConnectionPage extends StatefulWidget {
  const BluetoothConnectionPage({super.key});

  @override
  State<BluetoothConnectionPage> createState() => _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  List<dynamic>? device = [];
  bool isBluetoothConnecting = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getBluetoothDevices();
  }

  void getBluetoothDevices() async {
    final bluetooth = await BluetoothThermalPrinter.getBluetooths;
    device = bluetooth;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) => ListTile(
              title: Text(device?.elementAt(index).toString().split('#').first ?? 'err'),
              onTap: () async {
                final mac = device?.elementAt(index).toString().split('#').last ?? "err";
                await BluetoothThermalPrinter.connect(mac);
                HiveService.addDefaultPrinter(mac);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            itemCount: device?.length ?? 0,
          );
  }
}
