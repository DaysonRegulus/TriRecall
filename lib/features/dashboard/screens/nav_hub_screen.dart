import 'package:flutter/material.dart';
import 'package:trirecall/features/dashboard/screens/home_screen.dart';
import 'package:trirecall/features/subjects/screens/subjects_list_screen.dart';
import 'package:trirecall/features/topics/screens/all_topics_screen.dart';

class NavHubScreen extends StatefulWidget {
  const NavHubScreen({super.key});

  @override
  State<NavHubScreen> createState() => _NavHubScreenState();
}

class _NavHubScreenState extends State<NavHubScreen> {
  int _selectedIndex = 0; // The index of the currently selected tab.

  // A list of the main screens for our app. The order here
  // must match the order of the BottomNavigationBarItems.
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),         // Index 0
    AllTopicsScreen(),      // Index 1
    SubjectsListScreen(), // Index 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body will be the screen corresponding to the selected tab index.
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'All Topics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Subjects',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Theming for the navigation bar
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Ensures all items are always visible
      ),
    );
  }
}