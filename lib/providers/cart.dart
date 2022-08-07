import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  int quantity;
  final double price;

  CartItem(
      {required this.id,
      required this.title,
      this.quantity = 1,
      required this.price});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  void addItem(
    String productID,
    double price,
    String title,
  ) {
    if (_items.containsKey(productID)) {
      _items.update(
          productID,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.id,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity + 1,
              ));
    } else {
      _items[productID] =
          CartItem(id: DateTime.now().toString(), title: title, price: price);
    }
    notifyListeners();
  }
}
