import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locationPoint.dart';

class Tracking {
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

  void startTracking() {
    print("START");
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

    void saveCurrentPosition(Position currentPosition) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', currentPosition.latitude);
      await prefs.setDouble('longitude', currentPosition.longitude);
      await prefs.setDouble('altitude', currentPosition.altitude);
      await prefs.setDouble('speed', currentPosition.speed);
    }

    Future<void> saveLocations() async {
      var counter = 0;
      const oneSec = Duration(seconds: 10);
      Timer.periodic(oneSec, (Timer t) => counter = counter + 1);
      print(counter);
      print('${currentPosition.latitude} ${currentPosition.longitude}');
      print('Stream paused: ${positionStream.isPaused}');
      getAddressFromLatLng(currentPosition.latitude, currentPosition.longitude);
      saveCurrentPosition(currentPosition);
    }
  }
}
