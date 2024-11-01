import 'dart:convert';
import 'package:connect/chat_page.dart';
import 'package:connect/users_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'account_page.dart';
import 'config_file.dart';
import 'theme_notifier.dart'; // Import ThemeNotifier

class UserChatsList extends StatefulWidget {
  @override
  _UserChatList createState() => _UserChatList();
}

class _UserChatList extends State<UserChatsList> {
  bool _isLoading = true;
  List<dynamic> _chats = []; // Store chats here
  int _offset = 0; // Offset for pagination
  bool _hasMore = true; // Flag to control fetching more
  final int _limit = 10; // Number of chats per request
  bool _isFetchingMore = false; // Track if more chats are being fetched
  TextEditingController _searchController = TextEditingController(); // Controller for search input

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUserChats();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserChats() async {
    if (!_hasMore || _isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) {
      final url = '${ApiConfig.baseUrl}/chats/my-chats?limit=$_limit&offset=$_offset';
      final headers = {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      try {
        final response = await http.get(Uri.parse(url), headers: headers);

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);

          setState(() {
            if (data.isEmpty) {
              _hasMore = false; // No more chats to fetch
            } else {
              _chats.addAll(data); // Append new chats
              _offset += _limit; // Increment offset for next request
            }
            _isLoading = false;
            _isFetchingMore = false; // Fetching completed
          });
        } else {
          setState(() {
            _isLoading = false;
            _isFetchingMore = false; // Fetching completed with error
          });
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false; // Fetching completed with error
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _isFetchingMore = false; // No token available
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _hasMore) {
      // User scrolled to the end of the list
      _fetchUserChats();
    }
  }
  Future<void> _searchChats() async {
    // Handle create chat button pressed
  }

  void _createChat() {
    // Handle create chat button pressed
  }


  String _getTimeDifference(String lastUpdated) {
    // Parse the string into a DateTime object in UTC
    DateTime lastUpdatedDate = DateTime.parse(lastUpdated).toUtc();

    // Get the current time and its timezone offset
    final now = DateTime.now();
    final timezoneOffset = now.timeZoneOffset;

    // Adjust the last updated date according to the local timezone
    DateTime localDate = lastUpdatedDate.add(timezoneOffset);

    final difference = now.difference(localDate).inMinutes;

    if (difference < 60) {
      return '$difference min ago';
    } else if (difference < 1440) {
      final hours = (difference / 60).floor();
      return '$hours hr ago';
    } else {
      final days = (difference / 1440).floor();
      return '$days days ago';
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
          Padding(
            padding: const EdgeInsets.only(top:40, left: 20, bottom: 0, right: 20),
            child: Row(
              children: [
                TextButton(
                  onPressed: _createChat, // Action for create chat button
                  child: Icon(Icons.notes_outlined, color: isDarkMode ? Colors.white : Colors.black),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Chats',
                      filled: true,
                      fillColor: isDarkMode ? Colors.black : Colors.white, // Background color based on theme
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54, // Hint text color based on theme
                        fontFamily: 'KdamThmorPro',
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
                SizedBox(width: 8.0),
                TextButton(
                  onPressed: () {
                    // Add action for right-side button
                  },
                  child: Icon(Icons.arrow_forward_outlined, color: isDarkMode ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _chats.length + (_hasMore ? 1 : 0), // Add 1 for the loading indicator
              itemBuilder: (context, index) {
                if (index == _chats.length) {
                  // Display loading indicator only if there are more chats to load
                  return _isFetchingMore ? Center(child: CircularProgressIndicator()) : Container();
                }
                final chat = _chats[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        chat['name'] ?? 'No Name',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16.0,
                          fontFamily: 'KdamThmorPro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        (chat['last_message'] != null && chat['last_message'].length > 500)
                            ? '${chat['last_message'].substring(0, 500)}...'
                            : chat['last_message'] ?? '',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black,
                          fontSize: 12.0,
                          fontFamily: 'KdamThmorPro',
                        ),
                      ),
                      trailing: Text(
                        _getTimeDifference(chat['updated_at']),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                      onTap: () {
                        final chatId = chat['id']; // Ensure this value is not null and valid
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return ChatPage(chatId: chatId); // Pass the user ID
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
                    ),
                    Divider(
                      color: isDarkMode ? Colors.white24 : Colors.black12, // Adjust color for dark/light mode
                      thickness: 1, // Adjust thickness if needed
                      indent: 20, // Optional: add padding to start
                      endIndent: 20, // Optional: add padding to end
                    ),
                  ],
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
              icon: Icon(Icons.chat, color: isDarkMode ? Colors.white : Colors.black),
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
