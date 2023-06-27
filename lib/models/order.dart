import 'package:printy/models/item.dart';

class Order {
  final String id;
  final int amount;
  final int? discount;
  final String? customer;
  final String? phone;
  final String? address;
  final String? note;
  final int? paid;
  final String createdAt;
  final String? logo;
  final String? logoPhone;
  final List<Item> items;

  Order(
    this.id,
    this.amount,
    this.discount,
    this.customer,
    this.paid,
    this.phone,
    this.address,
    this.createdAt,
    this.logo,
    this.logoPhone,
    this.note,
    this.items,
  );

  Order.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        amount = json['amount'],
        discount = json['discount'],
        customer = json['customer'],
        address = json['address'],
        paid = json['paid'],
        phone = json['phone'],
        note = json['note'],
        createdAt = json['created_at'],
        logo = json['logo'],
        logoPhone = json['logo_phone'],
        items = List<Item>.from(json['a_items'].map((e) => Item.fromJson(e)));
}
