import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  // Fetch orders from the backend API
  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse('http://localhost/pos_api/order.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          orders = data['data'];
        });
      } else {
        _showSnackBar('Error fetching orders: ${data['message']}');
      }
    } else {
      _showSnackBar('Error fetching orders: ${response.statusCode}');
    }
  }

  // Show a snack bar for status messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

// Fetch order details by order ID
  Future<List<dynamic>> fetchOrderDetails(String orderId) async {
    final response = await http.get(Uri.parse('http://localhost/pos_api/order_detail.php?order_id=$orderId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['data']; // Return the list of order details directly
      } else {
        _showSnackBar('Error fetching order details: ${data['message']}');
        return [];
      }
    } else {
      _showSnackBar('Error fetching order details: ${response.statusCode}');
      return [];
    }
  }

// Show the order details in a dialog
  void _showOrderDetailsDialog(String orderId) async {
    List<dynamic> orderDetails = await fetchOrderDetails(orderId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Details (Order ID: $orderId)'),
          content: orderDetails.isEmpty
              ? Text('No details found for this order.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: orderDetails.map((detail) {
                    return ListTile(
                      title: Text('Product ID: ${detail['product_id']}'), // Displaying the product_id directly
                      subtitle: Text('Quantity: ${detail['quantity']}, Price: \$${detail['price']}'),
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Close')),
          ],
        );
      },
    );
  }

  // Show the create order dialog
  void _showCreateDialog() {
    final orderIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Order'),
          content: _buildOrderForm(orderIdController),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _createOrder(orderIdController.text);
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // Build the common order form widget
  Widget _buildOrderForm(TextEditingController orderIdController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField('Order ID', orderIdController),
      ],
    );
  }

  // Build the text field widget
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.text,
    );
  }

  // Create new order
  Future<void> _createOrder(String orderId) async {
    final response = await http.post(
      Uri.parse('http://localhost/pos_api/order.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'order_id': orderId,
        'total_price': 0, // You can update this later based on your items
        'order_date': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchOrders(); // Refresh the order list
        _showSnackBar('Order created successfully');
      } else {
        _showSnackBar('Failed to create order');
      }
    } else {
      _showSnackBar('Error creating order');
    }
  }

  // Show the edit dialog
  void _showEditDialog(dynamic order) {
    final orderIdController = TextEditingController(text: order['order_id']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Order'),
          content: _buildOrderForm(orderIdController),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _updateOrder(order['order_id'], orderIdController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Update existing order
  Future<void> _updateOrder(String orderId, String newOrderId) async {
    final response = await http.put(
      Uri.parse('http://localhost/pos_api/order.php?order_id=$orderId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'new_order_id': newOrderId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchOrders(); // Refresh the order list
        _showSnackBar('Order updated successfully');
      } else {
        _showSnackBar('Failed to update order');
      }
    } else {
      _showSnackBar('Error updating order');
    }
  }

  // Show the delete confirmation dialog
  void _showDeleteDialog(String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Order'),
          content: Text('Are you sure you want to delete this order?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _deleteOrder(orderId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete order
  Future<void> _deleteOrder(String orderId) async {
    final response = await http.delete(Uri.parse('http://localhost/pos_api/order.php?order_id=$orderId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchOrders(); // Refresh the order list
        _showSnackBar('Order deleted successfully');
      } else {
        _showSnackBar('Failed to delete order');
      }
    } else {
      _showSnackBar('Error deleting order');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // No back button
        elevation: 0, // Optional: Removes shadow
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog, // Call the create dialog
        child: Icon(Icons.add),
        tooltip: 'Create Order',
      ),
      body: orders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text(order['order_id']),
                  subtitle: Text('Total Price: \$${order['total_price']}'),
                  onTap: () => _showOrderDetailsDialog(order['order_id']), // On tap, show order details
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditDialog(order),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(order['order_id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
