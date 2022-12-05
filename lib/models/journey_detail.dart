import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<JourneyDetails> fetchJourneyDetails(String journeyDetailRef) async {
  // Building the URL
  const String apiURL = 'https://www.rmv.de/hapi/';
  String accessId = dotenv.get('RMVAPIKEY');
  const String requestType = 'journeyDetail';
  const String formatKey = 'json';
  journeyDetailRef = Uri.encodeComponent(journeyDetailRef);
  // API Response
  final response = await http.get(Uri.parse(
      '$apiURL$requestType?accessId=$accessId&id=$journeyDetailRef&format=$formatKey'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return JourneyDetails.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Journey Details.');
  }
}

class JourneyDetails {
  Stops? stops;
  Names? names;
  List<Product>? product;
  Directions? directions;
  Notes? notes;
  Messages? messages;
  String? journeyStatus;
  List<ServiceDays>? serviceDays;
  TechnicalMessages? technicalMessages;
  String? serverVersion;
  String? dialectVersion;
  String? planRtTs;
  String? requestId;
  String? ref;
  bool? reachable;
  String? dayOfOperation;

  JourneyDetails(
      {this.stops,
        this.names,
        this.product,
        this.directions,
        this.notes,
        this.messages,
        this.journeyStatus,
        this.serviceDays,
        this.technicalMessages,
        this.serverVersion,
        this.dialectVersion,
        this.planRtTs,
        this.requestId,
        this.ref,
        this.reachable,
        this.dayOfOperation});

  JourneyDetails.fromJson(Map<String, dynamic> json) {
    stops = json['Stops'] != null ? Stops.fromJson(json['Stops']) : null;
    names = json['Names'] != null ? Names.fromJson(json['Names']) : null;
    if (json['Product'] != null) {
      product = <Product>[];
      json['Product'].forEach((v) {
        product!.add(Product.fromJson(v));
      });
    }
    directions = json['Directions'] != null
        ? Directions.fromJson(json['Directions'])
        : null;
    notes = json['Notes'] != null ? Notes.fromJson(json['Notes']) : null;
    messages = json['Messages'] != null
        ? Messages.fromJson(json['Messages'])
        : null;
    journeyStatus = json['JourneyStatus'];
    if (json['ServiceDays'] != null) {
      serviceDays = <ServiceDays>[];
      json['ServiceDays'].forEach((v) {
        serviceDays!.add(ServiceDays.fromJson(v));
      });
    }
    technicalMessages = json['TechnicalMessages'] != null
        ? TechnicalMessages.fromJson(json['TechnicalMessages'])
        : null;
    serverVersion = json['serverVersion'];
    dialectVersion = json['dialectVersion'];
    planRtTs = json['planRtTs'];
    requestId = json['requestId'];
    ref = json['ref'];
    reachable = json['reachable'];
    dayOfOperation = json['dayOfOperation'];
  }
}

class Stops {
  List<Stop>? stop;

  Stops({this.stop});

  Stops.fromJson(Map<String, dynamic> json) {
    if (json['Stop'] != null) {
      stop = <Stop>[];
      json['Stop'].forEach((v) {
        stop!.add(Stop.fromJson(v));
      });
    }
  }
}

class Stop {
  Notes? notes;
  List<String>? altId;
  String? name;
  String? id;
  String? extId;
  int? routeIdx;
  double? lon;
  double? lat;
  String? depPrognosisType;
  String? depTime;
  String? depDate;
  String? depTrack;
  String? depDir;
  String? arrTime;
  String? arrDate;
  String? arrPrognosisType;
  String? arrTrack;

  Stop(
      {this.notes,
        this.altId,
        this.name,
        this.id,
        this.extId,
        this.routeIdx,
        this.lon,
        this.lat,
        this.depPrognosisType,
        this.depTime,
        this.depDate,
        this.depTrack,
        this.depDir,
        this.arrTime,
        this.arrDate,
        this.arrPrognosisType,
        this.arrTrack});

  Stop.fromJson(Map<String, dynamic> json) {
    notes = json['Notes'] != null ? Notes.fromJson(json['Notes']) : null;
    altId = json['altId'].cast<String>();
    name = json['name'];
    id = json['id'];
    extId = json['extId'];
    routeIdx = json['routeIdx'];
    lon = json['lon'];
    lat = json['lat'];
    depPrognosisType = json['depPrognosisType'];
    depTime = json['depTime'];
    depDate = json['depDate'];
    depTrack = json['depTrack'];
    depDir = json['depDir'];
    arrTime = json['arrTime'];
    arrDate = json['arrDate'];
    arrPrognosisType = json['arrPrognosisType'];
    arrTrack = json['arrTrack'];
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
  String? txtN;

  Note({this.value, this.key, this.type, this.txtN});

  Note.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    key = json['key'];
    type = json['type'];
    txtN = json['txtN'];
  }
}

class Names {
  List<Name>? name;

  Names({this.name});

  Names.fromJson(Map<String, dynamic> json) {
    if (json['Name'] != null) {
      name = <Name>[];
      json['Name'].forEach((v) {
        name!.add(Name.fromJson(v));
      });
    }
  }
}

class Name {
  Product? product;
  String? name;
  String? number;
  String? category;
  int? routeIdxFrom;
  int? routeIdxTo;

  Name(
      {this.product,
        this.name,
        this.number,
        this.category,
        this.routeIdxFrom,
        this.routeIdxTo});

  Name.fromJson(Map<String, dynamic> json) {
    product =
    json['Product'] != null ? Product.fromJson(json['Product']) : null;
    name = json['name'];
    number = json['number'];
    category = json['category'];
    routeIdxFrom = json['routeIdxFrom'];
    routeIdxTo = json['routeIdxTo'];
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
        this.matchId});

  Product.fromJson(Map<String, dynamic> json) {
    icon = json['icon'] != null ? new Icon.fromJson(json['icon']) : null;
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

class Directions {
  List<Direction>? direction;

  Directions({this.direction});

  Directions.fromJson(Map<String, dynamic> json) {
    if (json['Direction'] != null) {
      direction = <Direction>[];
      json['Direction'].forEach((v) {
        direction!.add(Direction.fromJson(v));
      });
    }
  }
}

class Direction {
  String? value;
  String? flag;
  int? routeIdxFrom;
  int? routeIdxTo;

  Direction({this.value, this.flag, this.routeIdxFrom, this.routeIdxTo});

  Direction.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    flag = json['flag'];
    routeIdxFrom = json['routeIdxFrom'];
    routeIdxTo = json['routeIdxTo'];
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
      {this.channel,
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

class Channel {
  String? name;
  List<Url>? url;
  String? validFromTime;
  String? validFromDate;
  String? validToTime;
  String? validToDate;

  Channel(
      {this.name,
        this.url,
        this.validFromTime,
        this.validFromDate,
        this.validToTime,
        this.validToDate});

  Channel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['url'] != null) {
      url = <Url>[];
      json['url'].forEach((v) {
        url!.add(new Url.fromJson(v));
      });
    }
    validFromTime = json['validFromTime'];
    validFromDate = json['validFromDate'];
    validToTime = json['validToTime'];
    validToDate = json['validToDate'];
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

class ServiceDays {
  String? planningPeriodBegin;
  String? planningPeriodEnd;
  String? sDaysR;
  String? sDaysI;
  String? sDaysB;
  int? routeIdxFrom;
  int? routeIdxTo;

  ServiceDays(
      {this.planningPeriodBegin,
        this.planningPeriodEnd,
        this.sDaysR,
        this.sDaysI,
        this.sDaysB,
        this.routeIdxFrom,
        this.routeIdxTo});

  ServiceDays.fromJson(Map<String, dynamic> json) {
    planningPeriodBegin = json['planningPeriodBegin'];
    planningPeriodEnd = json['planningPeriodEnd'];
    sDaysR = json['sDaysR'];
    sDaysI = json['sDaysI'];
    sDaysB = json['sDaysB'];
    routeIdxFrom = json['routeIdxFrom'];
    routeIdxTo = json['routeIdxTo'];
  }
}

class TechnicalMessages {
  List<TechnicalMessage>? technicalMessage;

  TechnicalMessages({this.technicalMessage});

  TechnicalMessages.fromJson(Map<String, dynamic> json) {
    if (json['TechnicalMessage'] != null) {
      technicalMessage = <TechnicalMessage>[];
      json['TechnicalMessage'].forEach((v) {
        technicalMessage!.add(new TechnicalMessage.fromJson(v));
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
