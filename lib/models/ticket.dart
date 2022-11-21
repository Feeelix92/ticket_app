import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import 'databaseLocalManager.dart';
import 'dart:async';

class Ticket {
  final int id;
  final String startTime;
  final String endTime;
  final String startStation;
  final String endStation;

  const Ticket({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.startStation,
    required this.endStation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'startStation': startStation,
      'endStation': endStation,
    };
  }

  @override
  String toString() {
    return 'Ticket{id: $id, startTime: $startTime, endTime: $endTime, startStation: $startStation, endStation: $endStation}';
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
        'CREATE TABLE ticket(id INTEGER PRIMARY KEY, startTime String, endTime String, startStation String, endStation String)',
      );
    },
// Set the version. This executes the onCreate function and provides a
// path to perform database upgrades and downgrades.
    version: 1,
  );

  Future<void> insertTicket(Ticket ticket) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'ticket',
      ticket.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Ticket>> tickets() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('ticket');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Ticket(
        id: maps[i]['id'],
        startTime: maps[i]['startTime'],
        endTime: maps[i]['endTime'],
        startStation: maps[i]['startStation'],
        endStation: maps[i]['endStation'],
      );
    });
  }

  Future<void> deleteticket(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'ticket',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}
