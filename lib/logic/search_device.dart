import 'dart:convert';
import 'package:app_rafa/screens/bluetooth/widgets/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchDevice extends StatefulWidget {
  SearchDevice({super.key});

  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  String get voltageValue => '';

  @override
  SearchDeviceState createState() => SearchDeviceState();
}

class SearchDeviceState extends State<SearchDevice> {
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];
  String voltageValue = '';

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  _initBluetooth() async {
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          for (ScanResult result in results) {
            _addDeviceTolist(result.device);
          }
        }
      },
      onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      ),
    );

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan();

    await FlutterBluePlus.isScanning.where((val) => val == false).first;
    FlutterBluePlus.connectedDevices.map((device) {
      _addDeviceTolist(device);
    });
  }

  @override
  void initState() {
    () async {
      var status = await Permission.location.status;
      if (status.isDenied) {
        final status = await Permission.location.request();
        if (status.isGranted || status.isLimited) {
          _initBluetooth();
        }
      } else if (status.isGranted || status.isLimited) {
        _initBluetooth();
      }

      if (await Permission.location.status.isPermanentlyDenied) {
        openAppSettings();
      }
    }();
    super.initState();
  }

  Container connectToDevice() {
    return Container(
        child: Center(
            child: ElevatedButton(
                onPressed: () async {
                  for (BluetoothDevice device in widget.devicesList) {
                    if (device.advName == 'LAMANIOSA') {
                      FlutterBluePlus.stopScan();
                      try {
                        await device.connect();
                      } on PlatformException catch (e) {
                        if (e.code != 'already_connected') {
                          rethrow;
                        }
                      } finally {
                        _services = await device.discoverServices();
                      }
                      setState(() {
                        _connectedDevice = device;
                      });
                    }
                  }
                },
                child: const Text('Connect'))));
  }

  ElevatedButton buildNotifyButton(BluetoothCharacteristic characteristic) {
    ElevatedButton button =
        ElevatedButton(onPressed: () {}, child: const Text(''));
    if (characteristic.properties.notify) {
      button = ElevatedButton(
        child: const Text('START RECEIVING',
            style: TextStyle(color: Colors.black)),
        onPressed: () async {
          characteristic.lastValueStream.listen((value) {
            setState(() {
              widget.readValues[characteristic.uuid] = value;
            });
          });
          await characteristic.setNotifyValue(true);
        },
      );
    }

    return button;
  }

  ElevatedButton buildDisconnectButton(BluetoothCharacteristic characteristic) {
    return ElevatedButton(
      child: const Text('STOP RECEIVING'),
      onPressed: () {
        if (_connectedDevice != null) {
          setState(() {
            characteristic.setNotifyValue(false);
            //_connectedDevice!.disconnect();
            //_connectedDevice = null;
          });
        }
      },
    );
  }

  Container showConnected() {
    Container connectedButtons = Container();
    final utf8Decoder = utf8.decoder;
    int cont = 0;
    for (BluetoothService service in _services) {
      if (cont == 2) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.notify) {
            String decodedBytes = '';
            List<int>? encodedBytes = widget.readValues[characteristic.uuid];
            // ignore: unnecessary_null_comparison
            if (encodedBytes?.where((e) => e != null).toList().isEmpty ??
                true) {
              decodedBytes = '';
              connectedButtons = Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildNotifyButton(characteristic),
                        buildDisconnectButton(characteristic)
                      ],
                    ),
                    Text('Value: $decodedBytes'),
                  ],
                ),
              );
            } else {
              decodedBytes = utf8Decoder.convert(encodedBytes!);
              voltageValue = decodedBytes;
              connectedButtons = Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildNotifyButton(characteristic),
                        buildDisconnectButton(characteristic)
                      ],
                    ),
                    Text('Value: $decodedBytes'),
                    Chart(datatest: decodedBytes),
                  ],
                ),
              );
            }
          }
        }
      }
      cont += 1;
    }
    return connectedButtons;
  }

  Container buildView() {
    if (_connectedDevice != null) {
      return showConnected();
    }
    return connectToDevice();
  }

  @override
  Widget build(BuildContext context) => buildView();
}
