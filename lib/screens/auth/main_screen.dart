import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_app/screens/auth/login_screen.dart';
import 'package:ticket_app/screens/ticket_screen.dart';

import '../loading_screen.dart';
import 'auth_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            var widget;
            return LoadingScreen(widget.tracking);
          } else{
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
