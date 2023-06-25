import 'dart:convert';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  Map<String, dynamic> _order = {};

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = json.decode(response);

    setState(() {
      _order = data['order'];
    });
  }

  bool _connected = false;

  _scanDevices() {
    _bluetoothPrint.startScan(timeout: const Duration(seconds: 3));
  }

  void _connectDevice() {
    _bluetoothPrint.connect(_device!);
  }

  _print() async {}

  @override
  void initState() {
    super.initState();
    _bluetoothPrint.state.listen((state) {
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
          _order.isEmpty
              ? const SizedBox()
              : Container(
                  width: 360.toDouble(),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      Image.network(_order['logo']),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(children: [
                              const Icon(Icons.person),
                              Text(_order['customer'])
                            ]),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.phone),
                                Text(_order['phone'])
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(children: [
                              const Icon(Icons.numbers),
                              Text(_order['id'].toString())
                            ]),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.calendar_month),
                                Flexible(
                                    child: Text(
                                  DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(_order['created_at'])),
                                  textAlign: TextAlign.right,
                                ))
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_pin),
                          Flexible(
                            child: Text(_order['address']),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
          ElevatedButton(
            onPressed: !_connected ? null : _print,
            child: const Text('Print'),
          ),
          ElevatedButton(
            onPressed: _device == null ? null : _connectDevice,
            child: const Text('Connect'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _scanDevices,
        tooltip: 'Scan',
        child: const Icon(Icons.search),
      ),
    );
  }
}
