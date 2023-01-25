import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ticket_app/models/ticket.dart';
import 'billing.dart';
import 'departure_board.dart';
import 'journey_detail.dart';
import 'locationPoint.dart';
import 'nearby_stops.dart';

class Tracking {
  //Dev Mode
  bool devModeEnabled = true;

  // API Objects
  late Future<DepartureBoard> futureDepartureBoard;
  late Future<NearbyStops> futureNearbyStops;
  late Future<JourneyDetails> futureJourneyDetails;

  // Timer Duration
  final timerDuration = const Duration(seconds: 2);

  // GNNS
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late List<LocationPoint> _ride;
  var oldLatitude = 0.0;
  var oldLongitude = 0.0;
  var calculatedDistance = 0.0;

  var latitude = 0.0;
  var longitude = 0.0;
  var altitude = 0.0;
  var speed = 0.0;
  var address = "";
  late Position currentPosition;
  late Position startPosition;
  late Position endPosition;
  late StreamSubscription<Position> positionStream;

  // Ticket
  var ticketHelper = TicketDatabaseHelper();
  late var ticketFuture;
  late Ticket ticket;
  bool activeTicket = false;
  late User user = FirebaseAuth.instance.currentUser!;

  // Billing
  var billingtHelper = BillingDatabaseHelper();

  void getTicket() async {
    ticket = await ticketFuture;
  }

  void saveLocationPoint() async {
    var id = ticket.id;
    var locationHelper = LocationPointDatabaseHelper();

    if (latitude.floor() != 0 || longitude.floor() != 0) {
      if (oldLatitude.floor() != 0 || oldLongitude.floor() != 0) {
        if (latitude != oldLatitude || longitude != oldLongitude) {
          print('Position has changed!!!!');
          locationHelper.createLocationPoint(latitude, longitude, altitude,
              speed, id, DateTime.now().toString(), address);
          calculatedDistance += _getDistanceBetween(
              latitude, longitude, oldLatitude, oldLongitude);
        }
        ticket.calculatedDistance =
            double.parse((calculatedDistance).toStringAsFixed(4));
      }
      oldLatitude = latitude;
      oldLongitude = longitude;
    } else {
      return;
    }
  }

  void startTrip() async {
    if (!activeTicket) {
      activeTicket = true;
      print("TRIP STARTED:");
      // Timer to periodic save the LocationPoints
      calculatedDistance = 0.0;
      saveLocations();
    }
  }

  void stopTrip() async {
    if (activeTicket) {
      activeTicket = false;
      print("TRIP STOPED:");
    }
  }

  Future<void> saveLocations() async {
    ticketFuture = ticketHelper.createTicket(DateTime.now().toString());
    getTicket();
    var counter = 0;
    futureNearbyStops = fetchNearbyStops(currentPosition.latitude.toString(),
        currentPosition.longitude.toString());
    startPosition = currentPosition;
    futureNearbyStops.then((nearbyStops) {
      print('_________________________');
      print('nearby Stop:');
      print(nearbyStops.stopLocationOrCoordLocation![0].stopLocation?.name);
      ticket.startStation =
          nearbyStops.stopLocationOrCoordLocation![0].stopLocation?.name;
      ticket.startLatitude = startPosition.latitude;
      ticket.startLongitude = startPosition.longitude;
      ticketHelper.updateticket(ticket);

      saveFirebaseTicket(
          GeoPoint(startPosition.latitude, startPosition.longitude),
          ticket.startStation!,
          DateTime.parse(ticket.startTime),
          user.uid);
    });
    Timer.periodic(timerDuration, (timer) {
      counter = counter + 1;
      print(counter);
      print('${currentPosition.latitude} ${currentPosition.longitude}');
      print('Stream paused: ${positionStream.isPaused}');
      saveLocationPoint();
      if (!activeTicket) {
        timer.cancel();
        ticket.endTime = DateTime.now().toString();
        futureNearbyStops = fetchNearbyStops(
            currentPosition.latitude.toString(),
            currentPosition.longitude.toString());
        endPosition = currentPosition;
        futureNearbyStops.then((nearbyStops) {
          ticket.endStation =
              nearbyStops.stopLocationOrCoordLocation![0].stopLocation?.name;
          ticket.endLatitude = endPosition.latitude;
          ticket.endLongitude = endPosition.longitude;
          ticket.ticketPrice = _calculateTicketPrice();
          ticketHelper.updateticket(ticket);

          stopFirebaseTicket(
              GeoPoint(endPosition.latitude, endPosition.longitude),
              ticket.endStation!,
              DateTime.parse(ticket.endTime!));
        });
      }
    });
  }

  _calculateTicketPrice() {
    // BeeLine = Luftlinie der Fahrt
    double beeLine = _getDistanceBetween(ticket.startLatitude!,
        ticket.startLongitude!, ticket.endLatitude!, ticket.endLongitude!);
    ticket.beeLine = double.parse((beeLine).toStringAsFixed(4));
    // Zeitunterschied
    DateTime startTime = DateTime.parse(ticket.startTime);
    DateTime endTime = DateTime.parse(ticket.endTime!);
    Duration timeDifference = endTime.difference(startTime);
    // Preisschlüssel
    double ticketPrice = 0.0;
    double serviceCharge = 1.60;
    double kilometerPrice = 0.05;
    double maxTicketPrice = 13.00;

    // Ticket kostet erst Geld, wenn mindestens 100 m zurückgelegt wurden und 2 Minuten vergangen sind
    if (beeLine >= 0.1 &&
        calculatedDistance >= 0.1 &&
        timeDifference.inSeconds >= 120) {
      var distanceForPricing =
          double.parse(((beeLine + calculatedDistance) / 2).toStringAsFixed(2));
      // Tarifierung
      if (distanceForPricing <= 5.0) {
        ticketPrice = serviceCharge + (5.0 * kilometerPrice);
      } else if (distanceForPricing > 5.0 && distanceForPricing <= 10.0) {
        ticketPrice = serviceCharge + (10.0 * kilometerPrice);
      } else if (distanceForPricing > 10.0 && distanceForPricing <= 30.0) {
        ticketPrice = serviceCharge + (30.0 * kilometerPrice);
      } else if (distanceForPricing > 30.0 && distanceForPricing <= 50.0) {
        ticketPrice = serviceCharge + (50.0 * kilometerPrice);
      } else if (distanceForPricing > 50.0 && distanceForPricing <= 100.0) {
        ticketPrice = serviceCharge + (100.0 * kilometerPrice);
      } else if (distanceForPricing > 100.0) {
        ticketPrice = maxTicketPrice;
      }
      return ticketPrice;
    } else {
      return ticketPrice;
    }
  }

  // Funktion ermittelt die Luftlinie zwischen zwei Punkten in Kilometern
  _getDistanceBetween(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    double distanceInMeters = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    double distanceInKilometers = distanceInMeters / 1000;
    return distanceInKilometers;
  }

  Future saveFirebaseTicket(GeoPoint startPoint, String startStation,
      DateTime startTime, String authId) async {
    await FirebaseFirestore.instance.collection('tickets').add({
      'startPoint': startPoint,
      'startStation': startStation,
      'startTime': startTime,
      'authId': authId,
    }).then((savedTicket) {
      ticket.firebaseId = savedTicket.id;
      ticketHelper.updateticket(ticket);
    });
  }

  Future stopFirebaseTicket(
      GeoPoint endPoint, String endStation, DateTime endTime) async {
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticket.firebaseId)
        .update({
      'endPoint': endPoint,
      'endStation': endStation,
      'endTime': endTime
    });
  }

  void getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      address =
          "${place.street}, \n${place.postalCode} ${place.locality}\n${place.administrativeArea}, ${place.country}";
    } catch (e) {
      print(e);
    }
  }

  Future<Position> getLocation() async {
    var currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return currentPosition;
  }

  void checkGps() async {
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
      if (haspermission) {}
    } else {
      if (kDebugMode) {
        print("GPS Service is not enabled, turn on GPS location");
      }
    }
  }

  void getLocationFromStream() async {
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
        ));

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      currentPosition = position;
      latitude = position.latitude;
      longitude = position.longitude;
      altitude = position.altitude;
      speed = position.speed;
      getAddressFromLatLng(latitude, longitude);
    });
  }
}

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
