import 'dart:convert';
import 'package:http/http.dart' as http;

Future<DepartureInfo> fetchRMVData() async {
  final response = await http
      .get(Uri.parse('https://www.rmv.de/hapi/departureBoard?accessId=865260df-a981-49c0-9207-d11d847bfc2e&id=A=1@O=Friedberg%20(Hessen)%20Bahnhof@&date=2022-11-28&time=12:30&format=json'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DepartureInfo.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load...');
  }
}

class DepartureInfo {
  final String serverVersion;
  final String dialectVersion;
  final String planRtTs;
  final String requestId;

  const DepartureInfo({
    required this.serverVersion,
    required this.dialectVersion,
    required this.planRtTs,
    required this.requestId,
  });

  factory DepartureInfo.fromJson(Map<String, dynamic> json) {
    print('DATA:       ');
    print(json['serverVersion']);
    return DepartureInfo(
      serverVersion: json['serverVersion'],
      dialectVersion: json['dialectVersion'],
      planRtTs: json['planRtTs'],
      requestId: json['requestId'],
    );
  }
}
