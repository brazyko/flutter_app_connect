import 'package:connect/login_page.dart';
import 'package:flutter/material.dart';
import 'package:connect/register_page_second.dart';

class FirstNameLastNamePage extends StatefulWidget {
  @override
  _FirstNameLastNamePageState createState() => _FirstNameLastNamePageState();
}

class _FirstNameLastNamePageState extends State<FirstNameLastNamePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _navigateToSecondPage() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return SecondPage(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
            );
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
                'registration',
                style: TextStyle(
                  fontFamily: 'KdamThmorPro',
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'first name',
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
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'last name',
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
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToSecondPage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black, // Text color
                  minimumSize: const Size(120, 50), // Width and height of the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                ),
                child: const Text(
                  'proceed',
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
                        return LoginPage();
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
                  'Already have an account?',
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
