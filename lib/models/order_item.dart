class OrderItem {
  final int price;
  final int quantity;
  final int discount;

  OrderItem(this.price, this.quantity, this.discount);

  OrderItem.fromJson(Map<String, dynamic> json)
      : price = json['price'],
        quantity = json['quantity'],
        discount = json['discount'];
}
