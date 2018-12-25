import 'package:flutter/material.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductEditPage extends StatefulWidget {
  final Product product;

  ProductEditPage({this.product});

  @override
  State createState() => new _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'https://fortunedotcom.files.wordpress.com/2017/02/chocolate.gif'
  };

  @override
  Widget build(BuildContext context) {
    var pageContent = buildPageContent(context);
    return widget.product == null
        ? pageContent
        : Scaffold(
            appBar: AppBar(
              title: Text('Edit ${widget.product.title}'),
            ),
            body: pageContent,
          );
  }

  GestureDetector buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * .95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(),
              _buildDescriptionTextField(),
              _buildPriceTextField(),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ScopedModelDescendant<MainModel>(
          builder: (context, child, model) {
            return model.isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RaisedButton(
                    child: Text('Save'),
                    color: Theme.of(context).accentColor,
                    textColor: Theme.of(context).primaryColorLight,
                    onPressed: () => _submitForm(model),
                  );
          },
        );
      },
    );
  }

  void _submitForm(MainModel model) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (widget.product != null) {
        model
            .updateProduct(
          widget.product.id,
          _formData['title'],
          _formData['description'],
          _formData['image'],
          _formData['price'],
        )
            .then((_) {
          Navigator.pushReplacementNamed(context, '/products');
        });
      } else {
        model
            .addProduct(_formData['title'], _formData['description'],
                _formData['image'], _formData['price'])
            .then((bool success) {
          if (success) {
            Navigator.pushReplacementNamed(context, '/products');
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Something went wrong'),
                    content: Text('Try again!'),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      )
                    ],
                  );
                });
          }
        });
      }
    }
  }

  TextFormField _buildPriceTextField() {
    return TextFormField(
      initialValue:
          widget.product == null ? '' : widget.product.price.toString(),
      decoration: InputDecoration(labelText: 'Product Price'),
      validator: _validNumber,
      keyboardType: TextInputType.number,
      onSaved: (String value) {
        _formData['price'] = double.parse(value);
      },
    );
  }

  TextFormField _buildDescriptionTextField() {
    return TextFormField(
      initialValue: widget.product == null ? '' : widget.product.description,
      decoration: InputDecoration(labelText: 'Product Description'),
      validator: _emptyTextFieldValidation,
      maxLines: 4,
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildTitleTextField() {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return TextFormField(
          initialValue: widget.product == null ? '' : widget.product.title,
          decoration: InputDecoration(labelText: 'Product Title'),
          validator: _emptyTextFieldValidation,
          onSaved: (String value) {
            _formData['title'] = value;
          },
        );
      },
    );
  }

  String _emptyTextFieldValidation(String value) {
    if (value.isEmpty) {
      return "Cannot be empty";
    }

    return null;
  }

  String _validNumber(String value) {
    if (double.tryParse(value) == null) {
      return 'Invalid value';
    }
    return null;
  }
}
