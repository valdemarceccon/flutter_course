import 'package:flutter/material.dart';

import './product_edit.dart';
import './product_list.dart';

class ProductsAdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Product Admin Page'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.create),
                text: 'Create Product',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'My Products',
              ),
            ],
          ),
        ),
        drawer: _buildDrawer(context),
        body: TabBarView(
            children: <Widget>[ProductEditPage(), ProductListPage()]),
      ),
    );
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
              leading: Icon(Icons.shop),
              title: Text('Product List'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/products');
              })
        ],
      ),
    );
  }
}
