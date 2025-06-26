import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/scam_exposure_screen.dart';
import 'screens/profile_screen.dart';
import 'service/speech_service.dart';
import 'screens/chatscreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpeechService()),
      ],
      child: const Chat165(),
    ),
  );
}

class Chat165 extends StatelessWidget {
  const Chat165({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat165防詐騙',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100], // MODIFY: Consistent light grey background
        appBarTheme: AppBarTheme( // MODIFY: Updated AppBar theme to match Apple style
          elevation: 0.5,
          centerTitle: false,
          backgroundColor: Colors.grey[50], // Light background for AppBar
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Black title text
          ),
          iconTheme: IconThemeData(color: Colors.blue.shade700), // Blue icons for AppBar
        ),
        // ADD: Define BottomNavigationBarTheme for consistency
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[50], // Light background for BottomNav
          selectedItemColor: Colors.blue.shade700, // Blue for selected item
          unselectedItemColor: Colors.grey.shade600, // Grey for unselected items
          type: BottomNavigationBarType.fixed,
          elevation: 0.5,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const RecordDialog(),
    //const ChatScreen(),
    const ScamExposureScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Use IndexedStack to preserve state of pages
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        // Properties like type, selectedItemColor, unselectedItemColor, backgroundColor
        // will now be primarily controlled by the BottomNavigationBarThemeData in ThemeData
        // However, you can still override them here if needed for this specific instance.
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), // Use outlined icons for a lighter feel
            activeIcon: Icon(Icons.home), // Optional: different icon when active
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded), // Use outlined icons
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: '聊天',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined), // Changed to a more relevant "security/exposure" icon
            activeIcon: Icon(Icons.shield),
            label: '騙局曝光',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Use outlined icons
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}