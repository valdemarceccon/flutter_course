import 'package:flutter/material.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:flutter_course/widgets/products/address_tag.dart';
import 'package:flutter_course/widgets/products/price_tag.dart';
import 'package:flutter_course/widgets/ui_elements/title_default.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductCard extends StatelessWidget {
  final int productIndex;

  const ProductCard(this.productIndex);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        final Product product = model.displayedProducts[productIndex];
        return Card(
          child: Column(
            children: <Widget>[
              FadeInImage(
                  image: NetworkImage(product.image),
                  height: 300.0,
                  fit: BoxFit.cover,
                  placeholder: AssetImage('assets/food.jpg')),
              _buildTitlePriceRow(product),
              AddressTag('asdfasdfasdf'),
              Text(product.userEmail),
              _buildActionButton(context, model)
            ],
          ),
        );
      },
    );
  }

  ButtonBar _buildActionButton(BuildContext context, MainModel model) {
    var product = model.displayedProducts[productIndex];
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.info),
          color: Theme.of(context).accentColor,
          onPressed: () =>
              Navigator.pushNamed<bool>(context, '/product/${product.id}'),
        ),
        IconButton(
          icon: product.favorite
              ? Icon(Icons.favorite)
              : Icon(Icons.favorite_border),
          color: Colors.red,
          onPressed: () => model.toggleFavorite(product.id),
        )
      ],
    );
  }

  Container _buildTitlePriceRow(Product product) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TitleDefault(product.title),
            SizedBox(
              width: 8.0,
            ),
            PriceTag(product.price.toString())
          ],
        ));
  }
}
