import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_app/colors.dart';
import 'package:ticket_app/models/tracking.dart';
import '../models/locationPoint.dart';
import '../widgets/navigation_bar.dart';

class MapScreen extends StatefulWidget {
  final Tracking tracking;
  const MapScreen({Key? key, required this.tracking})
      : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var locationHelper = LocationPointDatabaseHelper();
  late List futureTicket;
  late List locationPointsList;
  late LatLng centerPoint;
  late List<LatLng> route = [];
  double zoomLevel = 13.0;

  getLocations() async {
    if(widget.tracking.activeTicket){
      int id = widget.tracking.ticket.id;
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

  void zoomIn(){
    _getZoomLevel();

    if(zoomLevel < 18.0){
      setState(() {
        ++zoomLevel;
      });

      _saveZoomLevel();

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MyNavigationBar(
        tracking: widget.tracking,
        title: 'Easy-Ticket',
        index: 1
      ),));
      print('Zoom $zoomLevel');
    }
  }

  _getZoomLevel() async{
    final prefs = await SharedPreferences.getInstance();

    final double? localZoomLevel = prefs.getDouble('zoomLevel');
    setState(() {
      zoomLevel = localZoomLevel!;
    });

  }

  _saveZoomLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('zoomLevel', zoomLevel);
  }

  initialZoom() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('zoomLevel', 13.0);
  }

  void refreshMap(){
    setState(() {
      route = route;
    });
  }

  @override
  void initState() {
    getLocations();
    //initialZoom();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        key: UniqueKey(),
          options: MapOptions(
              zoom: zoomLevel,
              maxZoom: 18,
              keepAlive: true,
              center: LatLng(widget.tracking.currentPosition.latitude, widget.tracking.currentPosition.longitude)
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
      floatingActionButton: FloatingActionButton(
        onPressed: zoomIn,
        backgroundColor: primaryColor,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

/*

 */