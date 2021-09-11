import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'Models/client.dart';

class SQLiteHelper {
  ///Definição do Singleton
  SQLiteHelper._privateConstructor();
  static final SQLiteHelper _instance = SQLiteHelper._privateConstructor();
  static SQLiteHelper get instance => _instance;

  Database? _database;

  _createTables() async {
    WidgetsFlutterBinding.ensureInitialized();
    _database = await openDatabase(
      join(await getDatabasesPath(), 'loan_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS clients('
          'id INTEGER PRIMARY KEY, '
          'name TEXT, '
          'birth_date TEXT,'
          'cpf TEXT NOT NULL UNIQUE,'
          'RG TEXT,'
          'tel1 TEXT,'
          'email Text'
          ')',
        );
      },
      version: 1,
    );

    _database!.execute(
      'CREATE TABLE IF NOT EXISTS loans('
      'date TEXT,'
      'currency_symbol TEXT,'
      'value TEXT,'
      'maturity TEXT'
      ')',
    );
  }

  insertClient(Client client) async {
    await _createTables();
    await _database!.insert(
      'clients',
      client.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Client>> listClients() async {
    await _createTables();
    final List<Map<String, dynamic>> maps = await _database!.query('clients');

    return List.generate(maps.length, (i) {
      return Client(
        maps[i]['name'],
        maps[i]['birth_date'],
        maps[i]['cpf'],
        maps[i]['RG'],
        maps[i]['tel1'],
        maps[i]['email'],
        id: maps[i]['id'],
      );
    });
  }
}
