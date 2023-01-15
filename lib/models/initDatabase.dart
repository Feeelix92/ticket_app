import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  startLatitude DOUBLE,
  startLongitude DOUBLE,
  endStation String,
  endLatitude DOUBLE,
  endLongitude DOUBLE,
  distanceBetween DOUBLE,
  ticketPrice DOUBLE
  );""";

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    deleteDatabase('location_database.db');
    deleteDatabase(path);
    return openDatabase(
      join(path, dotenv.get('DB_PATH')),
      onCreate: (database, version) async {
        await database.execute(tableLocation);
        await database.execute(tableTicket);
      },
      version: 2,
    );
  }
  Future<void> deleteDatabase(String path) =>
      databaseFactory.deleteDatabase(path);
}
