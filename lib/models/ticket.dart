import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// import 'databaseLocalManager.dart';
import 'dart:async';

class Ticket {
  final int id;
  final String startTime;
  String? endTime;
  String? startStation;
  String? endStation;

  Ticket({
    required this.id,
    required this.startTime,
    this.endTime,
    this.startStation,
    this.endStation,
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

class TicketDatabaseHelper {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'location_database2.db'),
      version: 1,
    );
  }

  Future<Ticket> createTicket(String time) async {
    final db = await initializeDB();

    final data = {'startTime': time};
    final id = await db.insert('ticket', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return Ticket(id: id, startTime: time);
  }

  Future<void> insertTicket(Ticket ticket) async {
    // Get a reference to the database.
    final db = await initializeDB();

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
    final db = await initializeDB();

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
    final db = await initializeDB();

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
