import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class CsvReader{
  List<List<dynamic>> data = [];
  loadAsset() async {
    final csvTable = await rootBundle.loadString("assets/RMV_Haltestellen.csv");
    List<List<dynamic>> rmvData = const CsvToListConverter().convert(csvTable);
    print(rmvData[2]);
  }

}


