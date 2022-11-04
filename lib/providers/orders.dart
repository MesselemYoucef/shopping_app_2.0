import 'package:flutter/foundation.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this._orders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(
        'flutter-project-testing-8debf-default-rtdb.firebaseio.com',
        '/orders/$userId.json/',
        {'auth': authToken});
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((key, value) {
      loadedOrders.add(OrderItem(
          id: key,
          amount: value['amount'],
          dateTime: DateTime.parse(value['dateTime']),
          products: (value['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'], title: item['title'], price: item['price']))
              .toList()));
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
        'flutter-project-testing-8debf-default-rtdb.firebaseio.com',
        '/orders/$userId.json',
        {'auth': authToken});
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts.map((cp) {
              return {
                'id': cp.id,
                'title': cp.title,
                'quantity': cp.quantity,
                'price': cp.price
              };
            }).toList(),
            'createdBy': userId
          }));
      _orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timeStamp,
          ));
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
