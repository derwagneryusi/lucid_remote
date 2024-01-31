import 'dart:async';
import 'dart:io';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';
import 'package:lucid_remote/owl_app.dart';
import 'package:permission_handler/permission_handler.dart';

import 'colors.dart';

late LucidBLE? lucidBLE = null;
//String adaptorText = "Not Connected";
final ValueNotifier<String> adaptorText =
    ValueNotifier<String>("Not Connected...");
final ValueNotifier<int> showBTSymbol = ValueNotifier<int>(0);
final ValueNotifier<String> deviceText = ValueNotifier<String>("");
final ValueNotifier<int> showDeviceSymbol = ValueNotifier<int>(0);

late BluetoothCharacteristic _bt_uart;
FlutterBlue _flutterBlue = FlutterBlue.instance;
late BluetoothDevice _lucidAdaptor;
Guid _bt_uart_uuid = Guid("0000ffe1-0000-1000-8000-00805f9b34fb");
late List<int> _rx_list = [];
int ident = -1;

Future<void> btUartWrite(List<int> data) async {
  await _bt_uart.write(data);
  //print("send..." + data.toString());
}

int btUartRead() {
  if (_rx_list.isNotEmpty) {
    int i = _rx_list.first;
    _rx_list.removeAt(0);
    return i;
  }
  return -1;
}

bool btUartAvailable() {
  if (_rx_list.isNotEmpty) return true;
  return false;
}

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_TWO,
      floatingActionButton: FloatingActionButton(
        backgroundColor: COLOR_ONE,
        onPressed: () async {
          bool permGranted = true;
          var status = await Permission.location.status;
          if (status.isDenied) {
            permGranted = false;
            Map<Permission, PermissionStatus> statuses = await [
              Permission.location,
              Permission.bluetoothScan,
              Permission.bluetoothConnect,
              Permission.bluetooth,
              Permission.nearbyWifiDevices,
            ].request();
            if (statuses[Permission.location]!.isGranted &&
                statuses[Permission.bluetoothScan]!.isGranted &&
                statuses[Permission.bluetoothConnect]!.isGranted &&
                statuses[Permission.bluetooth]!.isGranted &&
                statuses[Permission.nearbyWifiDevices]!.isGranted) {
              permGranted = true;
            } //check each permission status after.
          }

          bool b = await FlutterBlue.instance.isOn;
          if (Platform.isIOS || permGranted) {
            if (b) {
              setState(() {
                if (lucidBLE != null) {
                  lucidBLE!.reset();
                } else {
                  lucidBLE = LucidBLE();
                }
              });
            } else {
              adaptorText.value = "Please Turn Bluetooth On First!";
            }
          }
        },
        child: lucidBLE == null
            ? const Icon(
                Icons.search,
                color: Colors.white,
                size: 30,
              )
            : const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 30,
              ),
      ),
      appBar: AppBar(
        title: Image.asset(
          'assets/lucid_white.png',
          height: 20,
        ),
        backgroundColor: COLOR_ONE,
      ),
      body: Column(
        children: [
          const Center(),
          const SizedBox(
            height: 30,
          ),
          ValueListenableBuilder<String>(
            builder: (BuildContext context, String value, Widget? child) {
              // This builder will only get called when the _counter
              // is updated.
              return whiteTextItalic(value);
            },
            valueListenable: adaptorText,
          ),
          const SizedBox(
            height: 30,
          ),
          ValueListenableBuilder<int>(
            builder: (BuildContext context, int value, Widget? child) {
              if (value >= 2) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 2000),
                  opacity: value > 2 ? 1.0 : 0.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            color: COLOR_ONE, shape: BoxShape.circle),
                        height: 200,
                        width: 200,
                      ),
                      const Icon(
                        Icons.bluetooth,
                        color: COLOR_THREE,
                        size: 100,
                      ),
                    ],
                  ),
                );
              } else if (value == 1) {
                return const CircularProgressIndicator();
              } else {
                return const SizedBox(
                  height: 0,
                );
              }
            },
            valueListenable: showBTSymbol,
          ),
          const SizedBox(
            height: 30,
          ),
          ValueListenableBuilder<String>(
            builder: (BuildContext context, String value, Widget? child) {
              // This builder will only get called when the _counter
              // is updated.
              return whiteTextItalic(value);
            },
            valueListenable: deviceText,
          ),
          const SizedBox(
            height: 30,
          ),
          ValueListenableBuilder<int>(
            builder: (BuildContext context, int value, Widget? child) {
              if (value >= 2) {
                return AnimatedOpacity(
                  opacity: value > 2 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 2000),
                  child: ElevatedButton(
                      //backgroundColor: const Color.fromARGB(204, 00, 122, 255),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // <-- Radius
                          ),
                          backgroundColor: COLOR_ONE,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/image.png',
                            width: 100,
                          ),
                          const SizedBox(
                            width: 80,
                          ),
                          const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 50,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              //return LightEditor();
                              return OwlApp();
                            },
                          ),
                        );
                      }),
                );
              } else if (value == 1) {
                return const CircularProgressIndicator();
              } else {
                return const SizedBox(
                  height: 0,
                );
              }
            },
            valueListenable: showDeviceSymbol,
          ),
        ],
      ),
    );
  }
}

Text whiteText(String txt) {
  return Text(
    txt,
    style: const TextStyle(
      color: Colors.white,
    ),
  );
}

Text whiteTextItalic(String txt) {
  return Text(
    txt,
    style: const TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.italic,
    ),
  );
}

class LucidBLE {
  LucidBLE() {
    var timer = Timer.periodic(const Duration(milliseconds: 200), ((timer) {
      _tick(timer);
    }));
  }

  int _stepState = 0;

  Future<void> reset() async {
    _stepState = 0;
    await _lucidAdaptor.disconnect();
    var timer = Timer.periodic(const Duration(milliseconds: 200), ((timer) {
      _tick(timer);
    }));
  }

  int getIdent() {
    return ident;
  }

  bool isConnected() {
    return ((_stepState > 2) ? true : false);
  }

  Future<void> _tick(Timer t) async {
    t.cancel();
    if (_stepState == 0) {
      showBTSymbol.value = 1;
      adaptorText.value = "Searching For Devices...";
      //showBTSymbol.value = 0;
      showDeviceSymbol.value = 0;
      deviceText.value = "";
      _stepState = 1;
      _flutterBlue.startScan();
    } else if (_stepState == 1) {
      _flutterBlue.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.name.compareTo("LUCID") == 0) {
            _lucidAdaptor = r.device;
            showBTSymbol.value = 2;
            _stepState = 2;
            await _flutterBlue.stopScan();
            break;
          }
        }
        _flutterBlue.scanResults.drain();
      });
    } else if (_stepState == 2) {
      showBTSymbol.value = 3;
      adaptorText.value = "Found LUCID BT Device";
      await _lucidAdaptor.connect();
      _stepState++;
    } else if (_stepState == 3) {
      adaptorText.value = "Checking LUCID BT Device Services";
      List<BluetoothService> services = await _lucidAdaptor.discoverServices();
      services.forEach((service) async {
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString().compareTo(_bt_uart_uuid.toString()) == 0) {
            _bt_uart = c;
            await _bt_uart.setNotifyValue(true);
            _bt_uart.value.listen((value) {
              _rx_list.addAll(value);
              //print("rec..." + value.toString());
            });
            _stepState = 4;
            showDeviceSymbol.value = 1;
            break;
          }
        }
      });
    } else if (_stepState == 4) {
      adaptorText.value = "LUCID BT Device Connected";
      deviceText.value = "Fetching Device Information";
      await btUartWrite([0x00]);
      _stepState++;
    } else if (_stepState == 5) {
      if (btUartAvailable()) ident = btUartRead();
      if (ident == 77) {
        _stepState++;
        showDeviceSymbol.value = 2;
      } else {
        _stepState = 4;
      }
    } else if (_stepState == 6) {
      deviceText.value = "Connected To";
      showDeviceSymbol.value = 3;
      t.cancel();
      _stepState++;
    }
    if (_stepState < 7) {
      t = Timer.periodic(const Duration(milliseconds: 200), ((t) {
        _tick(t);
      }));
    }
  }
}
