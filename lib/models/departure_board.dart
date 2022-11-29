import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<DepartureBoard> fetchDepartureBoard(String startPoint, String date, String time) async {
  // Building the URL
  const String apiURL = 'https://www.rmv.de/hapi/';
  String accessId = dotenv.get('RMVAPIKEY');
  const String requestType = 'departureBoard';
  const String formatKey = 'json';
  // API Response
  final response = await http.get(Uri.parse(
      '$apiURL$requestType?accessId=$accessId&id=A=1@O=$startPoint@&date=$date&time=$time&format=$formatKey'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DepartureBoard.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Departure Data.');
  }
}

class DepartureBoard {
  List<Departure>? departure;
  TechnicalMessages? technicalMessages;
  String? serverVersion;
  String? dialectVersion;
  String? planRtTs;
  String? requestId;

  DepartureBoard(
      {this.departure,
      this.technicalMessages,
      this.serverVersion,
      this.dialectVersion,
      this.planRtTs,
      this.requestId});

  DepartureBoard.fromJson(Map<String, dynamic> json) {
    if (json['Departure'] != null) {
      departure = <Departure>[];
      json['Departure'].forEach((v) {
        departure!.add(Departure.fromJson(v));
      });
    }
    technicalMessages = json['TechnicalMessages'] != null
        ? TechnicalMessages.fromJson(json['TechnicalMessages'])
        : null;
    serverVersion = json['serverVersion'];
    dialectVersion = json['dialectVersion'];
    planRtTs = json['planRtTs'];
    requestId = json['requestId'];
  }
}

class Departure {
  JourneyDetailRef? journeyDetailRef;
  String? journeyStatus;
  ProductAtStop? productAtStop;
  List<Product>? product;
  Notes? notes;
  Messages? messages;
  List<String>? altId;
  List<Occupancy>? occupancy;
  String? name;
  String? type;
  String? stop;
  String? stopid;
  String? stopExtId;
  String? time;
  String? date;
  String? track;
  bool? reachable;
  String? direction;
  String? directionFlag;
  String? prognosisType;
  String? rtTrack;
  bool? redirected;

  Departure(
      {this.journeyDetailRef,
      this.journeyStatus,
      this.productAtStop,
      this.product,
      this.notes,
      this.messages,
      this.altId,
      this.occupancy,
      this.name,
      this.type,
      this.stop,
      this.stopid,
      this.stopExtId,
      this.time,
      this.date,
      this.track,
      this.reachable,
      this.direction,
      this.directionFlag,
      this.prognosisType,
      this.rtTrack,
      this.redirected});

  Departure.fromJson(Map<String, dynamic> json) {
    journeyDetailRef = json['JourneyDetailRef'] != null
        ? JourneyDetailRef.fromJson(json['JourneyDetailRef'])
        : null;
    journeyStatus = json['JourneyStatus'];
    productAtStop = json['ProductAtStop'] != null
        ? ProductAtStop.fromJson(json['ProductAtStop'])
        : null;
    if (json['Product'] != null) {
      product = <Product>[];
      json['Product'].forEach((v) {
        product!.add(Product.fromJson(v));
      });
    }
    notes = json['Notes'] != null ? Notes.fromJson(json['Notes']) : null;
    messages =
        json['Messages'] != null ? Messages.fromJson(json['Messages']) : null;
    altId = json['altId'].cast<String>();
    if (json['Occupancy'] != null) {
      occupancy = <Occupancy>[];
      json['Occupancy'].forEach((v) {
        occupancy!.add(Occupancy.fromJson(v));
      });
    }
    name = json['name'];
    type = json['type'];
    stop = json['stop'];
    stopid = json['stopid'];
    stopExtId = json['stopExtId'];
    time = json['time'];
    date = json['date'];
    track = json['track'];
    reachable = json['reachable'];
    direction = json['direction'];
    directionFlag = json['directionFlag'];
    prognosisType = json['prognosisType'];
    rtTrack = json['rtTrack'];
    redirected = json['redirected'];
  }
}

class JourneyDetailRef {
  String? ref;

  JourneyDetailRef({this.ref});

  JourneyDetailRef.fromJson(Map<String, dynamic> json) {
    ref = json['ref'];
  }
}

class ProductAtStop {
  Icon? icon;
  String? name;
  String? internalName;
  String? displayNumber;
  String? num;
  String? line;
  String? lineId;
  String? catOut;
  String? catIn;
  String? catCode;
  String? cls;
  String? catOutS;
  String? catOutL;
  String? operatorCode;
  String? operator;
  String? admin;
  String? matchId;

  ProductAtStop(
      {this.icon,
      this.name,
      this.internalName,
      this.displayNumber,
      this.num,
      this.line,
      this.lineId,
      this.catOut,
      this.catIn,
      this.catCode,
      this.cls,
      this.catOutS,
      this.catOutL,
      this.operatorCode,
      this.operator,
      this.admin,
      this.matchId});

  ProductAtStop.fromJson(Map<String, dynamic> json) {
    icon = json['icon'] != null ? Icon.fromJson(json['icon']) : null;
    name = json['name'];
    internalName = json['internalName'];
    displayNumber = json['displayNumber'];
    num = json['num'];
    line = json['line'];
    lineId = json['lineId'];
    catOut = json['catOut'];
    catIn = json['catIn'];
    catCode = json['catCode'];
    cls = json['cls'];
    catOutS = json['catOutS'];
    catOutL = json['catOutL'];
    operatorCode = json['operatorCode'];
    operator = json['operator'];
    admin = json['admin'];
    matchId = json['matchId'];
  }
}

class Icon {
  ForegroundColor? foregroundColor;
  ForegroundColor? backgroundColor;
  String? res;

  Icon({this.foregroundColor, this.backgroundColor, this.res});

  Icon.fromJson(Map<String, dynamic> json) {
    foregroundColor = json['foregroundColor'] != null
        ? ForegroundColor.fromJson(json['foregroundColor'])
        : null;
    backgroundColor = json['backgroundColor'] != null
        ? ForegroundColor.fromJson(json['backgroundColor'])
        : null;
    res = json['res'];
  }
}

class ForegroundColor {
  int? r;
  int? g;
  int? b;
  String? hex;

  ForegroundColor({this.r, this.g, this.b, this.hex});

  ForegroundColor.fromJson(Map<String, dynamic> json) {
    r = json['r'];
    g = json['g'];
    b = json['b'];
    hex = json['hex'];
  }
}

class Product {
  Icon? icon;
  String? name;
  String? internalName;
  String? displayNumber;
  String? num;
  String? line;
  String? lineId;
  String? catOut;
  String? catIn;
  String? catCode;
  String? cls;
  String? catOutS;
  String? catOutL;
  String? operatorCode;
  String? operator;
  String? admin;
  int? routeIdxFrom;
  int? routeIdxTo;
  String? matchId;

  Product(
      {this.icon,
      this.name,
      this.internalName,
      this.displayNumber,
      this.num,
      this.line,
      this.lineId,
      this.catOut,
      this.catIn,
      this.catCode,
      this.cls,
      this.catOutS,
      this.catOutL,
      this.operatorCode,
      this.operator,
      this.admin,
      this.routeIdxFrom,
      this.routeIdxTo,
      this.matchId});

  Product.fromJson(Map<String, dynamic> json) {
    icon = json['icon'] != null ? Icon.fromJson(json['icon']) : null;
    name = json['name'];
    internalName = json['internalName'];
    displayNumber = json['displayNumber'];
    num = json['num'];
    line = json['line'];
    lineId = json['lineId'];
    catOut = json['catOut'];
    catIn = json['catIn'];
    catCode = json['catCode'];
    cls = json['cls'];
    catOutS = json['catOutS'];
    catOutL = json['catOutL'];
    operatorCode = json['operatorCode'];
    operator = json['operator'];
    admin = json['admin'];
    routeIdxFrom = json['routeIdxFrom'];
    routeIdxTo = json['routeIdxTo'];
    matchId = json['matchId'];
  }
}

class Notes {
  List<Note>? note;

  Notes({this.note});

  Notes.fromJson(Map<String, dynamic> json) {
    if (json['Note'] != null) {
      note = <Note>[];
      json['Note'].forEach((v) {
        note!.add(Note.fromJson(v));
      });
    }
  }
}

class Note {
  String? value;
  String? key;
  String? type;
  int? routeIdxFrom;
  int? routeIdxTo;
  String? txtN;
  int? priority;

  Note(
      {this.value,
      this.key,
      this.type,
      this.routeIdxFrom,
      this.routeIdxTo,
      this.txtN,
      this.priority});

  Note.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    key = json['key'];
    type = json['type'];
    routeIdxFrom = json['routeIdxFrom'];
    routeIdxTo = json['routeIdxTo'];
    txtN = json['txtN'];
    priority = json['priority'];
  }
}

class Messages {
  List<Message>? message;

  Messages({this.message});

  Messages.fromJson(Map<String, dynamic> json) {
    if (json['Message'] != null) {
      message = <Message>[];
      json['Message'].forEach((v) {
        message!.add(new Message.fromJson(v));
      });
    }
  }
}

class Message {
  AffectedStops? affectedStops;
  ValidFromStop? validFromStop;
  ValidFromStop? validToStop;
  List<Channel>? channel;
  List<MessageCategory>? messageCategory;
  String? id;
  bool? act;
  String? head;
  String? lead;
  String? text;
  String? company;
  String? category;
  int? priority;
  int? products;
  String? icon;
  int? routeIdxFrom;
  int? routeIdxTo;
  String? sTime;
  String? sDate;
  String? eTime;
  String? eDate;
  String? altStart;
  String? altEnd;
  String? modTime;
  String? modDate;
  String? dailyStartingAt;
  String? dailyDuration;
  String? baseType;

  Message(
      {this.affectedStops,
      this.validFromStop,
      this.validToStop,
      this.channel,
      this.messageCategory,
      this.id,
      this.act,
      this.head,
      this.lead,
      this.text,
      this.company,
      this.category,
      this.priority,
      this.products,
      this.icon,
      this.routeIdxFrom,
      this.routeIdxTo,
      this.sTime,
      this.sDate,
      this.eTime,
      this.eDate,
      this.altStart,
      this.altEnd,
      this.modTime,
      this.modDate,
      this.dailyStartingAt,
      this.dailyDuration,
      this.baseType});

  Message.fromJson(Map<String, dynamic> json) {
    affectedStops = json['affectedStops'] != null
        ? AffectedStops.fromJson(json['affectedStops'])
        : null;
    validFromStop = json['validFromStop'] != null
        ? ValidFromStop.fromJson(json['validFromStop'])
        : null;
    validToStop = json['validToStop'] != null
        ? ValidFromStop.fromJson(json['validToStop'])
        : null;
    if (json['channel'] != null) {
      channel = <Channel>[];
      json['channel'].forEach((v) {
        channel!.add(Channel.fromJson(v));
      });
    }
    if (json['messageCategory'] != null) {
      messageCategory = <MessageCategory>[];
      json['messageCategory'].forEach((v) {
        messageCategory!.add(MessageCategory.fromJson(v));
      });
    }
    id = json['id'];
    act = json['act'];
    head = json['head'];
    lead = json['lead'];
    text = json['text'];
    company = json['company'];
    category = json['category'];
    priority = json['priority'];
    products = json['products'];
    icon = json['icon'];
    routeIdxFrom = json['routeIdxFrom'];
    routeIdxTo = json['routeIdxTo'];
    sTime = json['sTime'];
    sDate = json['sDate'];
    eTime = json['eTime'];
    eDate = json['eDate'];
    altStart = json['altStart'];
    altEnd = json['altEnd'];
    modTime = json['modTime'];
    modDate = json['modDate'];
    dailyStartingAt = json['dailyStartingAt'];
    dailyDuration = json['dailyDuration'];
    baseType = json['baseType'];
  }
}

class AffectedStops {
  List<StopLocation>? stopLocation;

  AffectedStops({this.stopLocation});

  AffectedStops.fromJson(Map<String, dynamic> json) {
    if (json['StopLocation'] != null) {
      stopLocation = <StopLocation>[];
      json['StopLocation'].forEach((v) {
        stopLocation!.add(StopLocation.fromJson(v));
      });
    }
  }
}

class StopLocation {
  LocationNotes? locationNotes;
  List<ProductAtStops>? productAtStops;
  List<String>? altId;
  String? id;
  String? extId;
  String? name;
  double? lon;
  double? lat;
  int? products;

  StopLocation(
      {this.locationNotes,
      this.productAtStops,
      this.altId,
      this.id,
      this.extId,
      this.name,
      this.lon,
      this.lat,
      this.products});

  StopLocation.fromJson(Map<String, dynamic> json) {
    locationNotes = json['LocationNotes'] != null
        ? LocationNotes.fromJson(json['LocationNotes'])
        : null;
    if (json['productAtStop'] != null) {
      productAtStops = <ProductAtStops>[];
      json['productAtStop'].forEach((v) {
        productAtStops!.add(ProductAtStops.fromJson(v));
      });
    }
    altId = json['altId'].cast<String>();
    id = json['id'];
    extId = json['extId'];
    name = json['name'];
    lon = json['lon'];
    lat = json['lat'];
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

class ProductAtStops {
  Icon? icon;
  String? name;
  String? internalName;
  String? line;
  String? catOut;
  String? cls;
  String? catOutS;
  String? catOutL;
  String? lineId;

  ProductAtStops(
      {this.icon,
      this.name,
      this.internalName,
      this.line,
      this.catOut,
      this.cls,
      this.catOutS,
      this.catOutL,
      this.lineId});

  ProductAtStops.fromJson(Map<String, dynamic> json) {
    icon = json['icon'] != null ? Icon.fromJson(json['icon']) : null;
    name = json['name'];
    internalName = json['internalName'];
    line = json['line'];
    catOut = json['catOut'];
    cls = json['cls'];
    catOutS = json['catOutS'];
    catOutL = json['catOutL'];
    lineId = json['lineId'];
  }
}

class ValidFromStop {
  List<String>? altId;
  String? name;
  String? id;
  String? extId;
  int? routeIdx;
  double? lon;
  double? lat;

  ValidFromStop(
      {this.altId,
      this.name,
      this.id,
      this.extId,
      this.routeIdx,
      this.lon,
      this.lat});

  ValidFromStop.fromJson(Map<String, dynamic> json) {
    altId = json['altId'].cast<String>();
    name = json['name'];
    id = json['id'];
    extId = json['extId'];
    routeIdx = json['routeIdx'];
    lon = json['lon'];
    lat = json['lat'];
  }
}

class Channel {
  String? name;
  String? validFromTime;
  String? validFromDate;
  String? validToTime;
  String? validToDate;
  List<Url>? url;

  Channel(
      {this.name,
      this.validFromTime,
      this.validFromDate,
      this.validToTime,
      this.validToDate,
      this.url});

  Channel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    validFromTime = json['validFromTime'];
    validFromDate = json['validFromDate'];
    validToTime = json['validToTime'];
    validToDate = json['validToDate'];
    if (json['url'] != null) {
      url = <Url>[];
      json['url'].forEach((v) {
        url!.add(Url.fromJson(v));
      });
    }
  }
}

class Url {
  String? name;
  String? url;

  Url({this.name, this.url});

  Url.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
  }
}

class MessageCategory {
  int? id;
  String? name;

  MessageCategory({this.id, this.name});

  MessageCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class Occupancy {
  String? name;
  int? raw;

  Occupancy({this.name, this.raw});

  Occupancy.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    raw = json['raw'];
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
