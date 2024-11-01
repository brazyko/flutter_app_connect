import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_page.dart';
import 'config_file.dart';
import 'theme_notifier.dart'; // Import ThemeNotifier

class UserDetailedPage extends StatefulWidget {
  UserDetailedPage({required this.userId}); // Add required userId
  final int? userId; // Accept userId in constructor

  @override
  _UserDetailedPage createState() => _UserDetailedPage();
}

class _UserDetailedPage extends State<UserDetailedPage> {
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
      print(widget.userId);
      final url = '${ApiConfig.baseUrl}/users/get_user?user_id=${widget.userId}';
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
      appBar: AppBar(
        title: Text('User Details', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      backgroundColor: isDarkMode ? const Color.fromRGBO(20, 20, 20, 1) : const Color.fromRGBO(233, 236, 239, 1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // First block with image, name, and username
          Container(
            margin: const EdgeInsets.only(top: 20, left: 10, bottom: 0, right: 10),
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
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_firstName $_lastName',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 18.0,
                        fontFamily: 'KdamThmorPro',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@$_username',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        fontFamily: 'KdamThmorPro',
                        fontSize: 14.0,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? token = prefs.getString('access_token');

                        if (token != null) {
                          final url = '${ApiConfig.baseUrl}/chats/get-or-create-chat?receiver_id=${widget.userId}';
                          final headers = {
                            'accept': 'application/json',
                            'Authorization': 'Bearer $token',
                          };

                          try {
                            final response = await http.get(Uri.parse(url), headers: headers);
                            if (response.statusCode == 200) {
                              final data = jsonDecode(response.body);
                              final chatId = data; // Assuming the response has a chat_id field

                              // Navigate to the ChatPage with the chatId
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(chatId: chatId),
                                ),
                              );
                            } else {
                              // Handle error (e.g., show a message)
                              print('Error fetching chat: ${response.statusCode}');
                            }
                          } catch (error) {
                            // Handle exception (e.g., show a message)
                            print('Error: $error');
                          }
                        }
                      },
                      child: Text(
                        'Send message',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: 'KdamThmorPro',
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
