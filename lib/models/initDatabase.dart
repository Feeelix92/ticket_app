import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

class initDatabase {

  static const tableLocation = """
  CREATE TABLE location(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  latitude DOUBLE,
  longitude DOUBLE,
  altitude DOUBLE,
  speed DOUBLE,
  ticketid DOUBLE,
  time String,
  address STRING
  );""";
  static const tableTicket = """
  CREATE TABLE ticket(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  firebaseId String,
  startTime String,
  endTime String,
  startStation String,
  endStation String
  );""";

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'location_database3.db'),
      onCreate: (database, version) async {
        await database.execute(tableLocation);
        await database.execute(tableTicket);
      },
      version: 2,
    );
  }

}
