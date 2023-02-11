import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticket_app/colors.dart';
import '../models/tracking.dart';
import '../widgets/navigation_bar.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Timer _timer;

  _navigator() {
    _timer = Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MyNavigationBar(
          title: 'Easy-Ticket',
        ),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Tracking>(builder: (context, trackingService, child) {
      if (trackingService.haspermission && trackingService.servicestatus) _navigator();
      return Scaffold(
        body: Center(
          child: trackingService.haspermission && trackingService.servicestatus?
          Container(
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
              )):
              Center(
                  child: CircularProgressIndicator(
                    color: secondaryColor,
                  ))
        ),
      );
    });
  }
}
