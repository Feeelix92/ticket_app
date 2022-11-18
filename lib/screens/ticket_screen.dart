import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

import '../widgets/bold_styled_text.dart';
import '../widgets/ticket_information.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  // GPS
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  var _latitude = "";
  var _longitude = "";
  var _altitude = "";
  var _speed = "";
  var _address = "";
  late Position _currentPosition;
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best, //accuracy of the location data
    distanceFilter: 2, //minimum distance (measured in meters) a
    //device must move horizontally before an update event is generated;
  );
  late StreamSubscription<Position> _positionStream;
  var _counter = 0;

  Future<void> _backgroundTracking() async {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _counter = _counter + 1;
        if (kDebugMode) {
          print(_counter);
          print(_positionStream.isPaused);
          print(_currentPosition);
          // print(_address);
        }
      });
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _address =
            "${place.street}, \n${place.postalCode} ${place.locality} \n ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  _checkGps() async {
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

  @override
  void initState() {
    _checkGps();
    super.initState();
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _altitude = position.altitude.toString();
        _speed = position.speed.toString();
      });
    });
    _backgroundTracking();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TicketInformation(
                ticketHolderName: "Max Mustermann",
                ticketId: "12345",
                ticketDate: "14.11.2022",
                ticketTime: "10:00 Uhr",
                longitude: _longitude,
                latitude: _latitude,
                address: _address),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  ElevatedButton(
                    onPressed: null,
                    child: Text('FAHRT STARTEN'),
                  ),
                  ElevatedButton(
                    onPressed: null,
                    child: Text('FAHRT BEENDEN'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                ],
              ),
            ),
            BoldStyledText(
                text: 'Latitude: $_latitude'
            ),
            BoldStyledText(
                text: 'Longitude: $_longitude'
            ),
            BoldStyledText(
              text: 'Altitude: $_altitude',
            ),
            BoldStyledText(
              text: 'Speed: $_speed',
            ),
            Text('Adresse: $_address'),
            Text('Counter: $_counter')
            // const Text('Address: '),
            //   Text(_address),
          ],
        ),
      ),
    );
  }
}
