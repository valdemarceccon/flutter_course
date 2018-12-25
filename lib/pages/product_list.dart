import 'package:flutter/material.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/pages/product_edit.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            var product = model.allProducts.values.elementAt(index);
            return Dismissible(
              background: Container(
                color: Colors.red,
              ),
              key: Key(product.id),
              onDismissed: (DismissDirection direction) {
                final Product deletedProduct = model.deleteProduct(product.id);

                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('${product.title} deleted'),
                  action: SnackBarAction(label: 'Undo', onPressed: () {}),
                  duration: Duration(seconds: 40),
                ));
              },
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(product.image),
                    ),
                    title: Text(product.title),
                    subtitle: Text('\$${product.price}'),
                    trailing: _buildEditButton(context, product),
                  ),
                  Divider(),
                ],
              ),
            );
          },
          itemCount: model.allProducts.length,
        );
      },
    );
  }

  IconButton _buildEditButton(BuildContext context, Product products) {
    return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return ProductEditPage(
              product: products,
            );
          }));
        });
  }
}
