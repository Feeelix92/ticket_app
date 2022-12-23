import 'dart:async';
import 'package:flutter/material.dart';
import '../models/tracking.dart';
import '../widgets/navigation_bar.dart';

class LoadingScreen extends StatefulWidget {
  final Tracking tracking;
  const LoadingScreen(this.tracking, {super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MyNavigationBar(
          tracking: widget.tracking,
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
