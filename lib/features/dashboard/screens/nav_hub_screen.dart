// lib/features/dashboard/screens/nav_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:trirecall/features/dashboard/screens/home_screen.dart';
import 'package:trirecall/features/subjects/screens/subjects_list_screen.dart';
import 'package:trirecall/features/topics/screens/all_topics_screen.dart';
import 'package:trirecall/features/settings/screens/settings_screen.dart';

class NavHubScreen extends StatefulWidget {
  const NavHubScreen({super.key});

  @override
  State<NavHubScreen> createState() => _NavHubScreenState();
}

class _NavHubScreenState extends State<NavHubScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AllTopicsScreen(),
    SubjectsListScreen(),
    SettingsScreen(),
  ];

  // The name of this function is updated for clarity.
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      // --- REFACTORED WIDGET ---
      bottomNavigationBar: NavigationBar(
        // The selected index determines which destination gets the indicator pill.
        selectedIndex: _selectedIndex,
        
        // The callback is now semantically named `onDestinationSelected`.
        onDestinationSelected: _onDestinationSelected,
        
        // The theme automatically handles the background color, selected/unselected
        // item colors, and the indicator color and shape. No manual styling needed!
        
        // We now use a list of `NavigationDestination` widgets.
        destinations: const <NavigationDestination>[
          NavigationDestination(
            // Best Practice: Use outlined icons for inactive tabs...
            icon: Icon(Icons.today_outlined),
            // ...and filled icons for the active tab for clear visual distinction.
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'All Topics',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}