import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_app/screens/auth/login_screen.dart';
import 'package:ticket_app/screens/ticket_screen.dart';
import '../../models/tracking.dart';

import '../loading_screen.dart';
import 'auth_screen.dart';

class MainScreen extends StatefulWidget {
  final Tracking tracking;
  const MainScreen(this.tracking, {super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return LoadingScreen(widget.tracking);
          } else{
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
