import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(String) onItemSelected; // Callback to update the selected screen

  const AppDrawer({required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Drawer Header
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          // Home menu item
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              onItemSelected('Home'); // Navigate to Home
              Navigator.of(context).pop();
            },
          ),
          // Admin menu item
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text('Admin'),
            onTap: () {
              onItemSelected('Admin'); // Navigate to Admin
              Navigator.of(context).pop();
            },
          ),
          // Product menu item
          ListTile(
            leading: Icon(Icons.production_quantity_limits),
            title: Text('Product'),
            onTap: () {
              onItemSelected('Product'); // Navigate to Product
              Navigator.of(context).pop();
            },
          ),
          // Order menu item
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Order'),
            onTap: () {
              onItemSelected('Order'); // Navigate to Order
              Navigator.of(context).pop();
            },
          ),
          // Order_detail menu item (fix here)
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Order_detail'),
            onTap: () {
              onItemSelected('Order_detail'); // Navigate to Order_detail
              Navigator.of(context).pop();
            },
          ),
          // Divider and Logout button
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              _logout(context); // Handle logout action
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    // Optionally, clear session data here

    // Navigate to the HomeScreen (main entry point)
    Navigator.pushReplacementNamed(context, '/');
  }
}
