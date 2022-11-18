import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MyBottomNavigationBar(
          title: 'Easy-Ticket',
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: const Alignment(0, 0),
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).colorScheme.secondary
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: const Text(
            "Easy-Ticket",
            style: TextStyle(
              fontSize: 50.0,
              color: Colors.white,
            ),
          )),
    );
  }
}
