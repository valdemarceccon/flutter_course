import 'package:flutter_course/scoped_models/connected_products.dart';
import 'package:flutter_course/scoped_models/products.dart';
import 'package:flutter_course/scoped_models/user.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model
    with ConnectedProductsModel, ProductsModel, UserModel {}
