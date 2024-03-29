import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ticket_app/models/tracking.dart';
import '../colors.dart';
import '../models/locationPoint.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var locationHelper = LocationPointDatabaseHelper();
  late List futureTicket;
  late List locationPointsList;
  late LatLng centerPoint;
  late List<LatLng> route = [];

  _getLocations(bool activeTicket, int id) async {
    if(activeTicket){
     futureTicket = await locationHelper.locationsFromTicketid(id.toInt());
      for (var locationPoint in futureTicket) {
        centerPoint = LatLng(locationPoint.latitude, locationPoint.longitude);
        route.add(LatLng(locationPoint.latitude, locationPoint.longitude));
      }
      setState(() {
        route = route;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Tracking trackingService = Provider.of<Tracking>(context);
    if( trackingService.ticketInitialized){
      _getLocations(trackingService.activeTicket, trackingService.ticket.id);
    }
    return Center(
      child: trackingService.positionInitialized
          ? FlutterMap(
              options: MapOptions(
                  zoom: 13,
                  maxZoom: 18,
                  keepAlive: true,
                  center: LatLng(trackingService.currentPosition.latitude,
                      trackingService.currentPosition.longitude)),
              nonRotatedChildren: [
                  AttributionWidget.defaultWidget(
                    source: 'OpenStreetMap contributors',
                    onSourceTapped: null,
                  ),
                ],
              children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                ])
          : Center(
              child: CircularProgressIndicator(
              color: secondaryColor,
            )),
    );
  }
}
