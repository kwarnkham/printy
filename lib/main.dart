import 'dart:async';
import 'dart:convert';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

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

  DateTime _now = DateTime.now();

  bool _connected = false;

  _scanDevices() {
    _bluetoothPrint.startScan(timeout: const Duration(seconds: 3));
  }

  void _connectDevice() {
    _bluetoothPrint.connect(_device!);
  }

  Uint8List? _pngData;
  bool _printing = false;

  _print() async {
    Map<String, dynamic> config = {};
    List<LineText> list = List.empty(growable: true);
    Uint8List? data = await takePicture();
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

    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  final GlobalKey _globalKey = GlobalKey();

  Future<Uint8List?> takePicture() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 2);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          RepaintBoundary(
            key: _globalKey,
            child: _order.isEmpty
                ? const SizedBox()
                : Container(
                    width: 360.toDouble(),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        Image.network(_order['logo']),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text(_order['logo_phone'])],
                        ),
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
                                      DateTime.parse(_order['created_at']),
                                    ),
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
                        Container(
                          color: Colors.black,
                          height: 1,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 4, bottom: 4),
                          child: const Text('_'),
                        ),
                        const Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Price',
                                textAlign: TextAlign.end,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Qty',
                                textAlign: TextAlign.end,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Amount',
                                textAlign: TextAlign.end,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          color: Colors.black,
                          height: 1,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 4, bottom: 4),
                          child: const Text('_'),
                        ),
                        ..._order['a_items'].map((item) {
                          return Container(
                            padding: const EdgeInsets.only(top: 2, bottom: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(item['name']),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    (item['pivot']['price'] -
                                            item['pivot']['discount'])
                                        .toString(),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                        item['pivot']['quantity'].toString(),
                                        textAlign: TextAlign.end)),
                                Expanded(
                                  flex: 2,
                                  // child: Text(
                                  //     ((item['pivot']['price'] -
                                  //                 item['pivot']['quantity']) *
                                  //             item['pivot']['quantity'])
                                  //         .toString(),
                                  //     textAlign: TextAlign.end),
                                  child: Text(
                                      ((item['pivot']['price'] -
                                                  item['pivot']['discount']) *
                                              item['pivot']['quantity'])
                                          .toString(),
                                      textAlign: TextAlign.end),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        Container(
                          color: Colors.black,
                          height: 1,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 4, bottom: 4),
                          child: const Text('_'),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 6,
                                child: Text(
                                  'Total',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                    _order['a_items'].length == 0
                                        ? '0'
                                        : _order['a_items'].fold(0,
                                            (carry, item) {
                                            return item['pivot']['quantity'] +
                                                carry;
                                            // return carry +
                                            //     item['pivot']['quantity'];
                                          }).toString(),
                                    textAlign: TextAlign.end),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                    _order['a_items'].length == 0
                                        ? '0'
                                        : _order['a_items'].fold(0,
                                            (carry, item) {
                                            return (item['pivot']['quantity'] *
                                                    (item['pivot']['price'] -
                                                        item['pivot']
                                                            ['discount'])) +
                                                carry;
                                            // return carry +
                                            //     item['pivot']['quantity'];
                                          }).toString(),
                                    textAlign: TextAlign.end),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.black,
                          height: 1,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 4, bottom: 4),
                          child: const Text('_'),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 7,
                                child: Text(
                                  'Paid',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(_order['paid'].toString(),
                                    textAlign: TextAlign.end),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 7,
                                child: Text(
                                  'Discount',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(_order['discount'].toString(),
                                    textAlign: TextAlign.end),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.black,
                          height: 1,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 4, bottom: 4),
                          child: const Text('_'),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 7,
                                child: Text(
                                  'Grand Total',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                    (_order['amount'] - _order['paid'])
                                        .toString(),
                                    textAlign: TextAlign.end),
                              ),
                            ],
                          ),
                        ),
                        _order['note'] == ''
                            ? const SizedBox()
                            : Row(
                                children: [
                                  const Text('Note :'),
                                  Text(_order['note'])
                                ],
                              ),
                        Row(
                          children: [
                            Text(DateFormat('dd/MM/yyyy hh:mm:ss aaa')
                                .format(_now))
                          ],
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Thank You',
                              textAlign: TextAlign.center,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
          ),
          _pngData == null ? const SizedBox() : Image.memory(_pngData!),
          ElevatedButton(
            onPressed: !_connected
                ? null
                : _printing
                    ? null
                    : _print,
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
