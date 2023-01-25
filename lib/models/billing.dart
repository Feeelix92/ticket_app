import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class Billing {
  final int id;
  String? firebaseId;
  final String month;
  final double monthlyAmount;
  final double traveledDistance;
  final bool paid;

  Billing({
    required this.id,
    this.firebaseId,
    required this.month,
    required this.monthlyAmount,
    required this.traveledDistance,
    required this.paid,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'month': month,
      'monthlyAmount': monthlyAmount,
      'traveledDistance': traveledDistance,
      'paid': paid,

    };
  }

  @override
  String toString() {
    return 'Ticket{id: $id, firebaseId: $firebaseId, month: $month, monthlyAmount: $monthlyAmount, traveledDistance: $traveledDistance, paid: $paid}';
  }
}

class BillingDatabaseHelper {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, dotenv.get('DB_PATH')),
      version: 1,
    );
  }

  Future<Billing> createBilling(String month, double monthlyAmount, double traveledDistance, bool paid) async {
    final db = await initializeDB();
    final data = {'month': month, 'monthlyAmount': monthlyAmount, 'traveledDistance': traveledDistance, 'paid': paid};
    final id = await db.insert('billing', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return Billing(id: id, month: month, monthlyAmount: monthlyAmount, traveledDistance: traveledDistance, paid: paid, );
  }

  Future<void> insertBilling(Billing ticket) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Insert the Billing into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same Billing is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'ticket',
      ticket.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Billing>> billings() async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Query the table for all The Billings.
    final List<Map<String, dynamic>> maps = await db.query('ticket');

    // Convert the List<Map<String, dynamic> into a List<Billing>.
    return List.generate(maps.length, (i) {
      return Billing(
        id: maps[i]['id'],
        firebaseId: maps[i]['firebaseId'],
        month: maps[i]['month'],
        monthlyAmount: maps[i]['monthlyAmount'],
        traveledDistance: maps[i]['traveledDistance'],
        paid: maps[i]['paid'],
      );
    });
  }

  Future<void> deletebilling(int id) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Remove the Billing from the database.
    await db.delete(
      'billing',
      // Use a `where` clause to delete a specific Billing.
      where: 'id = ?',
      // Pass the Billing's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> updatebilling(Billing billing) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Remove the Billing from the database.
    await db.update(
      'billing',
      billing.toMap(),
      where: 'id = ?',
      // Pass the Billing's id as a whereArg to prevent SQL injection.
      whereArgs: [billing.id],
    );
  }

  Future<List<Billing>> getBillingsPerMonth(String month) async{
    // Get a reference to the database.
    final db = await initializeDB();

    final List<Map<String, dynamic>> maps = await db.query(
      'billing',
      // Use a `where` clause to delete a specific Billing.
      where: 'month = ?',
      // Pass the Billing's id as a whereArg to prevent SQL injection.
      whereArgs: [month],
    );

    // Convert the List<Map<String, dynamic> into a List<Billing>.
    return List.generate(maps.length, (i) {
      return Billing(
        id: maps[i]['id'],
        firebaseId: maps[i]['firebaseId'],
        month: maps[i]['month'],
        monthlyAmount: maps[i]['monthlyAmount'],
        traveledDistance: maps[i]['traveledDistance'],
        paid: maps[i]['paid'],
      );
    });
  }
}
