import 'dart:async';
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

  final TextEditingController _inputController =
      TextEditingController(text: '');

  int _size = 560;
  int _quantity = 2;
  Map<String, dynamic> _order = {};

  String _statusText = 'Disconnected';

  void reset(String text) {
    setState(() {
      _statusText = text;
      _bluetoothPrint.disconnect();
      _connected = false;
      _device = null;
    });
  }

  Future<Uint8List?> takePicture() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: _quantity.toDouble());

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  bool _printing = false;
  Uint8List? _printTarget;

  _prepare() async {
    Uint8List? data = await takePicture();
    setState(() {
      _printTarget = data;
    });
  }

  _print() async {
    bool isAvailable = await _bluetoothPrint.isAvailable;
    if (!isAvailable) {
      return reset('Printer is not available');
    }

    bool isConnected = await _bluetoothPrint.isConnected ?? false;
    if (!isConnected) {
      setState(() {
        return reset('Printer is not connected');
      });
    }

    bool isOn = await _bluetoothPrint.isOn;
    if (!isOn) {
      return reset('Printer is on');
    }

    if (_printTarget == null) {
      return reset('No print data yet');
    }

    setState(() {
      _printing = true;
    });

    List<LineText> list = List.empty(growable: true);
    String base64Image = base64Encode(_printTarget!);
    list.add(
      LineText(
          type: LineText.TYPE_IMAGE,
          content: base64Image,
          align: LineText.ALIGN_CENTER,
          width: _size,
          linefeed: 1),
    );

    await _bluetoothPrint.printReceipt({}, list);

    Timer(const Duration(seconds: 10), () {
      setState(() {
        _printing = false;
      });
    });
  }

  Future<void> initBluetooth() async {
    _bluetoothPrint.startScan(timeout: const Duration(seconds: 4));

    bool isConnected = await _bluetoothPrint.isConnected ?? false;

    _bluetoothPrint.state.listen((state) {
      // print('******************* current device status: $state');
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            _statusText = 'Connected';
          });
          break;
        default:
          setState(() {
            _connected = false;
          });
          _bluetoothPrint.disconnect();
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
            child: SizedBox(
              width: 360.toDouble(),
              child: Column(children: [
                _printTarget != null
                    ? Image.memory(_printTarget!)
                    : PrintView(
                        globalKey: _globalKey,
                        order: _order,
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(_statusText)],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _printing
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _printing = false;
                              });
                            },
                            child: const Text('Finish'))
                        : _printTarget != null
                            ? ElevatedButton(
                                onPressed: !_connected
                                    ? null
                                    : _printTarget == null
                                        ? null
                                        : _print,
                                child: const Text('Print'),
                              )
                            : ElevatedButton(
                                onPressed: _order.isEmpty ? null : _prepare,
                                child: const Text('Prepare'),
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
                              setState(() {
                                _device = null;
                              });
                              await _bluetoothPrint.disconnect();
                            }
                          : null,
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _size = 360;
                        });
                      },
                      child: Text(
                        '58mm',
                        style: TextStyle(
                            color: _size == 360 ? Colors.green : Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _size = 560;
                        });
                      },
                      child: Text(
                        '80mm',
                        style: TextStyle(
                            color: _size == 560 ? Colors.green : Colors.grey),
                      ),
                    )
                  ],
                ),
                const Center(
                  child: Text('Quality'),
                ),
                Wrap(
                  spacing: 10,
                  children: [2, 4, 6, 8, 10, 12]
                      .map(
                        (e) => ElevatedButton(
                          style: ElevatedButton.styleFrom(),
                          onPressed: () {
                            setState(() {
                              _quantity = e;
                            });
                          },
                          child: Text(
                            e.toString(),
                            style: TextStyle(
                                color: _quantity == e
                                    ? Colors.green
                                    : Colors.grey),
                          ),
                        ),
                      )
                      .toList(),
                ),
                TextField(
                  controller: _inputController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Print Data',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        try {
                          Map<String, dynamic> result =
                              json.decode(_inputController.value.text);
                          setState(() {
                            _order = result;
                          });
                        } on FormatException {
                          setState(() {
                            _order = {"text": _inputController.text};
                          });
                        }
                        setState(() {
                          _printTarget = null;
                        });
                        _inputController.text = '';
                      },
                      icon: const Icon(Icons.add_sharp),
                    )
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
      ),
    );
  }
}
