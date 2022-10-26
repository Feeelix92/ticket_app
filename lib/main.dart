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
  var _latitude = "";
  var _longitude = "";
  var _altitude = "";
  var _speed = "";
  var _address = "";
  final Color _backgroundColor = Colors.white;
  // accelerometer
  final Map _userAccerlerometer = {'x': 0, 'y': 0, 'z': 0};
  late Map _tempUserAcc = {'x': 0, 'y': 0, 'z': 0};
  // gyroscope
  final Map _gyroscope = {'x': 0, 'y': 0, 'z': 0};
  late  Map _tempGyro = {'x': 0, 'y': 0, 'z': 0};
  String _direction = "none";
  // magnetometer
  final Map _magnetometer = {'x': 0, 'y': 0, 'z': 0};
  late Map _tempMag = {'x': 0, 'y': 0, 'z': 0};
  late String _now;
  late Timer _everySecond;

  Future<void> _updatePosition() async {
    Position pos = await _determinePosition();
    List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    setState(() {
      _latitude = pos.latitude.toString();
      _longitude = pos.longitude.toString();
      _altitude = pos.altitude.toString();
      _speed = pos.speed.toString();
      _address = pm[0].toString();
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled){
      return Future.error('Location service are disabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied){
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever){
      return Future.error('Location permissions are permanently denied, we cannot request püermissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
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
        //rough calculation, you can use
        //advance formula to calculate the orientation
        if(_gyroscope['x'] > 0){
          _direction = "back";
        }else if(_gyroscope['x'] < 0){
          _direction = "forward";
        }else if(_gyroscope['y'] > 0){
          _direction = "left";
        }else if(_gyroscope['y'] < 0){
          _direction = "right";
        }
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
      setState(() {
        _now = DateTime.now().second.toString();
        _updatePosition();
        _tempUserAcc = _userAccerlerometer;
        _tempGyro = _gyroscope;
        _tempMag = _magnetometer;
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
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sekunden: $_now',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blueGrey,
                    )
                ),
              ),
              const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                      'GPS: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    )
                  ),
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
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'UserAccelerometer: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                    )
                ),
              ),
              Text(
                'x: ${_tempUserAcc['x'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'y: ${_tempUserAcc['y'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'z: ${_tempUserAcc['z'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6,
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'Gyroscope: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.purple,
                    )
                ),
              ),
              Text(
                'x: ${_tempGyro['x'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'y: ${_tempGyro['y'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'z: ${_tempGyro['z'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'direction: ${_direction}',
                style: Theme.of(context).textTheme.headline6,
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'Magnetometer: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    )
                ),
              ),
              Text(
                'x: ${_tempMag['x'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'y: ${_tempMag['y'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'z: ${_tempMag['z'].toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline6,
              ),
              // const Text('Address: '),
              //   Text(_address),
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
