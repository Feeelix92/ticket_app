import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ticket_app/screens/loading_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'colors.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:sqflite/sqflite.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    if (kDebugMode) {
      print("Native called background task:");
    } //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager().registerOneOffTask("_TicketScreenState", "_backgroundTracking");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy-Ticket',
      theme: ThemeData(
        primarySwatch: generateMaterialColor(color: primaryColor),
        fontFamily: "Montserrat",
      ),
      home: const LoadingScreen(),
    );
  }
}
