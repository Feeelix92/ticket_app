import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:workmanager/workmanager.dart';
import 'colors.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sqflite/sqflite.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Native called background task:"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager().registerOneOffTask("_MyHomePageState", "_test");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy-Ticket',
      theme: ThemeData(
        primarySwatch: generateMaterialColor(color: primaryColor),
      ),
      home: const MyHomePage(title: 'Easy-Ticket'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class QRCode extends StatefulWidget {
  const QRCode({Key? key, required this.lat, required this.long, required this.address}) : super(key: key);

  final String lat;
  final String long;
  final String address;

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  @override
  Widget build(BuildContext context) {
    return QrImage(
        data: 'Eingestiegen in ${widget.lat}, ${widget.long}. Ort: ${widget.address}',
        gapless: true,
        version: QrVersions.auto,
        size: 300,
        foregroundColor: accentColor1,
        //embeddedImage: const AssetImage('assets/images/thm.png'),
        //embeddedImageStyle: QrEmbeddedImageStyle(
          //size: const Size(80,80),
        //),
        errorStateBuilder: (cxt, err) {
          return const Center(
            child: Text(
              "Etwas läuft schief...",
              textAlign: TextAlign.center,
            ),
          );
        });
  }
}



class _MyHomePageState extends State<MyHomePage> {
  // GPS
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  var _latitude = "";
  var _longitude = "";
  var _altitude = "";
  var _speed = "";
  var _address = "";
  late Position _currentPosition;
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best, //accuracy of the location data
    distanceFilter: 2, //minimum distance (measured in meters) a
    //device must move horizontally before an update event is generated;
  );
  late StreamSubscription<Position> _positionStream;
  var _counter = 0;

  Future<void> _test() async {
    const oneSec = Duration(seconds: 10);
    Timer.periodic(
        oneSec,
        (Timer t) => setState(() {
              _counter = _counter + 1;
              print(_counter);
              print(_positionStream.isPaused);
              print(_currentPosition);
              // print(_address);
            }));
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _address =
            "${place.street}, \n${place.postalCode} ${place.locality} \n ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  _checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }
      if (haspermission) {
        setState(() {
          //refresh the UI
        });
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  @override
  void initState() {
    _checkGps();
    super.initState();
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _altitude = position.altitude.toString();
        _speed = position.speed.toString();
      });
    });
    _test();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Text('Max Mustermann',
                    style: TextStyle(
                      color: accentColor1,
                    )
                  ),
                  Text('Ticket-ID: 123456789',
                      style: TextStyle(
                        color: accentColor1,
                      )
                  ),
                  Text('Datum: 14.11.2022',
                      style: TextStyle(
                        color: accentColor1,
                      )
                  ),
                  Text('Uhrzeit: 10:00 Uhr',
                      style: TextStyle(
                        color: accentColor1,
                      )
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  const Text(
                    'QR-Code',
                    style: TextStyle(
                        fontSize: 30
                    ),
                  ),
                  Visibility(
                    visible: _longitude != "",
                    child: QRCode(lat: _latitude, long: _longitude, address: _address),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(50),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  ElevatedButton(
                    onPressed: null,
                    child: Text('FAHRT STARTEN'),
                  ),
                  ElevatedButton(
                    onPressed: null,
                    child: Text('FAHRT BEENDEN'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                ],
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
              Text('Adresse: $_address'),
              Text('Counter: $_counter')
              // const Text('Address: '),
              //   Text(_address),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.airplane_ticket),
            label: 'Ticket',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: 'Karte',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: 'Historie',
            backgroundColor: primaryColor,
          ),
        ],
        currentIndex: 0,
        selectedItemColor: secondaryColor,
        onTap: null,
      ),
    );
  }
}
