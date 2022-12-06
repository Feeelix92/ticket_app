import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:ticket_app/colors.dart';
import 'package:ticket_app/models/initDatabase.dart';
import 'package:ticket_app/models/csv_reader.dart';
import 'package:ticket_app/models/journey_detail.dart';
import 'package:ticket_app/models/nearby_stops.dart';
import '../models/departure_board.dart';
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
  late Future<DepartureBoard> futureDepartureBoard;
  late Future<NearbyStops> futureNearbyStops;
  late Future<JourneyDetails> futureJourneyDetails;
  var ticketHelper = TicketDatabaseHelper();
  late var ticketFuture ;
  late Ticket ticket ;


  _saveLocationPoint(Position position){
    var id = ticket.id;
    var locationHelper = LocationPointDatabaseHelper();
    var locationPointFuture = locationHelper.createLocationPoint(
        position.latitude, position.longitude, position.altitude,
        position.speed, id, '');
    print( locationPointFuture);
}

  _startTrip() async {
    ticketFuture = ticketHelper.createTicket(DateTime.now().toString());
    _getTicket();
    _saveLocationPoint;

    // if (_positionStream.isPaused) {
    //   _positionStream.resume();
    // }
    // if (kDebugMode) {
    //   print('trip started');
    //   print('Stream is paused:');
    //   print(_positionStream.isPaused);
    //   //print(_currentPosition);
    //   //var locationHelper = LocationPointDatabaseHelper();
    //   //var ticketHelper = TicketDatabaseHelper();
    //   //initDatabase().initializeDB();
    //   //var ticket = const Ticket(id: 1, startTime: '10:00', endTime: '10:30', startStation: 'Friedberg Bahnhof', endStation: 'Gießen Bahnhof');
    //   //var ticketFuture = ticketHelper.createTicket(DateTime.now().toString());
    //   //var ticket = await ticketFuture;
    //   //var locationPointFuture = locationHelper.createLocationPoint(123.00,123.00,1200,1.4,ticket.id,'');
    //   //var locationPoint = await locationPointFuture;
    //   //print(ticket);
    //   //print(locationPoint);
    // }
  }

  _stopTrip() async {
    // _positionStream.pause();
    // if (kDebugMode) {
    //   print('trip stopped');
    //   print('Stream is paused:');
    //   print(_positionStream.isPaused);
    //   print(_currentPosition);
    // }
  }


  _getTicket() async {
    ticket = await ticketFuture;
  }

  @override
  void initState() {
    super.initState();
    // API TESTS!
    // @TODO cleanup
    // Fetching NearbyStops for current position
    // futureNearbyStops = fetchNearbyStops('50.3316448', '8.7602899');
    // futureNearbyStops.then((nearbyStops) {
    //   print('_________________________');
    //   print('nearby Stop:');
    //   print(nearbyStops.stopLocationOrCoordLocation![0].stopLocation?.name);
    // });
    // // Date
    // var currentYear = '${DateTime.now().year}';
    // var currentMonth = '${DateTime.now().month}'.padLeft(2,'0');
    // var currentDay = '${DateTime.now().day}'.padLeft(2,'0');
    // var currentDate = '$currentYear-$currentMonth-$currentDay';
    // // Time
    // var currentHour = '${DateTime.now().hour+1}'.padLeft(2,'0');
    // var currentMinute = '${DateTime.now().minute}'.padLeft(2,'0');
    // var currentTime = '$currentHour:$currentMinute';
    // // Fetching DepartureBoard for specific station at date and time
    // futureDepartureBoard = fetchDepartureBoard('Friedberg (Hessen) Bahnhof', currentDate, currentTime);
    // futureDepartureBoard.then((departureBoard) async {
    //   print('_________________________');
    //   print('next Connection:');
    //   print(departureBoard.departure![0].stop);
    //   print(departureBoard.departure![0].name);
    //   print(departureBoard.departure![0].direction);
    //   print(departureBoard.departure![0].date);
    //   print(departureBoard.departure![0].time);
    //   print(departureBoard.departure![0].rtTrack);
    //   print('_________________________');
    //   print('Journey Details:');
    //   var journeyRef = departureBoard.departure![0].journeyDetailRef?.ref;
    //   futureJourneyDetails = fetchJourneyDetails(journeyRef!);
    //   futureJourneyDetails.then((value) => value.stops?.stop?.forEach(
    //           (element) {
    //             print(element.name);
    //           }
    //         ));
    // });
    //End of API Tests
    if (mounted) {
      initDatabase().initializeDB();
      // _checkGps();
      // _backgroundTracking();
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
            // TicketInformation(
            //     ticketHolderName: "Max Mustermann",
            //     ticketId: "12345",
            //     ticketDate: "14.11.2022",
            //     ticketTime: "10:00 Uhr",
            //     longitude: _longitude,
            //     latitude: _latitude,
            //     address: _address),
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
            // GpsTestData(
            //     latitude: _latitude,
            //     longitude: _longitude,
            //     altitude: _altitude,
            //     speed: _speed,
            //     address: _address
            // ),
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
