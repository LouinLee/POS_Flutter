import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'homes/home_screen.dart'; // Import the HomeScreen

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      bool success = await AuthService().register(
        _adminIdController.text,
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful')));

        // Replace the current RegisterScreen with the HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Navigate to HomeScreen
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _adminIdController,
                decoration: InputDecoration(labelText: 'Admin ID'),
                validator: (value) => value!.isEmpty ? 'Enter Admin ID' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
