import 'dart:convert';

import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';

mixin ConnectedProductsModel on Model {
  final Map<String, Product> _products = {};
  User _authenticatedUser;

  bool _isLoading = false;

  Future<dynamic> addProduct(
      String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    return http
        .post('https://udemy-flutter-course.firebaseio.com/products.json',
            body: json.encode(productData))
        .then((value) {
      final Map responseData = json.decode(value.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.addAll({newProduct.id: newProduct});
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }
}

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavorites = false;

  Map<String, Product> get allProducts {
    return Map.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return allProducts.values.where((product) => product.favorite).toList();
    } else {
      return allProducts.values.toList();
    }
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Product deleteProduct(String id) {
    var removed = _products.remove(id);
    notifyListeners();
    return removed;
  }

  void fetchProducts() {
    _isLoading = true;
    notifyListeners();
    http
        .get('https://udemy-flutter-course.firebaseio.com/products.json')
        .then((response) {
      if (response.body != 'null') {
        final Map<String, dynamic> productListData = json.decode(response.body);
        final Map<String, Product> loadedProducts = {};
        productListData.forEach((productId, productData) {
          final Product product = Product(
              id: productId,
              title: productData['title'],
              description: productData['description'],
              price: productData['price'],
              image: productData['image'],
              userEmail: productData['userEmail'],
              userId: productData['userId']);

          loadedProducts[productId] = product;
        });
        _products.addAll(loadedProducts);
        notifyListeners();
      }
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<dynamic> updateProduct(
      String id, String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();

    final Product product = _products[id];
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'userEmail': product.userEmail,
      'userId': product.userId
    };

    return http
        .put('https://udemy-flutter-course.firebaseio.com/products/$id.json',
            body: json.encode(productData))
        .then((response) {
      _products[id] = Product(
          id: product.id,
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: product.userEmail,
          userId: product.userId,
          favorite: product.favorite);
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });

//    deleteProduct(id);
//    addProduct(id, newTitle, description, image, price);
  }

  void toggleFavorite(String id) {
    final Product product = _products[id];
    _products[id] = Product(
        id: id,
        title: product.title,
        description: product.description,
        price: product.price,
        image: product.image,
        favorite: !product.favorite,
        userId: product.userId,
        userEmail: product.userEmail);
    notifyListeners();
  }

  void toggleShowFavorites() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {
  void login(String email, String password) {
    _authenticatedUser = User(id: 'adfadf', email: email, password: password);
  }
}

mixin UtilsModel on ConnectedProductsModel {
  bool get isLoading => _isLoading;
}
