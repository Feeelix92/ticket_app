import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:ticket_app/colors.dart';
import 'package:ticket_app/models/csv_reader.dart';
import '../models/locationPoint.dart';

import '../models/ticket.dart';
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
  late List<LocationPoint> _ride;
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

  Future<void> _backgroundTracking() async {
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _getAddressFromLatLng();
            _latitude = position.latitude.toString();
            _longitude = position.longitude.toString();
            _altitude = position.altitude.toString();
            _speed = position.speed.toString();
            //Todo
            // _ride.add(LocationPoint(id: id, latitude: position.latitude, longitude: position.longitude, altitude: position.altitude, speed: position.speed, ticketid: ticketid, address: _getAddressFromLatLng())); //needs the IDs
            if (kDebugMode) {
              print('position update:');
              print(_currentPosition);
              // print(_address);
            }
          });
        }
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

  _startTrip() async {
    if(_positionStream.isPaused){
      _positionStream.resume();
    }
    if (kDebugMode) {
      print('trip started');
      print('Stream is paused:');
      print(_positionStream.isPaused);
      print(_currentPosition);
      var ticket = const Ticket(id: 1, startTime: '10:00', endTime: '10:30', startStation: 'Friedberg Bahnhof', endStation: 'Gießen Bahnhof');
      var locationPoint = LocationPoint(id: 1, latitude: 123.00, longitude: 123.00, altitude: 1200, speed: 1.4, ticketid: ticket.id, address: '');
      print(ticket);
      print(locationPoint);
      var ticketHelper = TicketDatabaseHelper();
      var locationHelper = LocationPointDatabaseHelper();
      ticketHelper.insertTicket(ticket);
      locationHelper.insertLocation(locationPoint);
    }
  }

  _stopTrip() async {
    _positionStream.pause();
    if (kDebugMode) {
      print('trip stopped');
      print('Stream is paused:');
      print(_positionStream.isPaused);
      print(_currentPosition);
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
    super.initState();
    if (mounted) {
      _checkGps();
      _backgroundTracking();
      var csv = CsvReader();
      csv.loadAsset();
    }
    //Todo
    // _ride.add(LocationPoint(id: id, latitude: position.latitude, longitude: position.longitude, altitude: position.altitude, speed: position.speed, ticketid: ticketid, address: _getAddressFromLatLng())); //needs the IDs
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
                children: [
                  buildTripButton(_startTrip, 'Fahrt starten', primaryColor),
                  buildTripButton(_stopTrip, 'Fahrt beenden', secondaryColor),
                ],
              ),
            ),
            GpsTestData(
                latitude: _latitude,
                longitude: _longitude,
                altitude: _altitude,
                speed: _speed,
                address: _address),
          ],
        ),
      ),
    );
  }

  Center buildTripButton(tripFunction, text, color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: tripFunction,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(color),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class GpsTestData extends StatelessWidget {
  const GpsTestData({
    Key? key,
    required String latitude,
    required String longitude,
    required String altitude,
    required String speed,
    required String address,
  })  : _latitude = latitude,
        _longitude = longitude,
        _altitude = altitude,
        _speed = speed,
        _address = address,
        super(key: key);

  final String _latitude;
  final String _longitude;
  final String _altitude;
  final String _speed;
  final String _address;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoldStyledText(text: 'Test Data:'),
            BoldStyledText(text: 'Latitude: $_latitude'),
            BoldStyledText(text: 'Longitude: $_longitude'),
            BoldStyledText(
              text: 'Altitude: $_altitude',
            ),
            BoldStyledText(
              text: 'Speed: $_speed',
            ),
            Text('Adresse: $_address'),
            // const Text('Address: '),
            //   Text(_address),
          ],
        ),
      ),
    );
  }
}
