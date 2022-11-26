import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        options: MapOptions(
          zoom: 12,
          maxZoom: 13,
          keepAlive: true,
          center: LatLng(50.3249, 8.7409)
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
                points: [LatLng(50.3249, 8.7409), LatLng(50.4978, 8.6629), LatLng(50.5841, 8.6784),],
                color: Colors.blue,
                strokeWidth: 3.0
              ),
            ],
          ),
        ]);
  }
}