import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<NearbyStops> fetchNearbyStops(String fromLat, String fromLong) async {
  // Building the URL
  const String apiURL = 'https://www.rmv.de/hapi/';
  String accessId = dotenv.get('RMVAPIKEY');
  const String requestType = 'location.nearbystops';
  const String formatKey = 'json';
  // API Response
  final response = await http.get(Uri.parse(
      '$apiURL$requestType?accessId=$accessId&originCoordLat=$fromLat&originCoordLong=$fromLong&format=$formatKey'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return NearbyStops.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load NearByStops.');
  }
}

class NearbyStops {
  List<StopLocationOrCoordLocation>? stopLocationOrCoordLocation;
  TechnicalMessages? technicalMessages;
  String? serverVersion;
  String? dialectVersion;
  String? requestId;

  NearbyStops(
      {this.stopLocationOrCoordLocation,
        this.technicalMessages,
        this.serverVersion,
        this.dialectVersion,
        this.requestId});

  NearbyStops.fromJson(Map<String, dynamic> json) {
    if (json['stopLocationOrCoordLocation'] != null) {
      stopLocationOrCoordLocation = <StopLocationOrCoordLocation>[];
      json['stopLocationOrCoordLocation'].forEach((v) {
        stopLocationOrCoordLocation!
            .add(StopLocationOrCoordLocation.fromJson(v));
      });
    }
    technicalMessages = json['TechnicalMessages'] != null
        ? TechnicalMessages.fromJson(json['TechnicalMessages'])
        : null;
    serverVersion = json['serverVersion'];
    dialectVersion = json['dialectVersion'];
    requestId = json['requestId'];
  }
}

class StopLocationOrCoordLocation {
  StopLocation? stopLocation;

  StopLocationOrCoordLocation({this.stopLocation});

  StopLocationOrCoordLocation.fromJson(Map<String, dynamic> json) {
    stopLocation = json['StopLocation'] != null
        ? StopLocation.fromJson(json['StopLocation'])
        : null;
  }
}

class StopLocation {
  LocationNotes? locationNotes;
  List<String>? altId;
  int? timezoneOffset;
  String? id;
  String? extId;
  String? name;
  double? lon;
  double? lat;
  int? weight;
  int? dist;
  int? products;

  StopLocation(
      {this.locationNotes,
        this.altId,
        this.timezoneOffset,
        this.id,
        this.extId,
        this.name,
        this.lon,
        this.lat,
        this.weight,
        this.dist,
        this.products});

  StopLocation.fromJson(Map<String, dynamic> json) {
    locationNotes = json['LocationNotes'] != null
        ? LocationNotes.fromJson(json['LocationNotes'])
        : null;
    altId = json['altId'].cast<String>();
    timezoneOffset = json['timezoneOffset'];
    id = json['id'];
    extId = json['extId'];
    name = json['name'];
    lon = json['lon'];
    lat = json['lat'];
    weight = json['weight'];
    dist = json['dist'];
    products = json['products'];
  }
}

class LocationNotes {
  List<LocationNote>? locationNote;

  LocationNotes({this.locationNote});

  LocationNotes.fromJson(Map<String, dynamic> json) {
    if (json['LocationNote'] != null) {
      locationNote = <LocationNote>[];
      json['LocationNote'].forEach((v) {
        locationNote!.add(LocationNote.fromJson(v));
      });
    }
  }
}

class LocationNote {
  String? value;
  String? key;
  String? type;
  String? txtN;

  LocationNote({this.value, this.key, this.type, this.txtN});

  LocationNote.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    key = json['key'];
    type = json['type'];
    txtN = json['txtN'];
  }
}

class TechnicalMessages {
  List<TechnicalMessage>? technicalMessage;

  TechnicalMessages({this.technicalMessage});

  TechnicalMessages.fromJson(Map<String, dynamic> json) {
    if (json['TechnicalMessage'] != null) {
      technicalMessage = <TechnicalMessage>[];
      json['TechnicalMessage'].forEach((v) {
        technicalMessage!.add(TechnicalMessage.fromJson(v));
      });
    }
  }
}

class TechnicalMessage {
  String? value;
  String? key;

  TechnicalMessage({this.value, this.key});

  TechnicalMessage.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    key = json['key'];
  }
}
