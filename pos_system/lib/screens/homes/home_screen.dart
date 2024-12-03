import 'package:flutter/material.dart';
import 'order_detail_screen.dart';
import 'product_screen.dart';
import 'home_content.dart';
import 'admin_screen.dart';
import 'order_screen.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Map of screen names to their respective widgets
  final Map<String, Widget> _screens = {
    'Home': HomeContent(),
    'Admin': AdminScreen(),
    'Product': ProductScreen(),
    'Order': OrderScreen(),
    'Order_detail': OrderDetailScreen(),
  };

  // List of screen names to map them to the BottomNavigationBar
  final List<String> _screenNames = ['Home', 'Admin', 'Product', 'Order', 'Order_detail'];

  // Current screen to display and active index
  int _currentIndex = 0;

  // Method to update the selected screen based on the screen name
  void _onItemSelected(String screenName) {
    setState(() {
      _currentIndex = _screenNames.indexOf(screenName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: AppDrawer(onItemSelected: _onItemSelected), // Pass the callback
      body: _screens[_screenNames[_currentIndex]]!, // Display the selected screen
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Flutter App'),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(), // Open drawer
          );
        },
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex, // Update active item
      type: BottomNavigationBarType.fixed, // Ensure fixed size for all items
      onTap: (index) {
        setState(() {
          _currentIndex = index; // Update selected index
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.production_quantity_limits),
          label: 'Product',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Order',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Order_detail',
        ),
      ],
      selectedItemColor: Colors.blue, // Color for the selected icon
      unselectedItemColor: Colors.grey, // Color for unselected icons
    );
  }
}
