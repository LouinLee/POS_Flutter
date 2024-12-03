import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
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

  // Show the create product dialog
  void _showCreateDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final productIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Product'),
          content: _buildProductForm(nameController, quantityController, priceController, productIdController),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _createProduct(productIdController.text, nameController.text, double.parse(quantityController.text), double.parse(priceController.text));
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // Build the common product form widget
  Widget _buildProductForm(TextEditingController nameController, TextEditingController quantityController, TextEditingController priceController, TextEditingController productIdController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField('Product ID', productIdController),
        _buildTextField('Product Name', nameController),
        _buildTextField('Quantity', quantityController),
        _buildTextField('Price', priceController),
      ],
    );
  }

  // Build the text field widget
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: label == 'Price' || label == 'Quantity' ? TextInputType.number : TextInputType.text,
    );
  }

  // Create new product
  Future<void> _createProduct(String productId, String name, double quantity, double price) async {
    final response = await http.post(
      Uri.parse('http://localhost/pos_api/product.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'product_id': productId,
        'product_name': name,
        'quantity': quantity,
        'price': price,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchProducts(); // Refresh the product list
        _showSnackBar('Product created successfully');
      } else {
        _showSnackBar('Failed to create product');
      }
    } else {
      _showSnackBar('Error creating product');
    }
  }

  // Show the edit dialog
  void _showEditDialog(dynamic product) {
    final nameController = TextEditingController(text: product['product_name']);
    final quantityController = TextEditingController(text: product['quantity'].toString());
    final priceController = TextEditingController(text: product['price'].toString());
    final productIdController = TextEditingController(text: product['product_id']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: _buildProductForm(nameController, quantityController, priceController, productIdController),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _updateProduct(product['product_id'], productIdController.text, nameController.text, double.parse(quantityController.text), double.parse(priceController.text));
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Update existing product
  Future<void> _updateProduct(String productId, String newProductId, String name, double quantity, double price) async {
    final response = await http.put(
      Uri.parse('http://localhost/pos_api/product.php?product_id=$productId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'new_product_id': newProductId,
        'product_name': name,
        'quantity': quantity,
        'price': price,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchProducts(); // Refresh the product list
        _showSnackBar('Product updated successfully');
      } else {
        _showSnackBar('Failed to update product');
      }
    } else {
      _showSnackBar('Error updating product');
    }
  }

  // Show the delete confirmation dialog
  void _showDeleteDialog(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _deleteProduct(productId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete product
  Future<void> _deleteProduct(String productId) async {
    final response = await http.delete(Uri.parse('http://localhost/pos_api/product.php?product_id=$productId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchProducts(); // Refresh the product list
        _showSnackBar('Product deleted successfully');
      } else {
        _showSnackBar('Failed to delete product');
      }
    } else {
      _showSnackBar('Error deleting product');
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
        tooltip: 'Create Product',
      ),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product['product_name']),
                  subtitle: Text('Price: \$${product['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditDialog(product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(product['product_id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
