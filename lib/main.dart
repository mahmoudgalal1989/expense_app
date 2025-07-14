import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

// Main page with bottom navigation
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // List of pages to display
  static final List<Widget> _pages = <Widget>[
    const TransactionsPage(),
    const SummaryPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2022), // #1C2022 solid color
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 22,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color.fromRGBO(255, 255, 255, 0.7),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt),
                  label: 'Transactions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Summary',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder pages
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  // Font family constant for consistent usage
  static const String fontFamily = 'Sora';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C0F11), // Dark background color
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1E1F), Color(0xFF0C0F11)],
              ),
            ),
          ),

          // Main content - Centered with Stack
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Items Container Image
                    Image.asset(
                      'assets/svg/Progress Items Container.png',
                      width: 244.0,
                      height: 192.0,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 24.0),

                    // Main message
                    Text(
                      "Let's start your journey!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        fontFamily: fontFamily,
                      ),
                    ),

                    const SizedBox(height: 8.0),

                    // Subtitle
                    Text(
                      'Add your first transaction to start.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF8A8A8A),
                        fontSize: 13.0,
                        height: 1.5,
                        fontFamily: fontFamily,
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Add expense button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16.0),
                          child: Ink(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFEFF2F6), Color(0xFFDFDFDF)],
                                stops: [0.01, 1.0],
                              ),
                            ),
                            child: Text(
                              'Add expense',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF151A1F),
                                fontFamily: fontFamily,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                height: 24.0 / 14.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Implement transaction card widget
  // Widget _buildPlaceholderCard() {
  //   return Container(
  //     height: 80.0,
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF1A1E1F),
  //       borderRadius: BorderRadius.circular(12.0),
  //       border: Border.all(color: const Color(0xFF2A2F31), width: 1.0),
  //     ),
  //     child: const Opacity(
  //       opacity: 0.3,
  //       child: Center(
  //         child: Text(
  //           'Transaction Card',
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Summary Page'));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings Page'));
  }
}
