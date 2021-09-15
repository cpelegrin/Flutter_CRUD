import 'package:emprestimos/Models/loan.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../Models/client.dart';

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
          'client_id INTEGER PRIMARY KEY, '
          'name TEXT, '
          'birth_date TEXT,'
          'cpf TEXT NOT NULL UNIQUE,'
          'RG TEXT,'
          'tel TEXT,'
          'email Text'
          ')',
        );
      },
      version: 1,
    );

    _database!.execute(
      'CREATE TABLE IF NOT EXISTS loans('
      'loan_id INTEGER PRIMARY KEY, '
      'date_of_loan TEXT,'
      'currency_symbol TEXT,'
      'currency_name TEXT,'
      'value TEXT,'
      'maturity TEXT,'
      'tax TEXT,'
      'client_id INTEGER NOT NULL,'
      'FOREIGN KEY(client_id) REFERENCES clients(client_id) '
      'ON DELETE CASCADE'
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
        maps[i]['tel'],
        maps[i]['email'],
        id: maps[i]['client_id'],
      );
    });
  }

  selectClientById(id) async {
    await _createTables();
    final List<Map<String, dynamic>> maps =
        await _database!.query('clients', where: "client_id == $id");

    return List.generate(maps.length, (i) {
      return Client(
        maps[i]['name'],
        maps[i]['birth_date'],
        maps[i]['cpf'],
        maps[i]['RG'],
        maps[i]['tel'],
        maps[i]['email'],
        id: maps[i]['client_id'],
      );
    });
    // return null;
  }

  insertLoan(loan) async {
    await _createTables();
    await _database!.insert(
      'loans',
      loan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Loan>> listLoansJoin() async {
    await _createTables();
    final List<Map<String, dynamic>> maps = await _database!.rawQuery(
        'SELECT *, name FROM loans INNER JOIN clients USING(client_id)');

    return List.generate(maps.length, (i) {
      return Loan(
        maps[i]['currency_symbol'],
        maps[i]['currency_name'],
        maps[i]['value'],
        maps[i]['maturity'],
        maps[i]['tax'],
        date_of_loan: maps[i]['date_of_loan'],
        client_id: maps[i]['client_id'],
        loan_id: maps[i]['loan_id'],
        clientName: maps[i]['name'],
      );
    });
  }

  updateClient(client) async {
    await _createTables();
    await _database!.update(
      'clients',
      client.toMap(),
      where: 'client_id = ?',
      whereArgs: [client.id],
    );
  }

  deleteClient(client_id) async {
    await _createTables();
    return await _database!.delete(
      'clients',
      where: 'client_id = ?',
      whereArgs: [client_id],
    );
  }

  updateLoan(Loan loan) async {
    await _createTables();
    await _database!.update(
      'loans',
      loan.toMap(),
      where: 'loan_id = ?',
      whereArgs: [loan.loan_id],
    );
  }

  deleteLoan(loan_id) async {
    await _createTables();
    return await _database!.delete(
      'loans',
      where: 'loan_id = ?',
      whereArgs: [loan_id],
    );
  }
}
