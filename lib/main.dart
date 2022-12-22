import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_app/screens/loading_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'colors.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'models/locationPoint.dart';

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
  Workmanager().registerOneOffTask("_MyNavigationBarState", "_saveLocations");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late List<LocationPoint> _ride;
  var latitude = "";
  var longitude = "";
  var altitude = "";
  var speed = "";
  var address = "";
  late Position currentPosition;
  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    checkGps();
    getLocationFromStream();
    super.initState();
    _saveLocations();
  }

  Future<void> _saveLocations() async{
    var counter = 0;
    const oneSec = Duration(seconds:10);
    Timer.periodic(oneSec, (Timer t) => setState(() {
      counter = counter+1;
      print(counter);
      print('${currentPosition.latitude} ${currentPosition.longitude}');
      print('Stream paused: ${positionStream.isPaused}');
      getAddressFromLatLng(currentPosition.latitude, currentPosition.longitude);
      saveCurrentPosition(currentPosition);
    }));

  }

  saveCurrentPosition(Position currentPosition) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', currentPosition.latitude);
    await prefs.setDouble('longitude', currentPosition.longitude);
    await prefs.setDouble('altitude', currentPosition.altitude);
    await prefs.setDouble('speed', currentPosition.speed);
  }



  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
        } else if (permission == LocationPermission.deniedForever) {
          if (kDebugMode) {
            print("'Location permissions are permanently denied");
          }
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }
      if (haspermission) {
        setState(() {
          //refresh the UI
        });
      }
    } else {
      if (kDebugMode) {
        print("GPS Service is not enabled, turn on GPS location");
      }
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocationFromStream() async {
    //late LocationSettings locationSettings;
    LocationSettings locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2,
        //(Optional) Set foreground notification config to keep the app alive
        //when going to the background
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
          "Bitte die App nicht komplett schließen, Fahrt wird aufgenommen",
          notificationTitle: "Fahrt wird im Background aufgenommen",
          enableWakeLock: true,
        )
    );

    positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {
      currentPosition = position;
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
      setState(() {
        //refresh UI on update
      });
    });
  }

  getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude, longitude);
      Placemark place = placemarks[0];
      address = "${place.street}, \n${place.postalCode} ${place.locality} \n ${place
          .administrativeArea}, ${place.country}";
      setState(() {
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
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
      home: const LoadingScreen(),
    );
  }
}
