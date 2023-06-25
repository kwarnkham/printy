import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BluetoothPrint _bluetoothPrint = BluetoothPrint.instance;

  BluetoothDevice? _device;
  dynamic _order;

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = await json.decode(response);

    setState(() {
      _order = data;
    });
  }

  bool _connected = false;

  _scanDevices() {
    _bluetoothPrint.startScan(timeout: const Duration(seconds: 3));
  }

  void _connectDevice() {
    _bluetoothPrint.connect(_device!);
  }

  _print() async {
    // Map<String, dynamic> config = {};
    // List<LineText> list = List.empty(growable: true);

    // list.add(LineText(
    //     type: LineText.TYPE_TEXT,
    //     content: 'A Title',
    //     weight: 1,
    //     align: LineText.ALIGN_CENTER,
    //     linefeed: 1));
    // ByteData data = await rootBundle.load("assets/print-logo.jpg");
    // List<int> imageBytes =
    //     data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // String base64Image = base64Encode(imageBytes);

    // list.add(LineText(
    //     type: LineText.TYPE_IMAGE,
    //     content: base64Image,
    //     align: LineText.ALIGN_CENTER,
    //     width: 450,
    //     height: 450,
    //     x: 10,
    //     y: 10,
    //     linefeed: 1));
    // await _bluetoothPrint.printReceipt(config, list);
    // list.add(LineText(
    //     type: LineText.TYPE_TEXT,
    //     content: 'this is conent left',
    //     weight: 0,
    //     align: LineText.ALIGN_LEFT,
    //     linefeed: 1));
    // list.add(LineText(
    //     type: LineText.TYPE_TEXT,
    //     content: 'this is conent right',
    //     align: LineText.ALIGN_RIGHT,
    //     linefeed: 1));
    // list.add(LineText(linefeed: 1));
    // list.add(LineText(
    //     type: LineText.TYPE_BARCODE,
    //     content: 'A12312112',
    //     size: 10,
    //     align: LineText.ALIGN_CENTER,
    //     linefeed: 1));
    // list.add(LineText(linefeed: 1));
    // list.add(LineText(
    //     type: LineText.TYPE_QRCODE,
    //     content: 'qrcode i',
    //     size: 10,
    //     align: LineText.ALIGN_CENTER,
    //     linefeed: 1));
    // list.add(LineText(linefeed: 1));
  }

  @override
  void initState() {
    super.initState();
    _bluetoothPrint.state.listen((state) {
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            print('device state is connected');
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

    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(children: [
          Image.network(_order.logo),
          ElevatedButton(
              onPressed: !_connected ? null : _print,
              child: const Text('Print')),
          ElevatedButton(
              onPressed: _device == null ? null : _connectDevice,
              child: const Text('Connect')),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _scanDevices,
        tooltip: 'Scan',
        child: const Icon(Icons.search),
      ),
    );
  }
}
