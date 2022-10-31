import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authToken;
  final String userId;
  ProductsProvider(this.authToken, this._items, this.userId);

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite == true).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var _params;
    if (filterByUser) {
      _params = <String, String>{
        'auth': authToken,
        "orderBy": json.encode("createdBy"),
        "equalTo": json.encode(userId),
      };
    }
    if (filterByUser == false) {
      _params = <String, String>{
        'auth': authToken,
      };
    }

    var url = Uri.https(
        "flutter-project-testing-8debf-default-rtdb.firebaseio.com",
        "/products.json",
        _params);

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }
      url = Uri.https(
          "flutter-project-testing-8debf-default-rtdb.firebaseio.com",
          "/userFavorites/$userId.json",
          {'auth': authToken});

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          description: prodData['description'],
          isFavorite: favoriteData == null
              ? false
              : favoriteData[prodId] == null
                  ? false
                  : favoriteData[prodId]['isFavorite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  //Add product
  Future<void> addProduct(Product product) async {
    final url = Uri.https(
        'flutter-project-testing-8debf-default-rtdb.firebaseio.com',
        'products.json',
        {'auth': authToken});
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'createdBy': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  //Update product
  Future<void> updateProduct(String productId, Product newProduct) async {
    final productIndex =
        _items.indexWhere((element) => element.id == productId);
    if (productIndex >= 0) {
      final url = Uri.https(
          'flutter-project-testing-8debf-default-rtdb.firebaseio.com',
          'products/$productId.json',
          {'auth': authToken});

      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            'description': newProduct.description,
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print("Updating problem");
    }
  }

  //Delete Product
  Future<void> deleteProduct(String productId) async {
    final productIndex =
        _items.indexWhere((element) => element.id == productId);

    final url = Uri.https(
        'flutter-project-testing-8debf-default-rtdb.firebaseio.com',
        'products/$productId.json',
        {'auth': authToken});
    final existingProductIndex =
        _items.indexWhere((element) => element.id == productId);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode > 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete the product!");
    }
    existingProduct = null;
  }
}
