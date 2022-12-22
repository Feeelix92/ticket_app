import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_app/colors.dart';
import 'package:ticket_app/models/initDatabase.dart';
import 'package:ticket_app/models/csv_reader.dart';
import 'package:ticket_app/models/journey_detail.dart';
import 'package:ticket_app/models/nearby_stops.dart';
import 'package:ticket_app/models/tracking.dart';
import '../models/departure_board.dart';
import '../models/locationPoint.dart';
import '../models/ticket.dart';
import '../widgets/bold_styled_text.dart';
import '../widgets/ticket_information.dart';

class TicketScreen extends StatefulWidget {
  final Tracking tracking;
  const TicketScreen({Key? key, required this.tracking})
      : super(key: key);

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  // API Objects
  late Future<DepartureBoard> futureDepartureBoard;
  late Future<NearbyStops> futureNearbyStops;
  late Future<JourneyDetails> futureJourneyDetails;
  // Ticket
  var ticketHelper = TicketDatabaseHelper();
  late var ticketFuture ;
  late Ticket ticket ;
  bool _ticketActive = false;
  // GNNS Data
  var _latitude = 0.0;
  var _longitude = 0.0;
  var _altitude = 0.0;
  var _speed = 0.0;
  var _address = "";

  _saveLocationPoint() async {
    loadPreferences();
    var id = ticket.id;
    var locationHelper = LocationPointDatabaseHelper();
    var locationPointFuture = locationHelper.createLocationPoint(
        _latitude, _longitude, _altitude,
        _speed, id, '');
  }

  loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _latitude = prefs.getDouble('latitude') ?? 0;
    _longitude = prefs.getDouble('longitude') ?? 0;
    _altitude = prefs.getDouble('altitude') ?? 0;
    _speed = prefs.getDouble('speed') ?? 0;
    setState(() {
      //refresh UI
    });
  }

  _startTrip() async {
    if(!_ticketActive){
      _ticketActive = true;
      print("TRIP STARTED:");
      var startLocation = _getLocation();
      print(startLocation);
      ticketFuture = ticketHelper.createTicket(DateTime.now().toString());
      _getTicket();
      // Timer to periodic save the LocationPoints
      const oneSec = Duration(seconds:1);
      Timer.periodic(oneSec, (timer) {
        _saveLocationPoint();
        if(!_ticketActive) {
          timer.cancel();
        }
      });
    }
  }

  _stopTrip() async {
    if(_ticketActive){
      _ticketActive = false;
      print("TRIP STOPED:");
      var endLocation = _getLocation();
      print(endLocation);
    }
  }


  _getTicket() async {
    ticket = await ticketFuture;
  }

  Future<Position> _getLocation() async {
    var currentPosition =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      //refresh UI
    });
    return currentPosition;
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
                longitude: _longitude.toString(),
                latitude: _latitude.toString(),
                address: _address
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildStartTripButton(_startTrip, 'Fahrt starten', primaryColor),
                  buildEndTripButton(_stopTrip, 'Fahrt beenden', secondaryColor),
                ],
              ),
            ),
            GpsTestData(
                latitude: _latitude.toString(),
                longitude: _longitude.toString(),
                altitude: _altitude.toString(),
                speed: _speed.toString(),
                address: _address
            ),
          ],
        ),
      ),
    );
  }

  Center buildStartTripButton(tripFunction, text, color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: _ticketActive ? null : tripFunction,
            style: ButtonStyle(
              backgroundColor: _ticketActive ?  MaterialStateProperty.all<Color>(accentColor3) : MaterialStateProperty.all<Color>(color),
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
            onPressed: _ticketActive ? tripFunction : null,
            style: ButtonStyle(
              backgroundColor: _ticketActive ?  MaterialStateProperty.all<Color>(color) : MaterialStateProperty.all<Color>(accentColor3),
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
