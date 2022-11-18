import 'package:ticket_app/widgets/qr.dart';
import 'package:flutter/material.dart';
import '../colors.dart';


class TicketScreen extends StatelessWidget {
  const TicketScreen({
    Key? key,
    required String longitude,
    required String latitude,
    required String address,
    required String altitude,
    required String speed,
    required int counter,
  }) : _longitude = longitude, _latitude = latitude, _address = address, _altitude = altitude, _speed = speed, _counter = counter, super(key: key);

  final String _longitude;
  final String _latitude;
  final String _address;
  final String _altitude;
  final String _speed;
  final int _counter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  padding: EdgeInsets.all(5.0),
                ),
                Visibility(
                  visible: _longitude != "",
                  child: QRCode(lat: _latitude, long: _longitude, address: _address),
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
    );
  }
}
