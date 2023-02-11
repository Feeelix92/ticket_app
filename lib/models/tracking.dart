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

class Tracking with ChangeNotifier{
  Future init() async {
    print("init");
    getLocationFromStream();
  }
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
  bool finish = false;

  // Billing
  var billingHelper = BillingDatabaseHelper();
  late var billingFuture;
  late Billing billing;

  void getTicket() async {
    ticket = await ticketFuture;
    notifyListeners();
  }

  void getBilling() async {
    billing = await billingFuture;
    notifyListeners();
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
      notifyListeners();
    }
  }

  void stopTrip() async {
    if (activeTicket) {
      activeTicket = false;
      print("TRIP STOPED:");
      notifyListeners();
    }
  }

  Future<void> saveLocations() async {
    finish = false;
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
        futureNearbyStops = fetchNearbyStops(currentPosition.latitude.toString(), currentPosition.longitude.toString());
        endPosition = currentPosition;
        futureNearbyStops.then((nearbyStops) {
          ticket.endStation = nearbyStops.stopLocationOrCoordLocation![0].stopLocation?.name;
          ticket.endLatitude = endPosition.latitude;
          ticket.endLongitude = endPosition.longitude;
          ticket.ticketPrice = _calculateTicketPrice();
          ticketHelper.updateticket(ticket);

          stopFirebaseTicket(
              GeoPoint(endPosition.latitude, endPosition.longitude),
              ticket.endStation!,
              DateTime.parse(ticket.endTime!));
          _createBilling();
        });
      }
    });
    finish = true;
  }

  _createBilling() async {
    var today = DateTime.now();
    var month = DateTime(today.year, today.month);
    var nextMonth = DateTime(month.year, month.month + 1);
    var list = await billingHelper.getBillingsPerMonth(month.toString());
    var tickets = await ticketHelper.tickets();
    var monthlyAmount = 0.0;
    var monthlyDistance = 0.0;

    for (var index in tickets){
      var ticketTime = DateTime.parse(index.startTime);
      var ticketMonth = DateTime(ticketTime.year, ticketTime.month);
      if(ticketMonth == month){
        monthlyAmount += index.ticketPrice??0.0;
        monthlyDistance += index.calculatedDistance??0.0;
      }
    }
    monthlyAmount = double.parse((monthlyAmount).toStringAsFixed(2));
    monthlyDistance = double.parse((monthlyDistance).toStringAsFixed(3));

    // 49 Euro-Ticket
    if(monthlyAmount >= 49){
     monthlyAmount = 49;
    }

    if(list.isEmpty){
      billingFuture = billingHelper.createBilling(month.toString(), monthlyAmount, monthlyDistance, 0);
    }else{
      for (var index in list){
        if(index.month != month.toString()){
          billingFuture = billingHelper.createBilling(month.toString(), monthlyAmount, monthlyDistance, 0);
          getBilling();
        }else{
          billing = index;
          billing.monthlyAmount = monthlyAmount;
          billing.traveledDistance = monthlyDistance;
          billingHelper.updatebilling(billing);
        }
      }
    }
    notifyListeners();
  }

  double _calculateTicketPrice() {
    double beeLine = _getDistanceBetween(
        ticket.startLatitude!,
        ticket.startLongitude!,
        ticket.endLatitude!,
        ticket.endLongitude!);
    ticket.beeLine = double.parse((beeLine).toStringAsFixed(4));
    DateTime startTime = DateTime.parse(ticket.startTime);
    DateTime endTime = DateTime.parse(ticket.endTime!);
    Duration timeDifference = endTime.difference(startTime);
    double ticketPrice = 0.0;
    double serviceCharge = 1.60;
    List<double> distances = [5, 10, 30, 50, 100];
    double kilometerPrice = 0.10;
    if (beeLine >= 0.1 && calculatedDistance >= 0.1 && timeDifference.inSeconds >= 120) {
      var distanceForPricing =
      double.parse(((beeLine + calculatedDistance) / 2).toStringAsFixed(2));
      for (int i = 0; i < distances.length; i++) {
        if (distanceForPricing <= distances[i]) {
          ticketPrice = kilometerPrice * distances[i] + serviceCharge;
          break;
        }
      }
      if (distanceForPricing > 100.0) {
        ticketPrice = 13.0;
      }
    }
    notifyListeners();
    return ticketPrice;
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
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
  }

  Future<Position> getLocation() async {
    var currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return currentPosition;
  }

  void checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (!servicestatus) {
      if (kDebugMode) {
        print("GPS Service is not enabled, turn on GPS location");
      }
      return;
    }
    permission = await Geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.denied:
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
          return;
        }
        break;
      case LocationPermission.deniedForever:
        if (kDebugMode) {
          print("Location permissions are permanently denied");
        }
        return;
      default:
        break;
    }
    haspermission = true;
    notifyListeners();
  }

  void getLocationFromStream() async {
    //late LocationSettings locationSettings;
    LocationSettings locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2,
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
      notifyListeners();
    });
  }
}
