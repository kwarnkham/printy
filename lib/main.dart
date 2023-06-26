import 'dart:convert';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:printy/print_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Printy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BluetoothPrint _bluetoothPrint = BluetoothPrint.instance;

  BluetoothDevice? _device;
  final GlobalKey _globalKey = GlobalKey();
  bool _connected = false;

  void _connectDevice() async {
    if (_device != null && _device!.address != null) {
      await _bluetoothPrint.connect(_device!);
    } else {}
  }

  bool _printing = false;

  Future<Uint8List?> takePicture() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 2);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  _print() async {
    Uint8List? data = await takePicture();
    Map<String, dynamic> config = {};
    List<LineText> list = List.empty(growable: true);
    String base64Image = base64Encode(data!);
    list.add(
      LineText(
          type: LineText.TYPE_IMAGE,
          content: base64Image,
          align: LineText.ALIGN_CENTER,
          width: 540,
          linefeed: 1),
    );
    _printing = true;
    await _bluetoothPrint
        .printReceipt(config, list)
        .whenComplete(() => setState(() {
              _printing = false;
            }));
  }

  Future<void> initBluetooth() async {
    _bluetoothPrint.startScan(timeout: const Duration(seconds: 4));

    bool isConnected = await _bluetoothPrint.isConnected ?? false;

    _bluetoothPrint.state.listen((state) {
      print('******************* current device status: $state');
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            _bluetoothPrint.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Center(
            child: Column(children: [
              PrintView(globalKey: _globalKey),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: !_connected
                        ? null
                        : _printing
                            ? null
                            : _print,
                    child: const Text('Print'),
                  ),
                  ElevatedButton(
                    onPressed: _device != null && _device!.address != null
                        ? _connectDevice
                        : null,
                    child: const Text('Connect'),
                  ),
                  ElevatedButton(
                    onPressed: _connected
                        ? () async {
                            await _bluetoothPrint.disconnect();
                          }
                        : null,
                    child: const Text('Disconnect'),
                  ),
                ],
              ),
              StreamBuilder<List<BluetoothDevice>>(
                stream: _bluetoothPrint.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                    children: snapshot.data
                            ?.map((d) => ListTile(
                                  title: Text(d.name ?? ''),
                                  subtitle: Text(d.address ?? ''),
                                  onTap: () async {
                                    setState(() {
                                      _device = d;
                                    });
                                  },
                                  trailing: _device?.address == d.address
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : null,
                                ))
                            .toList() ??
                        []),
              )
            ]),
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: _bluetoothPrint.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data == true) {
            return FloatingActionButton(
              onPressed: () => _bluetoothPrint.stopScan(),
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
              child: const Icon(Icons.search),
              onPressed: () => _bluetoothPrint.startScan(
                timeout: const Duration(seconds: 4),
              ),
            );
          }
        },
      ),
    );
  }
}
