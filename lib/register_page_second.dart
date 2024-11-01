import 'package:connect/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config_file.dart';
import 'login_page.dart';

class SecondPage extends StatefulWidget {
  final String firstName;
  final String lastName;

  SecondPage({required this.firstName, required this.lastName});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      const url = '${ApiConfig.baseUrl}/auth/register';
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'username': _usernameController.text,
        'first_name': widget.firstName,
        'last_name': widget.lastName,
        'password': _passwordController.text,
      });

      try {
        final response = await http.post(Uri.parse(url), headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['msg'] ?? 'Registration successful')),
          );
          // Navigate to LoginPage after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to register')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/logo.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(height: 10),
              const Text(
                'Registration',
                style: TextStyle(
                  fontFamily: 'KdamThmorPro',
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: const Color.fromRGBO(234, 234, 234, 1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  labelStyle: const TextStyle(
                    color: Colors.black45, // Text color
                    fontFamily: 'KdamThmorPro', // Custom font
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never, // Keeps label in place
                ),
                style: const TextStyle(
                  fontFamily: 'KdamThmorPro', // Custom font for the text entered
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: const Color.fromRGBO(234, 234, 234, 1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  labelStyle: const TextStyle(
                    color: Colors.black45, // Text color
                    fontFamily: 'KdamThmorPro', // Custom font
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never, // Keeps label in place
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black45, // Icon color
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'KdamThmorPro', // Custom font for the text entered
                ),
                obscureText: _obscurePassword, // Use the state variable to control visibility
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: const Color.fromRGBO(234, 234, 234, 1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  labelStyle: const TextStyle(
                    color: Colors.black45, // Text color
                    fontFamily: 'KdamThmorPro', // Custom font
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never, // Keeps label in place
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black45, // Icon color
                    ),
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'KdamThmorPro', // Custom font for the text entered
                ),
                obscureText: _obscureConfirmPassword, // Use the state variable to control visibility
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black, // Text color
                  minimumSize: const Size(120, 50), // Width and height of the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                ),
                onPressed: _register,
                child: const Text(
                  'Register',
                  style: TextStyle(
                    fontFamily: 'KdamThmorPro', // Custom font
                    fontSize: 16, // Font size
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        // Define the new page
                        return FirstNameLastNamePage();
                      },
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        // Define the transition animation
                        const offsetBegin = Offset(-1.0, 0.0); // Start from the left
                        const offsetEnd = Offset.zero; // End at the center

                        var tween = Tween<Offset>(begin: offsetBegin, end: offsetEnd);
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(position: offsetAnimation, child: child);
                      },
                    ),
                  );
                },
                child: const Text(
                  'Return to Previous Step',
                  style: TextStyle(
                    fontFamily: 'KdamThmorPro',
                    color: Colors.black,  // You can change the color as needed
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

