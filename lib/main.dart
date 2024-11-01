import 'package:connect/register_page.dart';
import 'package:connect/user_chats.dart';
import 'package:connect/users_list.dart';
import 'package:connect/websocket_service.dart'; // Import the WebSocketService
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_page.dart';
import 'appearance_page.dart';
import 'language_page.dart';
import 'login_page.dart';
import 'splash_screen.dart';
import 'theme_notifier.dart'; // Import the ThemeNotifier class

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('dark_mode') ?? false;


  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(isDarkMode ? ThemeData.dark() : ThemeData.light()),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WebSocketService()), // Provide WebSocketService
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'San Francisco',
      ),
      routes: {
        '/': (context) => SplashScreen(),
        '/register_page': (context) => FirstNameLastNamePage(),
        '/login_page': (context) => LoginPage(),
        '/account_page': (context) => MyAccount(),
        '/appearance_page': (context) => AppearancePage(),
        '/language_page': (context) => LanguagePage(),
        '/all_messages': (context) => UserChatsList(),
        '/search_users': (context) => UsersList(),
      },
      initialRoute: '/',
    );
  }
}


