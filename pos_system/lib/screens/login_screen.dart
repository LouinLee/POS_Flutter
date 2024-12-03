import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import 'homes/home_screen.dart'; // Import the home screen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      bool success = await AuthService().login(
        _emailController.text,
        _passwordController.text,
      );
      if (success) {
        // Store email or any other info you want to persist after login
        await _storage.write(key: 'email', value: _emailController.text);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful')));

        // Navigate to the Home screen after login success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Navigate to Home screen
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid credentials')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Enter your password' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
