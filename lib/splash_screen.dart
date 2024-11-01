import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false; // Default to false if not set

      await Future.delayed(Duration(seconds: 1)); // Simulate loading

      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/userPage'); // Navigate to user page
      } else {
        Navigator.pushReplacementNamed(context, '/register_page'); // Navigate to registration page
      }
    } catch (e) {
      print('Error checking login status: $e');
      // Handle error, maybe navigate to an error screen or show a dialog
      Navigator.pushReplacementNamed(context, '/errorPage'); // Example: navigate to an error page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Connect',  // Your text
              style: TextStyle(
                fontFamily: 'San Francisco',  // Ensure the font is correctly set in pubspec.yaml
                fontSize: 24,  // Font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
