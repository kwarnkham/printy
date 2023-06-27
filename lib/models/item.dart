import 'package:printy/models/order_item.dart';

class Item {
  final int id;
  final String name;
  final double price;
  final OrderItem orderItem;

  Item(this.id, this.name, this.price, this.orderItem);

  Item.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        price = json['price'],
        orderItem = OrderItem.fromJson(json['pivot']);
}
