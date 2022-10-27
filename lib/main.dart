import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Ticket',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Easy Ticket'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Colors
  final Color _backgroundColor = Colors.white;
  // GPS
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position _currentPosition;
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best, //accuracy of the location data
    distanceFilter: 0, //minimum distance (measured in meters) a
    //device must move horizontally before an update event is generated;
  );
  late StreamSubscription<Position> positionStream;
  var _latitude = "";
  var _longitude = "";
  var _altitude = "";
  var _speed = "";
  var _address = "";
  // accelerometer
  final Map _userAccerlerometer = {'x': 0, 'y': 0, 'z': 0};
  late final Map _tempUserAcc = {'x': 0, 'y': 0, 'z': 0};
  // gyroscopes
  final Map _gyroscope = {'x': 0, 'y': 0, 'z': 0};
  late final  Map _tempGyro = {'x': 0, 'y': 0, 'z': 0};
  final Map _direction = {'x': 'none', 'y': 'none', 'z': 'none'};
  // magnetometer
  final Map _magnetometer = {'x': 0, 'y': 0, 'z': 0};
  late final Map _tempMag = {'x': 0, 'y': 0, 'z': 0};
  late String _now;
  late Timer _everySecond;
  // decimal places
  final int decimalPlaces = 2;

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus){
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        }else if(permission == LocationPermission.deniedForever){
          print("'Location permissions are permanently denied");
        }else{
          haspermission = true;
        }
      }else{
        haspermission = true;
      }
      if(haspermission){
        setState(() {
          //refresh the UI
        });
      }
    }else{
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });

  }
  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude,
          _currentPosition.longitude
      );
      Placemark place = placemarks[0];
      setState(() {
        _address = "${place.street}, \n${place.postalCode} ${place.locality} \n ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    checkGps();
    super.initState();

    Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _altitude = position.altitude.toString();
        _speed = position.speed.toString();
      });
    });
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccerlerometer['x'] = event.x;
        _userAccerlerometer['y'] = event.y;
        _userAccerlerometer['z'] = event.z;
      });
    });
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscope['x'] = event.x;
        _gyroscope['y'] = event.y;
        _gyroscope['z'] = event.z;
      });
    });
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometer['x'] = event.x;
        _magnetometer['y'] = event.y;
        _magnetometer['z'] = event.z;
      });
    });
    // sets first value
    _now = DateTime.now().second.toString();
    // defines a timer
    _everySecond = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      print('Test 1 second');
      setState(() {
        _now = DateTime.now().second.toString();
        _tempUserAcc['x'] = _userAccerlerometer['x'].toStringAsFixed(decimalPlaces);
        _tempUserAcc['y'] = _userAccerlerometer['y'].toStringAsFixed(decimalPlaces);
        _tempUserAcc['z'] = _userAccerlerometer['z'].toStringAsFixed(decimalPlaces);
        _tempGyro['x'] = _gyroscope['x'].toStringAsFixed(decimalPlaces);
        _tempGyro['y'] = _gyroscope['y'].toStringAsFixed(decimalPlaces);
        _tempGyro['z'] = _gyroscope['z'].toStringAsFixed(decimalPlaces);
        _tempMag['x'] = _magnetometer['x'].toStringAsFixed(decimalPlaces);
        _tempMag['y'] = _magnetometer['y'].toStringAsFixed(decimalPlaces);
        _tempMag['z'] = _magnetometer['z'].toStringAsFixed(decimalPlaces);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                      'GPS: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    )
                  ),
              ),
              Text(servicestatus? "Status: active": "Status: disabled.",
                  style: const TextStyle(fontSize: 20)
              ),
              Text(haspermission? "Permissions accepted": "Permissions denied.",
                  style: const TextStyle(fontSize: 20)
              ),
              Text(
                'Latitude: $_latitude',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'Longitude: $_longitude',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'Altitude: $_altitude',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'Speed: $_speed',
                style: Theme.of(context).textTheme.headline6,
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                    'UserAccelerometer: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                    )
                ),
              ),
              Text(
                'x: ${_tempUserAcc['x']}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'y: ${_tempUserAcc['y']}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'z: ${_tempUserAcc['z']}',
                style: Theme.of(context).textTheme.headline6,
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                    'Gyroscope: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.purple,
                    )
                ),
              ),
              Text(
                'x: ${_tempGyro['x']}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'y: ${_tempGyro['y']}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'z: ${_tempGyro['z']}',
                style: Theme.of(context).textTheme.headline6,
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                    'Magnetometer: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    )
                ),
              ),
              Text(
                'x: ${_tempMag['x']}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'y: ${_tempMag['y']}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'z: ${_tempMag['z']}',
                style: Theme.of(context).textTheme.headline6,
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                    'Address: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                    )
                ),
              ),
              Text(_address),
            ],
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _updatePosition,
      //   tooltip: 'GET GPS position',
      //   child: const Icon(Icons.change_circle_outlined),
      // ),
    );
  }
}