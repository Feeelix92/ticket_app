import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ticket_app/screens/auth/auth_screen.dart';
import 'package:ticket_app/screens/loading_screen.dart';
import 'package:ticket_app/screens/auth/main_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'colors.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'models/tracking.dart';
import 'package:firebase_core/firebase_core.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    if (kDebugMode) {
      print("Native called background task:");
    } //simpleTask will be emitted here.
    return Future.value(true);
  });
}

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager().registerOneOffTask("Tracking", "_saveLocations");

  await Firebase.initializeApp();
  runApp(MyApp(Tracking()));
}

class MyApp extends StatefulWidget {
  final Tracking tracking;
  const MyApp(this.tracking, {super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.tracking.checkGps();
    widget.tracking.getLocationFromStream();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy-Ticket',
      theme: ThemeData(
        primarySwatch: generateMaterialColor(color: primaryColor),
        fontFamily: "Montserrat",
      ),
      home: MainScreen(widget.tracking),
    );
  }
}
