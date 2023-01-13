import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ticket_app/models/ticket.dart';
import '../models/locationPoint.dart';

class TicketMapScreen extends StatefulWidget {
  const TicketMapScreen({required this.ticket,Key? key}) : super(key: key);

  final Ticket ticket;

  @override
  State<TicketMapScreen> createState() => _TicketMapScreenState();
}

class _TicketMapScreenState extends State<TicketMapScreen> {
  var locationHelper = LocationPointDatabaseHelper();
  late List futureTicket;
  late List locationPointsList;
  late LatLng centerPoint;
  late List<LatLng> route = [];
  late LatLng centerMap;

  _getLocations() async {
    int id = widget.ticket.id;
    futureTicket = await locationHelper.locationsFromTicketid(id.toInt());
    for (var locationPoint in futureTicket) {
      print('test $locationPoint');

      centerPoint = LatLng(locationPoint.latitude, locationPoint.longitude);
      //print(centerPoint);
      route.add(LatLng(locationPoint.latitude, locationPoint.longitude));
    }
    setState(() {
      centerMap = LatLng(route.last.latitude, route.last.longitude);
    });
  }

  @override
  void initState() {
    _getLocations();
    super.initState();
    if (mounted) {
      print('moin ' );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Reise'),
    ),
    body: FlutterMap(
        options: MapOptions(
            zoom: 12,
            maxZoom: 13,
            keepAlive: true,
            center: centerMap
        ),
        nonRotatedChildren: [
          AttributionWidget.defaultWidget(
            source: 'OpenStreetMap contributors',
            onSourceTapped: null,
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.easy-ticket.map',
          ),
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(
                  //points: [LatLng(50.3249, 8.7409), LatLng(50.4978, 8.6629), LatLng(50.5841, 8.6784),],
                  points: route,
                  color: Colors.blue,
                  strokeWidth: 3.0),
            ],
          ),
        ]),
    );
  }
}
