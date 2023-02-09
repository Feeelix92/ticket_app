import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_app/models/tracking.dart';
import 'package:ticket_app/screens/map_screen.dart';
import 'package:ticket_app/screens/profile_screen.dart';
import 'package:ticket_app/screens/ticket_history_screen.dart';
import 'package:ticket_app/screens/ticket_screen.dart';
import '../colors.dart';
import '../screens/auth/main_screen.dart';

class MyNavigationBar extends StatefulWidget {
  final String title;
  const MyNavigationBar({Key? key, required this.title})
      : super(key: key);

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _currentIndex = 0;
  final user = FirebaseAuth.instance.currentUser!;
  var firstName = "";
  var lastName = "";

  getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localFirstName = prefs.getString('firstName');
    final String? localLastName = prefs.getString('lastName');
    setState(() {
      firstName = localFirstName!;
      lastName = localLastName!;
    });
  }

  List<Widget> _children() => [
        const TicketScreen(),
        const MapScreen(),
        const TicketHistory(),
      ];

  void onTappedBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    getUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Tracking trackingService = Provider.of<Tracking>(context);
    final List<Widget> children = _children();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      endDrawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Text('$firstName $lastName',
                  style: TextStyle(color: accentColor2)),
            ),
            ListTile(
              title: const Text('Profil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ProfileScreen();
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: MaterialButton(
                  onPressed: () => {
                    FirebaseAuth.instance.signOut(),
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const MainScreen();
                    }))
                  },
                  color: primaryColor,
                  child: Text('Logout', style: TextStyle(color: accentColor2)),
                ),
              ),
            ),
          ],
        ),
      ),
      body: children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num_outlined),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Karte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historie',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: secondaryColor,
        onTap: onTappedBar,
      ),
    );
  }
}
