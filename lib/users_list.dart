import 'dart:convert';
import 'package:connect/user_detailed_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'account_page.dart';
import 'config_file.dart';
import 'theme_notifier.dart';
import 'user_chats.dart';

class UsersList extends StatefulWidget {
  @override
  _UsersList createState() => _UsersList();
}

class _UsersList extends State<UsersList> {
  bool _isLoading = false;
  List<dynamic> _users = [];
  TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged); // Listen for changes in search
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _fetchSearchedUsers(_searchController.text);
    } else {
      setState(() {
        _users.clear(); // Clear list if search query is empty
      });
    }
  }

  Future<void> _fetchSearchedUsers(String query) async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) {
      final url = '${ApiConfig.baseUrl}/users/find?user=$query';
      final headers = {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      try {
        final response = await http.get(Uri.parse(url), headers: headers);

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            _users = data; // Update users list
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Users',
                  filled: true,
                  fillColor: isDarkMode ? Colors.black : Colors.white, // Background color based on theme
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.black54, // Hint text color based on theme
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Adjust padding for round input feel
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Make the input rounded
                    borderSide: BorderSide.none, // Remove border
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black, // Text color based on theme
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(
                    user['username'] ?? '',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16.0,
                      fontFamily: 'KdamThmorPro',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    user['first_name'] + ' ' + user['last_name'] ?? 'No Name',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black,
                      fontSize: 12.0,
                      fontFamily: 'KdamThmorPro',
                    ),
                  ),
                  trailing: Text(
                    'view profile',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12.0,
                    ),
                  ),
                  onTap: () {
                    final userId = user['id']; // Ensure this value is not null and valid
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return UserDetailedPage(userId: userId); // Pass the user ID
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
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: isDarkMode ? Colors.black : const Color.fromRGBO(206, 212, 218, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.person_outlined, color: isDarkMode ? Colors.white : Colors.black),
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
              icon: Icon(Icons.search_outlined, color: isDarkMode ? Colors.white : Colors.black),
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
