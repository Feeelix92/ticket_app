import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ticket_app/screens/map_screen.dart';
import 'package:ticket_app/screens/ticket_history_screen.dart';
import 'package:ticket_app/screens/ticket_screen.dart';
import '../colors.dart';
import '../models/locationPoint.dart';
import '../models/ticket.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
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
  void initState() {
    checkGps();
    getLocation();
    getLocationFromStream();
    getAddressFromLatLng();
    super.initState();
    _saveLocations();
  }

  Future<void> _saveLocations() async{
    var counter = 0;
    const oneSec = Duration(seconds:10);
    Timer.periodic(oneSec, (Timer t) => setState(() {
      counter = counter+1;
      print(counter);
      print('$latitude $longitude');
      print(address);
      print('Stream paused: ${positionStream.isPaused}');
      // print(_address);
    }));
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

  getLocation() async {
    currentPosition =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(currentPosition.latitude);
    print(currentPosition.longitude);
    latitude = currentPosition.latitude.toString();
    longitude = currentPosition.longitude.toString();

    setState(() {
      //refresh UI
    });
  }

  getLocationFromStream() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {
      print(position.latitude);
      print(position.longitude);
      currentPosition = position;
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();

      setState(() {
        //refresh UI on update
      });
    });
  }

  getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);
      Placemark place = placemarks[0];
      address = "${place.street}, \n${place.postalCode} ${place.locality} \n ${place
          .administrativeArea}, ${place.country}";
      print(address);
      setState(() {
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
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
          ],
        ),
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
