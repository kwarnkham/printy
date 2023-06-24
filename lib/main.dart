import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';

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
  BluetoothDevice? _device;
  bool _scanning = false;
  bool _connecting = false;
  bool _connected = false;
  final BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  _MyHomePageState() {
    bluetoothPrint.state.listen((state) {
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
  }
  void _scanForBluetoothDevices() {
    setState(() {
      _scanning = true;
    });

    bluetoothPrint
        .startScan(timeout: const Duration(seconds: 4))
        .then((value) => {
              setState(() {
                _scanning = false;
              })
            });
  }

  void _connectDevice() async {
    setState(() {
      _connecting = true;
    });
    try {
      await bluetoothPrint.connect(_device!);
    } catch (e) {
      rethrow;
    }
    setState(() {
      _connecting = false;
    });
  }

  void _print() async {
    Map<String, dynamic> config = {};
    List<LineText> list = List.empty();
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'A Title',
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'this is conent left',
        weight: 0,
        align: LineText.ALIGN_LEFT,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'this is conent right',
        align: LineText.ALIGN_RIGHT,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_BARCODE,
        content: 'A12312112',
        size: 10,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_QRCODE,
        content: 'qrcode i',
        size: 10,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(linefeed: 1));

    await bluetoothPrint.printReceipt(config, list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: (_connected) ? _print : null,
                child: const Text('Print')),
            ElevatedButton(
                onPressed:
                    (_device != null && !_connecting) ? _connectDevice : null,
                child: const Text('Connect')),
            StreamBuilder<List<BluetoothDevice>>(
              stream: bluetoothPrint.scanResults,
              initialData: const [],
              builder: (c, snapshot) => Column(
                children: snapshot.data!
                    .map((d) => ListTile(
                          title: Text(d.name ?? ''),
                          subtitle: Text(d.address ?? ''),
                          onTap: () async {
                            setState(() {
                              _device = d;
                            });
                          },
                          trailing:
                              _device != null && _device!.address == d.address
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : null,
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanning ? null : _scanForBluetoothDevices,
        tooltip: 'Scan',
        child: const Icon(Icons.scanner),
      ),
    );
  }
}
