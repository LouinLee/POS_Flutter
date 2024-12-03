import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<dynamic> orderDetails = [];
  List<dynamic> orders = [];
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
    fetchOrders();
    fetchProducts();
  }

  // Fetch order details from the backend API
  Future<void> fetchOrderDetails() async {
    final response = await http.get(Uri.parse('http://localhost/pos_api/order_detail.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          orderDetails = data['data'];
          isLoading = false;
        });
      } else {
        _showSnackBar('Error fetching order details: ${data['message']}');
      }
    } else {
      _showSnackBar('Error fetching order details: ${response.statusCode}');
    }
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

  // Fetch products from the backend API
  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://localhost/pos_api/product.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          products = data['data'];
        });
      } else {
        _showSnackBar('Error fetching products: ${data['message']}');
      }
    } else {
      _showSnackBar('Error fetching products: ${response.statusCode}');
    }
  }

  // Show a snack bar for status messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Show the create order detail dialog
  void _showCreateDialog() {
    final orderDetailIdController = TextEditingController();
    String selectedOrderId = orders.isNotEmpty ? orders[0]['order_id'] : '';
    String selectedProductId = products.isNotEmpty ? products[0]['product_id'] : '';
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Order Detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: orderDetailIdController,
                decoration: const InputDecoration(labelText: 'Order Detail ID'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedOrderId,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOrderId = newValue!;
                  });
                },
                items: orders.map((order) {
                  return DropdownMenuItem<String>(
                    value: order['order_id'],
                    child: Text('Order ID: ${order['order_id']}'),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Order ID'),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedProductId,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProductId = newValue!;
                  });
                },
                items: products.map((product) {
                  return DropdownMenuItem<String>(
                    value: product['product_id'],
                    child: Text(product['product_name']),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Product'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _createOrderDetail(
                  orderDetailIdController.text,
                  selectedOrderId,
                  selectedProductId,
                  int.parse(quantityController.text),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Create new order detail
  Future<void> _createOrderDetail(String orderDetailId, String orderId, String productId, int quantity) async {
    final response = await http.post(
      Uri.parse('http://localhost/pos_api/order_detail.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'order_detail_id': orderDetailId,
        'order_id': orderId,
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchOrderDetails(); // Refresh the order detail list
        _showSnackBar('Order detail created successfully');
      } else {
        _showSnackBar('Failed to create order detail');
      }
    } else {
      _showSnackBar('Error creating order detail');
    }
  }

  // Show the edit order detail dialog
  void _showEditDialog(dynamic orderDetail) {
    final orderDetailIdController = TextEditingController(text: orderDetail['order_detail_id']);
    String selectedProductId = orderDetail['product_id'];
    final quantityController = TextEditingController(text: orderDetail['quantity'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Order Detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: orderDetailIdController,
                decoration: const InputDecoration(labelText: 'Order Detail ID'),
                enabled: false,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedProductId,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProductId = newValue!;
                  });
                },
                items: products.map((product) {
                  return DropdownMenuItem<String>(
                    value: product['product_id'],
                    child: Text(product['product_name']),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Product'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _updateOrderDetail(
                  orderDetail['order_detail_id'],
                  selectedProductId,
                  int.parse(quantityController.text),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Update existing order detail
  Future<void> _updateOrderDetail(String orderDetailId, String productId, int quantity) async {
    final response = await http.put(
      Uri.parse('http://localhost/pos_api/order_detail.php?order_detail_id=$orderDetailId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchOrderDetails(); // Refresh the order detail list
        _showSnackBar('Order detail updated successfully');
      } else {
        _showSnackBar('Failed to update order detail');
      }
    } else {
      _showSnackBar('Error updating order detail');
    }
  }

  // Show the delete confirmation dialog
  void _showDeleteDialog(String orderDetailId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Order Detail'),
          content: const Text('Are you sure you want to delete this order detail?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _deleteOrderDetail(orderDetailId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete order detail
  Future<void> _deleteOrderDetail(String orderDetailId) async {
    final response = await http.delete(Uri.parse('http://localhost/pos_api/order_detail.php?order_detail_id=$orderDetailId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchOrderDetails(); // Refresh the order detail list
        _showSnackBar('Order detail deleted successfully');
      } else {
        _showSnackBar('Failed to delete order detail');
      }
    } else {
      _showSnackBar('Error deleting order detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        tooltip: 'Create Order Detail',
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orderDetails.length,
              itemBuilder: (context, index) {
                final orderDetail = orderDetails[index];
                return ListTile(
                  title: Text('Order Detail ID: ${orderDetail['order_detail_id']}'),
                  subtitle: Text('Total Amount: ${orderDetail['subtotal']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(orderDetail),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(orderDetail['order_detail_id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
