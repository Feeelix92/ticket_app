import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_app/models/tracking.dart';
import 'package:ticket_app/screens/login_screen.dart';
import 'package:ticket_app/screens/map_screen.dart';
import 'package:ticket_app/screens/ticket_history_screen.dart';
import 'package:ticket_app/screens/ticket_screen.dart';
import '../colors.dart';

class MyNavigationBar extends StatefulWidget {
  final String title;
  final Tracking tracking;
  const MyNavigationBar({Key? key, required this.title, required this.tracking})
      : super(key: key);

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _currentIndex = 0;
  final user = FirebaseAuth.instance.currentUser!;

  List<Widget> _children() => [
    TicketScreen(tracking: widget.tracking),
    MapScreen(tracking: widget.tracking),
    TicketHistory(tracking: widget.tracking),
  ];
  void onTappedBar(int index){
    setState(() {
      _currentIndex = index;
    });
  }
  void refreshPage(){
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Text('Profil'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
                // Then close the drawer
                Navigator.pop(context);
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
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const LoginPage()))
                  },
                  child: const Text('Login'),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: MaterialButton(
                  onPressed: () => {
                    FirebaseAuth.instance.signOut()
                  },
                  color: primaryColor,
                  child: const Text('Logout'),
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
      // Button to refresh TestData
      floatingActionButton: FloatingActionButton(
      onPressed: refreshPage,
      tooltip: 'Increment',
      child: const Icon(Icons.change_circle_outlined),
      ),
    );
  }
}
