import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> admins = [];

  @override
  void initState() {
    super.initState();
    fetchAdmins();
  }

  // Fetch admins from the backend API
  Future<void> fetchAdmins() async {
    final response = await http.get(Uri.parse('http://localhost/pos_api/admin.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          admins = data['data'];
        });
      } else {
        _showSnackBar('Error fetching admins: ${data['message']}');
      }
    } else {
      _showSnackBar('Error fetching admins: ${response.statusCode}');
    }
  }

  // Show a snack bar for status messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Show the create admin dialog
  void _showCreateDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final adminIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Admin'),
          content: _buildAdminForm(nameController, emailController, adminIdController),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _createAdmin(adminIdController.text, nameController.text, emailController.text);
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // Build the common admin form widget
  Widget _buildAdminForm(TextEditingController nameController, TextEditingController emailController, TextEditingController adminIdController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField('Admin ID', adminIdController),
        _buildTextField('Name', nameController),
        _buildTextField('Email', emailController),
        _buildPasswordField('Password'),
      ],
    );
  }

  // Build the text field widget
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  // Build the password field widget
  Widget _buildPasswordField(String label) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(labelText: label),
    );
  }

  // Create new admin
  Future<void> _createAdmin(String adminId, String name, String email) async {
    final response = await http.post(
      Uri.parse('http://localhost/pos_api/admin.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'admin_id': adminId,
        'name': name,
        'email': email,
        'password': 'unchanged', // You should handle password securely
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchAdmins(); // Refresh the admin list
        _showSnackBar('Admin created successfully');
      } else {
        _showSnackBar('Failed to create admin');
      }
    } else {
      _showSnackBar('Error creating admin');
    }
  }

  // Show the edit dialog
  void _showEditDialog(dynamic admin) {
    final nameController = TextEditingController(text: admin['name']);
    final emailController = TextEditingController(text: admin['email']);
    final adminIdController = TextEditingController(text: admin['admin_id']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Admin'),
          content: _buildAdminForm(nameController, emailController, adminIdController),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _updateAdmin(admin['admin_id'], adminIdController.text, nameController.text, emailController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Update existing admin
  Future<void> _updateAdmin(String adminId, String newAdminId, String name, String email) async {
    final response = await http.put(
      Uri.parse('http://localhost/pos_api/admin.php?admin_id=$adminId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'new_admin_id': newAdminId,
        'name': name,
        'email': email,
        'password': 'unchanged', // Handle password change if necessary
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchAdmins(); // Refresh the admin list
        _showSnackBar('Admin updated successfully');
      } else {
        _showSnackBar('Failed to update admin');
      }
    } else {
      _showSnackBar('Error updating admin');
    }
  }

  // Show the delete confirmation dialog
  void _showDeleteDialog(String adminId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Admin'),
          content: Text('Are you sure you want to delete this admin?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _deleteAdmin(adminId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete admin
  Future<void> _deleteAdmin(String adminId) async {
    final response = await http.delete(Uri.parse('http://localhost/pos_api/admin.php?admin_id=$adminId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        fetchAdmins(); // Refresh the admin list
        _showSnackBar('Admin deleted successfully');
      } else {
        _showSnackBar('Failed to delete admin');
      }
    } else {
      _showSnackBar('Error deleting admin');
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
        tooltip: 'Create Admin',
      ),
      body: admins.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: admins.length,
              itemBuilder: (context, index) {
                final admin = admins[index];
                return ListTile(
                  title: Text(admin['name']),
                  subtitle: Text(admin['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditDialog(admin),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(admin['admin_id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
