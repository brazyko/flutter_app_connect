import 'dart:convert';
import 'package:connect/storage_usage.dart';
import 'package:connect/users_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'appearance_page.dart';
import 'config_file.dart';
import 'language_page.dart';
import 'login_page.dart';
import 'user_chats.dart';
import 'theme_notifier.dart'; // Import ThemeNotifier

class MyAccount extends StatefulWidget {
  @override
  _MyAccount createState() => _MyAccount();
}

class _MyAccount extends State<MyAccount> {
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) {
      final url = '${ApiConfig.baseUrl}/users/my-profile';
      final headers = {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      try {
        final response = await http.get(Uri.parse(url), headers: headers);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _username = data['username'] ?? '';
            _firstName = data['first_name'] ?? '';
            _lastName = data['last_name'] ?? '';
            _isLoading = false;
          });
        } else {
          // Handle server errors
          setState(() {
            _isLoading = false;
          });
        }
      } catch (error) {
        // Handle network errors
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Handle token not found scenario
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.currentTheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color.fromRGBO(20, 20, 20, 1) : const Color.fromRGBO(233, 236, 239, 1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const Spacer(),
          // First block with image, name, and username
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : const Color.fromRGBO(206, 212, 218, 1),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30.0,
                ),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_firstName $_lastName', // Display the user's full name
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 18.0,
                        fontFamily: 'KdamThmorPro',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@$_username', // Display the user's username
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        fontFamily: 'KdamThmorPro',
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Second block with settings items
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : const Color.fromRGBO(206, 212, 218, 1),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _settingsItems.length,
              separatorBuilder: (context, index) =>
              const Divider(color: Colors.white),
              itemBuilder: (context, index) {
                final item = _settingsItems[index];
                return ListTile(
                  leading: Icon(item.icon, color: isDarkMode ? Colors.white : Colors.black),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'KdamThmorPro',
                      fontSize: 16.0,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: 16.0),
                  onTap: () {
                    switch (item.text) {
                      case 'Storage Usage':
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    StorageUsagePage()));
                        break;
                      case 'Notifications':
                        break;
                      case 'Privacy':
                        break;
                      case 'Appearance':
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AppearancePage()));
                        break;
                      case 'Language':
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LanguagePage()));
                        break;
                      default:
                        break;
                    }
                  },
                );
              },
            ),
          ),
          // Third block
// Third block
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : const Color.fromRGBO(206, 212, 218, 1),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () async {
                    // Clear the access token from SharedPreferences
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('access_token');

                    // Navigate back to the LoginPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your actual login page widget
                    );
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'KdamThmorPro',
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: isDarkMode ? Colors.black : const Color.fromRGBO(206, 212, 218, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => MyAccount(), // Replace with your target page
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = 0.0; // Start of animation
                      const end = 1.0; // End of animation
                      const curve = Curves.easeInOut; // Animation curve

                      // Define the animation for the fade transition
                      final tween = Tween<double>(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final opacityAnimation = animation.drive(tween);

                      return FadeTransition(
                        opacity: opacityAnimation, // Apply the opacity animation
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.search_sharp, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => UsersList(), // Replace with your target page
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = 0.0; // Start of animation
                      const end = 1.0; // End of animation
                      const curve = Curves.easeInOut; // Animation curve

                      // Define the animation for the fade transition
                      final tween = Tween<double>(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final opacityAnimation = animation.drive(tween);

                      return FadeTransition(
                        opacity: opacityAnimation, // Apply the opacity animation
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.chat_outlined, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => UserChatsList(), // Replace with your target page
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = 0.0; // Start of animation
                      const end = 1.0; // End of animation
                      const curve = Curves.easeInOut; // Animation curve

                      // Define the animation for the fade transition
                      final tween = Tween<double>(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final opacityAnimation = animation.drive(tween);

                      return FadeTransition(
                        opacity: opacityAnimation, // Apply the opacity animation
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.settings_outlined, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsItem {
  final IconData icon;
  final String text;

  SettingsItem(this.icon, this.text);
}

final List<SettingsItem> _settingsItems = [
  SettingsItem(Icons.storage, 'Storage Usage'),
  SettingsItem(Icons.notifications, 'Notifications'),
  SettingsItem(Icons.lock, 'Privacy'),
  SettingsItem(Icons.visibility, 'Appearance'),
  SettingsItem(Icons.language, 'Language'),
];
