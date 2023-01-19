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
  bool finish = false;
  final user = FirebaseAuth.instance.currentUser!;
  var firstName = "";
  var lastName = "";
  late Timer _timer;

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
    // Timer Duration
    const timerDuration = Duration(milliseconds: 1);
    _timer = Timer.periodic(timerDuration, (timer) {
      setState(() {});
    });
    if(mounted) {
      finish = true;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
              if (widget.tracking.activeTicket)...[
                TicketInformation(
                  ticketHolderName: "$firstName $lastName",
                  ticketId: widget.tracking.ticket.firebaseId??"Loading...",
                  ticketDate: '${DateTime.parse(widget.tracking.ticket.startTime).day}.${DateTime.parse(widget.tracking.ticket.startTime).month}.${DateTime.parse(widget.tracking.ticket.startTime).year}',
                  ticketTime: '${DateTime.parse(widget.tracking.ticket.startTime).hour}:${DateTime.parse(widget.tracking.ticket.startTime).minute > 10 ? DateTime.parse(widget.tracking.ticket.startTime).minute :  DateTime.parse(widget.tracking.ticket.startTime).minute.toString().padLeft(2, '0') }',
                  latitude: widget.tracking.latitude.toString(),
                  longitude: widget.tracking.longitude.toString(),
                  address: widget.tracking.address,
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildStartTripButton(widget.tracking.startTrip, 'Fahrt starten', primaryColor),
                    buildEndTripButton(widget.tracking.stopTrip, 'Fahrt beenden', secondaryColor),
                  ],
                ),
              ),
              if (widget.tracking.devModeEnabled) ...[
                GpsTestData(
                  latitude: widget.tracking.latitude.toString(),
                  longitude: widget.tracking.longitude.toString(),
                  altitude: widget.tracking.altitude.toString(),
                  speed: widget.tracking.speed.toString(),
                  address: widget.tracking.address,
                )
              ]
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
            onPressed: widget.tracking.activeTicket ?  null : tripFunction,
            style: ButtonStyle(
              backgroundColor: widget.tracking.activeTicket ?  MaterialStateProperty.all<Color>(accentColor3) : MaterialStateProperty.all<Color>(color),
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
            onPressed: widget.tracking.activeTicket ? tripFunction : null,
            style: ButtonStyle(
              backgroundColor: widget.tracking.activeTicket ?  MaterialStateProperty.all<Color>(color) : MaterialStateProperty.all<Color>(accentColor3),
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
