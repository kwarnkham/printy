import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';

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
  ReceiptController? controller;

  Future<void> print() async {
    final device = await FlutterBluetoothPrinter.selectDevice(context);
    if (device != null) {
      /// do print
      controller?.print(address: device.address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Receipt(
        builder: (context) => const Column(children: [
          Text('Hello World'),
        ]),
        onInitialized: (controller) {
          this.controller = controller;
        },
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        tooltip: 'Scan',
        child: Icon(Icons.scanner),
      ),
    );
  }
}
