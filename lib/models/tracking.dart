import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ticket_app/models/ticket.dart';
import 'locationPoint.dart';

class Tracking {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late List<LocationPoint> _ride;
  var latitude = 0.0;
  var longitude = 0.0;
  var altitude = 0.0;
  var speed = 0.0;
  var address = "";
  late Position currentPosition;
  late StreamSubscription<Position> positionStream;
  // Ticket
  var ticketHelper = TicketDatabaseHelper();
  late var ticketFuture ;
  late Ticket ticket ;
  bool ticketActive = false;

  void startTracking() {
    print("START");
  }

  void _saveLocationPoint() async {
    var id = ticket.id;
    var locationHelper = LocationPointDatabaseHelper();
    var locationPointFuture = locationHelper.createLocationPoint(
        latitude, longitude, altitude,
        speed, id, '');
  }

  void startTrip() async {
    if(!ticketActive){
      ticketActive = true;
      print("TRIP STARTED:");
      var startLocation = _getLocation();
      print(startLocation);
      ticketFuture = ticketHelper.createTicket(DateTime.now().toString());
      _getTicket();
      // Timer to periodic save the LocationPoints
      const oneSec = Duration(seconds:1);
      Timer.periodic(oneSec, (timer) {
        _saveLocationPoint();
        if(!ticketActive) {
          timer.cancel();
        }
      });
    }
  }

  void stopTrip() async {
    if(ticketActive){
      ticketActive = false;
      print("TRIP STOPED:");
      var endLocation = _getLocation();
      print(endLocation);
    }
  }


  void _getTicket() async {
    ticket = await ticketFuture;
  }

  Future<Position> _getLocation() async {
    var currentPosition =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
      if (haspermission) {

      }
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

    void getAddressFromLatLng(double latitude, double longitude) async {
      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);
        Placemark place = placemarks[0];
        address =
            "${place.street}, \n${place.postalCode} ${place.locality} \n ${place.administrativeArea}, ${place.country}";
      } catch (e) {
        print(e);
      }
    }

    Future<void> saveLocations() async {
      var counter = 0;
      const oneSec = Duration(seconds: 10);
      Timer.periodic(oneSec, (Timer t) => counter = counter + 1);
      print(counter);
      print('${currentPosition.latitude} ${currentPosition.longitude}');
      print('Stream paused: ${positionStream.isPaused}');
      getAddressFromLatLng(currentPosition.latitude, currentPosition.longitude);
    }
  }
}
