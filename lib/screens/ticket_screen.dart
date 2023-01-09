import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ticket_app/colors.dart';
import 'package:ticket_app/models/initDatabase.dart';
import 'package:ticket_app/models/csv_reader.dart';
import 'package:ticket_app/models/tracking.dart';
import '../widgets/bold_styled_text.dart';
import '../widgets/ticket_information.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketScreen extends StatefulWidget {
  final Tracking tracking;

  const TicketScreen({Key? key, required this.tracking}) : super(key: key);

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late bool activeTicket;
  late Position currentPosition;
  var latitude = 0.0;
  var longitude = 0.0;
  var altitude = 0.0;
  var speed = 0.0;
  var address = "";
  bool finish = false;
  final user = FirebaseAuth.instance.currentUser!;
  var ticketID = "";
  var firstName = "";
  var lastName = "";

  _getTicketStatus() {
    activeTicket = widget.tracking.activeTicket;
    setState(() {});
    return activeTicket;
  }

  _getCurrentPosition(){
    currentPosition = widget.tracking.currentPosition;
    latitude = currentPosition.latitude;
    longitude = currentPosition.longitude;
    altitude = currentPosition.altitude;
    speed = currentPosition.speed;
    setState(() {
      finish = true;
    });
    return currentPosition;
  }

  _getAddress(){
    address = widget.tracking.address;
    setState(() {});
    return address;
  }

  void startTrip() async {
    if (!_getTicketStatus()) {
      widget.tracking.activeTicket = true;
      print("TRIP STARTED:");
      // Timer to periodic save the LocationPoints
      widget.tracking.saveLocations();

      saveTicket(
          GeoPoint(latitude, longitude),
          DateTime.now(),
          user.uid
      );
    }
  }

  Future saveTicket(GeoPoint startPoint, DateTime startTime, String authId) async {
    await FirebaseFirestore.instance.collection('tickets').add({
      'startPoint': startPoint,
      'startTime': startTime,
      'authId': authId,
    }).then((savedTicket) {
      setState(() {
        ticketID = savedTicket.id;
      });
    });
  }

  void stopTrip() async {
    if (_getTicketStatus()) {
      widget.tracking.activeTicket = false;
      print("TRIP STOPED:");

      stopTicket(
          GeoPoint(latitude, longitude),
          DateTime.now()
      );
    }
  }

  Future stopTicket(GeoPoint endPoint, DateTime endTime) async{
    await FirebaseFirestore.instance.collection('tickets').doc(ticketID).update({
      'endPoint': endPoint,
      'endTime': endTime
    });
  }

  getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localFirstName = prefs.getString('firstName');
    final String? localLastName = prefs.getString('lastName');
    setState(() {
      firstName = localFirstName!;
      lastName = localLastName!;
    });
  }

  @override
  void initState() {
    getUserName();
    if (mounted) {
      initDatabase().initializeDB();
      var csv = CsvReader();
      csv.loadAsset();
    }
    //Todo
    // _ride.add(LocationPoint(id: id, latitude: position.latitude, longitude: position.longitude, altitude: position.altitude, speed: position.speed, ticketid: ticketid, address: _getAddressFromLatLng())); //needs the IDs
    super.initState();
    _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    if (finish){
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TicketInformation(
                ticketHolderName: "$firstName $lastName",
                ticketId: ticketID,
                ticketDate: DateFormat('dd.MM.yyyy').format(DateTime.now()),
                ticketTime: '${DateFormat('kk:mm').format(DateTime.now())} Uhr',
                latitude: _getCurrentPosition().latitude.toString(),
                longitude: _getCurrentPosition().longitude.toString(),
                address: _getAddress(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildStartTripButton(startTrip, 'Fahrt starten', primaryColor),
                    buildEndTripButton(stopTrip, 'Fahrt beenden', secondaryColor),
                  ],
                ),
              ),
              GpsTestData(
                latitude: _getCurrentPosition().latitude.toString(),
                longitude: _getCurrentPosition().longitude.toString(),
                altitude: _getCurrentPosition().altitude.toString(),
                speed: _getCurrentPosition().speed.toString(),
                address: _getAddress(),
              ),
            ],
          ),
        ),
      );
    }
    return const Text('Loading');
  }

  Center buildStartTripButton(tripFunction, text, color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: _getTicketStatus() ? null : tripFunction,
            style: ButtonStyle(
              backgroundColor: _getTicketStatus()
                  ? MaterialStateProperty.all<Color>(accentColor3)
                  : MaterialStateProperty.all<Color>(color),
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
  Center buildEndTripButton(tripFunction, text, color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: _getTicketStatus() ? tripFunction : null,
            style: ButtonStyle(
              backgroundColor: _getTicketStatus()
                  ? MaterialStateProperty.all<Color>(color)
                  : MaterialStateProperty.all<Color>(accentColor3),
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
  })
      : _latitude = latitude,
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
