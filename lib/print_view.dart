import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PrintView extends StatefulWidget {
  final GlobalKey globalKey;
  const PrintView({super.key, required this.globalKey});

  @override
  State<PrintView> createState() => _PrintViewState();
}

class _PrintViewState extends State<PrintView> {
  Map<String, dynamic> _order = {};
  DateTime _now = DateTime.now();

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = json.decode(response);

    setState(() {
      _order = data['order'];
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget.globalKey,
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
                                    DateTime.parse(_order['created_at'])),
                                textAlign: TextAlign.right,
                              ),
                            ),
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
                  const Divider(),
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
                  const Divider(),
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
                              child: Text(item['pivot']['quantity'].toString(),
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
                  const Divider(),
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
                                  : _order['a_items'].fold(0, (carry, item) {
                                      return item['pivot']['quantity'] + carry;
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
                                  : _order['a_items'].fold(0, (carry, item) {
                                      return (item['pivot']['quantity'] *
                                              (item['pivot']['price'] -
                                                  item['pivot']['discount'])) +
                                          carry;
                                      // return carry +
                                      //     item['pivot']['quantity'];
                                    }).toString(),
                              textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
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
                  const Divider(),
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
                              (_order['amount'] - _order['paid']).toString(),
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
                      Text(DateFormat('dd/MM/yyyy hh:mm:ss aaa').format(_now))
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
    );
  }
}
