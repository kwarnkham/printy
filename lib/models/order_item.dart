class OrderItem {
  final double price;
  final int quantity;
  final double discount;

  OrderItem(this.price, this.quantity, this.discount);

  OrderItem.fromJson(Map<String, dynamic> json)
      : price = json['price'],
        quantity = json['quantity'],
        discount = json['discount'];
}
