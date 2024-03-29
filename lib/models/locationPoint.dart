import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// import 'databaseLocalManager.dart';
import 'dart:async';

class LocationPoint {
  final int id;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final int ticketid;
  final String time;
  final String address;

  const LocationPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.ticketid,
    required this.time,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'ticketid': ticketid,
      'time': time,
      'address': address,
    };
  }

  @override
  String toString() {
    return 'LocationPoint{id: $id, latitude: $latitude, longitude: $longitude, altitude: $altitude, speed: $speed, ticketid: $ticketid, time: $time, address: $address,}';
  }
}

class LocationPointDatabaseHelper {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, dotenv.get('DB_PATH')),
      version: 1,
    );
  }

  Future<LocationPoint> createLocationPoint(double latitude, double longitude,
      double altitude, double speed, int ticketid, String time, String address) async {
    final db = await initializeDB();

    final data = {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'ticketid': ticketid,
      'time': time,
      'address': address
    };
    final id = await db.insert('location', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return LocationPoint(
        id: id,
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        speed: speed,
        ticketid: ticketid,
        time: time,
        address: address);
  }

  Future<void> insertLocation(LocationPoint locationPoint) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'location',
      locationPoint.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //should insert all Locations into the database
  Future<void> insertLocations(List<LocationPoint> locationPoints) async {
    final db = await initializeDB();

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    for (LocationPoint locationPoint in locationPoints) {
      await db.insert(
        'location',
        locationPoint.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<LocationPoint>> locations() async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('location');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return LocationPoint(
        id: maps[i]['id'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        altitude: maps[i]['altitude'],
        speed: maps[i]['speed'],
        ticketid: maps[i]['ticketid'],
        time: maps[i]['time'],
        address: maps[i]['address'],
      );
    });
  }

  //returns all Locations to a specific ticket
  Future<List<LocationPoint>> locationsFromTicketid(int ticketid) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query(
      'location',
      where: 'ticketid = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [ticketid],
    );

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return LocationPoint(
        id: maps[i]['id'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        altitude: maps[i]['altitude'],
        speed: maps[i]['speed'],
        ticketid: maps[i]['ticketid'].toInt(),
        time: maps[i]['time'],
        address: maps[i]['address'],
      );
    });
  }

  Future<void> deletelocation(int id) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Remove the Dog from the database.
    await db.delete(
      'location',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}
