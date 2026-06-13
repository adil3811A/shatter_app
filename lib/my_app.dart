import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'screens/chats_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shatter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0E13), // Match background color from screenshot
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),     // Violet accent
          secondary: Color(0xFFC5B3F9),   // Lavender accent
          surface: Color(0xFF1B1724),     // Cards/containers background
        ),
        useMaterial3: true,
      ),
      home: const ShatterAppShell(),
    );
  }
}

class ShatterAppShell extends StatefulWidget {
  const ShatterAppShell({super.key});

  @override
  State<ShatterAppShell> createState() => _ShatterAppShellState();
}

class _ShatterAppShellState extends State<ShatterAppShell> {
  int _currentIndex = 0; // Set Chats (index 0) as default home screen
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pages to swipe between
    final List<Widget> screens = const [
      ChatsScreen(),
      ContactsScreen(),
      SettingsScreen(),
      ProfileScreen(),
    ];

    return PopScope(
      // Allow popping (exiting) only when we are on the Chats screen (index 0)
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // If not on Chats, intercept and navigate back to Chats
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentIndex = 0;
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0E13),
        extendBody: true, // Allows the PageView to draw underneath the bottom nav bar for a premium look
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: screens,
        ),
        bottomNavigationBar: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 12.0,
            ),
            child: ShatterBottomNavBar(
              currentIndex: _currentIndex,
              pageController: _pageController,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
