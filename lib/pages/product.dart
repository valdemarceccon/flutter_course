import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:flutter_course/widgets/ui_elements/title_default.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductPage extends StatelessWidget {
  final String _id;

  const ProductPage(this._id);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: ScopedModelDescendant<MainModel>(builder: (context, child, model) {
        var product =
            model.displayedProducts.firstWhere((product) => product.id == _id);
        return Scaffold(
          appBar: AppBar(
            title: Text('Product Page'),
          ),
          body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.network(product.image),
                Container(
                  child: TitleDefault(product.title),
                  padding: EdgeInsets.all(10.0),
                ),
                _buildAddressPriceRow(product),
                Container(
                  child: Text(
                    product.description,
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(10.0),
                )
              ]),
        );
      }),
    );
  }

  Row _buildAddressPriceRow(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Endereco',
          style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
        ),
        Container(
          child: Text(
            '|',
            style: TextStyle(color: Colors.grey),
          ),
          margin: EdgeInsets.symmetric(horizontal: 5.0),
        ),
        Text('\$' + product.price.toString(),
            style: TextStyle(fontFamily: 'Oswald', color: Colors.grey))
      ],
    );
  }
}
