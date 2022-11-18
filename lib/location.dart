import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'databaseLocalManager.dart';
import 'dart:async';

class Location {
  final int id;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double ticketid;
  final String address;

  const Location({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.ticketid,
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
      'address': address,
    };
  }

  @override
  String toString() {
    return 'Dog{id: $id, latitude: $latitude, longitude: $longitude, altitude: $altitude, speed: $speed, ticketid: $ticketid, address: $address,}';
  }
}

void main() async {
  //WidgetsFlutterBinding.ensureInitialized(); Already in main
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'location_database.db'),

    onCreate: (db, version) {
// Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE location(id INTEGER PRIMARY KEY, latitude DOUBLE, longitude DOUBLE, altitude DOUBLE, speed DOUBLE, ticketid DOUBLE, address STRING)',
      );
    },
// Set the version. This executes the onCreate function and provides a
// path to perform database upgrades and downgrades.
    version: 1,
  );


  Future<void> insertLocation(Location location) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'location',
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Location>> locations() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('location');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Location(
        id: maps[i]['id'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        altitude: maps[i]['altitude'],
        speed: maps[i]['speed'],
        ticketid: maps[i]['ticketid'],
        address: maps[i]['address'],
      );
    });
  }

  Future<void> deletelocation(int id) async {
    // Get a reference to the database.
    final db = await database;

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
