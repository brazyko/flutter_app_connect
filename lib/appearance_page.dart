import 'package:connect/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // Import provider package
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_notifier.dart';  // Import ThemeNotifier class

class AppearancePage extends StatefulWidget {
  @override
  _AppearancePageState createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.currentTheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : const Color.fromRGBO(206, 212, 218, 1),
        title: Text(
          'Appearance Settings ',
          style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'KdamThmorPro',
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,  // Dynamically change the back arrow color
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: isDarkMode ? Color.fromRGBO(20, 20, 20, 1) : const Color.fromRGBO(233, 236, 239, 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),  // Add padding to ensure rounded edges are visible
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black54 : Colors.white,  // Background color for the box
            borderRadius: BorderRadius.circular(30.0),  // Rounded corners for the box
          ),
          child: ListTile(
            leading: Icon(
              Icons.theater_comedy_outlined,
              color: isDarkMode ? Colors.white : Colors.black,  // Icon color
            ),
            title: Text(
              'Dark Theme',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontFamily: 'KdamThmorPro',
                fontSize: 18,
              ),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) async {
                themeNotifier.toggleTheme();
                final prefs = await SharedPreferences.getInstance();
                prefs.setBool('dark_mode', value);
              },
              activeColor: Colors.white,
              inactiveThumbColor: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
