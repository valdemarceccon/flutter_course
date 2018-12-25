import 'package:flutter/material.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:flutter_course/widgets/products/product_card.dart';
import 'package:scoped_model/scoped_model.dart';

class Products extends StatelessWidget {
  Widget _buildProductList(MainModel model) {
    final List<Product> products = model.displayedProducts;
    Widget productCards;

    if (model.isLoading) {
      productCards = Center(
        child: CircularProgressIndicator(),
      );
    } else if (products.length > 0) {
      productCards = ListView.builder(
        itemBuilder: (context, index) => ProductCard(index),
        itemCount: products.length,
      );
    } else {
      productCards = Center(child: Text('No Products found'));
    }

    return productCards;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return RefreshIndicator(
            child: _buildProductList(model),
            onRefresh: model.fetchProducts);
      },
    );
  }
}
