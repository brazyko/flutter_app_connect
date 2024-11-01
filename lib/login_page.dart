import 'dart:convert';
import 'package:connect/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'account_page.dart';
import 'config_file.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      const url = '${ApiConfig.baseUrl}/auth/login';
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      });

      try {
        final response = await http.post(Uri.parse(url), headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final accessToken = responseData['access_token'];

          // Save token using shared_preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);

          // Navigate to the MyAccount page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyAccount()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to login')),
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
                'authenticate',
                style: TextStyle(
                  fontFamily: 'KdamThmorPro',
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'username',
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
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black, // Text color
                  minimumSize: const Size(120, 50), // Width and height of the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                ),
                child: const Text(
                  'login',
                  style: TextStyle(
                    fontFamily: 'KdamThmorPro', // Custom font
                    fontSize: 16, // Font size
                  ),
                ),
              ),
              const Spacer(),  // Pushes the "already have an account" text to the bottom
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return FirstNameLastNamePage();
                      },
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        // Define the transition animation
                        const offsetBegin = Offset(1.0, 0.0); // Start from the left
                        const offsetEnd = Offset.zero; // End at the center

                        var tween = Tween<Offset>(begin: offsetBegin, end: offsetEnd);
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(position: offsetAnimation, child: child);
                      },
                    ),
                  );
                },
                child: const Text(
                  'Don`t have an account?',
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
