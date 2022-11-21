import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CsvReader{
  List<List<dynamic>> data = [];
  loadAsset() async {
    final myData = await rootBundle.loadString("assets/RMV_Haltestellen.csv");
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(myData);
    data = csvTable;
    print(data[2]);
  }

}


