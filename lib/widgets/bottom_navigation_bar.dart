import 'package:flutter/material.dart';
import 'package:ticket_app/screens/map_screen.dart';
import 'package:ticket_app/screens/ticket_history_screen.dart';
import 'package:ticket_app/screens/ticket_screen.dart';
import '../colors.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {

  int _currentIndex = 0;
  final List<Widget> _children = [
    const TicketScreen(),
    const MapScreen(),
    const TicketHistory(),
  ];
  void onTappedBar(int index){
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _children [_currentIndex],
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
