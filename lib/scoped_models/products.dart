import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/scoped_models/connected_products.dart';

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavorites = false;

  Map<String, Product> get allProducts {
    return Map.from(products);
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

  void deleteProduct(String title) {
    products.remove(title);
  }

  void updateProduct(
      String title, String description, String image, double price) {
    deleteProduct(title);
    addProduct(title, description, image, price);
  }

  void toggleFavorite(String title) {
    final Product product = products[title];
    products[title] = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        image: product.image,
        favorite: !product.favorite,
        userId: authenticatedUser.id,
        userEmail: authenticatedUser.email);
    notifyListeners();
  }

  void toggleShowFavorites() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}
