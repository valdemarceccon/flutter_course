import 'package:flutter/material.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:flutter_course/widgets/products/products.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductsPage extends StatefulWidget {
  final MainModel mainModel;

  ProductsPage(this.mainModel);

  @override
  ProductsPageState createState() {
    return new ProductsPageState();
  }
}

class ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    widget.mainModel.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: _buildDrawer(context),
        appBar: AppBar(
          title: Text('EasyList'),
          actions: <Widget>[
            ScopedModelDescendant<MainModel>(
              builder: (context, child, model) {
                return IconButton(
                  icon: model.displayFavoritesOnly
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border),
                  onPressed: () => model.toggleShowFavorites(),
                );
              },
            )
          ],
        ),
        body: Products());
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Choose'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
              leading: Icon(Icons.edit),
              title: Text('Product Admin'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/admin');
              })
        ],
      ),
    );
  }
}
