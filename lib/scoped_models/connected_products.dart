import 'dart:async';
import 'dart:convert';

import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin ConnectedProductsModel on Model {
  final Map<String, Product> _products = {};
  User _authenticatedUser;

  bool _isLoading = false;

  Future<bool> addProduct(String title, String description, String image, double price) {
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
        .post(
        'https://udemy-flutter-course.firebaseio.com/products.json?auth=${_authenticatedUser
            .token}',
        body: json.encode(productData))
        .then((response) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map responseData = json.decode(response.body);
        final Product newProduct = Product(
            id: responseData['name'],
            title: title,
            description: description,
            price: price,
            image: image,
            userEmail: _authenticatedUser.email,
            userId: _authenticatedUser.id);
        _products.addAll({newProduct.id: newProduct});
        return true;
      } else {
        return false;
      }
    }).catchError((error) {
      return false;
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

  Future<bool> deleteProduct(String id) {
    _isLoading = true;
    notifyListeners();

    return http
        .delete(
        'https://udemy-flutter-course.firebaseio.com/products/$id.json?auth=${_authenticatedUser
            .token}')
        .then((response) {
      _products.remove(id);
      return true;
    })
        .catchError(() => false)
        .whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> fetchProducts({ownerOnly = false}) async {
    if (_authenticatedUser == null) {
      return false;
    }
    _isLoading = true;
    _products.clear();
    notifyListeners();
    final http.Response response = await http.get(
        'https://udemy-flutter-course.firebaseio.com/products.json?auth=${_authenticatedUser
            .token}');
    try {
      if (response.body != 'null') {
        final Map<String, dynamic> productListData = json.decode(response.body);
        final Map<String, Product> loadedProducts = {};
        productListData.forEach((productId, productData) {
          if (!ownerOnly ||
              (ownerOnly && productData['userId'] == _authenticatedUser.id)) {
            final Product product = Product(
                id: productId,
                title: productData['title'],
                description: productData['description'],
                price: productData['price'],
                image: productData['image'],
                userEmail: productData['userEmail'],
                userId: productData['userId'],
                favorite: productData['wishlistUsers'] == null
                    ? false
                    : (productData['wishlistUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));

            loadedProducts[productId] = product;
          }
        });
        _products.addAll(loadedProducts);
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> updateProduct(String id, String title, String description, String image, double price) {
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
        .put(
        'https://udemy-flutter-course.firebaseio.com/products/$id.json?auth=${_authenticatedUser
            .token}',
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

      return true;
    })
        .catchError(() => false)
        .whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  void toggleFavorite(String id) async {
    final Product product = _products[id];
    final bool isCurrentFavorite = product.favorite;
    final bool newFavoriteStatus = !isCurrentFavorite;

    _products[id] = Product(
        id: id,
        title: product.title,
        description: product.description,
        price: product.price,
        image: product.image,
        favorite: newFavoriteStatus,
        userId: product.userId,
        userEmail: product.userEmail);
    notifyListeners();

    http.Response response;

    if (newFavoriteStatus) {
      response = await http.put(
          'https://udemy-flutter-course.firebaseio.com/products/$id/wishlistUsers/${_authenticatedUser
              .id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _products[id] = Product(
            id: id,
            title: product.title,
            description: product.description,
            price: product.price,
            image: product.image,
            favorite: !newFavoriteStatus,
            userId: product.userId,
            userEmail: product.userEmail);
        notifyListeners();
      }
    } else {
      response = await http.delete(
          'https://udemy-flutter-course.firebaseio.com/products/$id/wishlistUsers/${_authenticatedUser
              .id}.json?auth=${_authenticatedUser.token}');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      _products[id] = Product(
          id: id,
          title: product.title,
          description: product.description,
          price: product.price,
          image: product.image,
          favorite: !newFavoriteStatus,
          userId: product.userId,
          userEmail: product.userEmail);
      notifyListeners();
    }
  }

  void toggleShowFavorites() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {
  Timer _authTimer;

  get user => _authenticatedUser;

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final http.Response response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyAaeNNm2uJJw0XJWUPnkCQ2D7Khv7lKPS4',
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
        headers: {'Content-Type': 'application/json'});

    final Map<String, dynamic> authData =
    await _handleAuthData(json.decode(response.body));

    _isLoading = false;
    notifyListeners();
    return authData;
  }

  Future<Map<String, dynamic>> signup(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final http.Response response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAaeNNm2uJJw0XJWUPnkCQ2D7Khv7lKPS4',
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
        headers: {'Content-Type': 'application/json'});

    final Map<String, dynamic> authData =
    await _handleAuthData(json.decode(response.body));

    _isLoading = false;
    notifyListeners();
    return authData;
  }

  Future<Map<String, dynamic>> _handleAuthData(
      Map<String, dynamic> responseData) async {
    bool hasError = !responseData.containsKey('idToken');
    String message;

    if (hasError) {
      final String errorMessage = responseData['error']['message'];

      if (errorMessage == 'EMAIL_NOT_FOUND' ||
          errorMessage == 'INVALID_PASSWORD') {
        message = 'User/Password invalid';
      } else if (errorMessage == 'USER_DISABLED') {
        message = 'User disabled';
      } else if (errorMessage == 'EMAIL_EXISTS') {
        message = 'E-mail already in use';
      } else {
        message = 'Something went wrong';
      }
    }

    if (!hasError) {
      _authenticatedUser = User(
          id: responseData['localId'],
          email: responseData['email'],
          token: responseData['idToken']);
      final int expiresIn = int.parse(responseData['expiresIn']);

      setAuthTimeout(expiresIn);

      final DateTime now = DateTime.now();
      final DateTime expireTime = now.add(Duration(seconds: expiresIn));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userToken', _authenticatedUser.token);
      prefs.setString('userEmail', _authenticatedUser.email);
      prefs.setString('userId', _authenticatedUser.id);
      prefs.setString('expireTime', expireTime.toIso8601String());
    }

    return {'success': !hasError, 'message': message};
  }

  void autoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String userToken = prefs.getString('userToken');
    final String expireTime = prefs.getString('expireTime');
    if (userToken != null) {
      final DateTime now = DateTime.now();
      final parsedExpireTime = DateTime.parse(expireTime);

      if (now.isAfter(parsedExpireTime)) {
        return;
      }

      _authenticatedUser = User(
          id: prefs.getString('userId'),
          email: prefs.getString('userEmail'),
          token: userToken);
      setAuthTimeout(parsedExpireTime
          .difference(now)
          .inSeconds);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove('userToken');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }

  void setAuthTimeout(int seconds) {
    _authTimer = Timer(Duration(seconds: seconds), logout);
  }
}

mixin UtilsModel on ConnectedProductsModel {
  bool get isLoading => _isLoading;
}
