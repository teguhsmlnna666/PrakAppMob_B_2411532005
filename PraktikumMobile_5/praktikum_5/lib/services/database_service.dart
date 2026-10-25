import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/app_user.dart';
import '../models/transaction_model.dart';

class DatabaseService extends ChangeNotifier {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    String path;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      path = 'expense_tracker_web.db';
    } else {
      final databasePath = await getDatabasesPath();
      path = join(databasePath, 'expense_tracker.db');
    }

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL,
            category TEXT NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');
      },
    );

    return _database!;
  }

  Future<int> registerUser(AppUser user) async {
    final db = await database;
    return db.insert(
      'users',
      user.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<AppUser?> loginUser(String email, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), password],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return AppUser.fromMap(result.first);
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return AppUser.fromMap(result.first);
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    final map = transaction.toMap()..remove('id');

    final id = await db.insert('transactions', map);

    notifyListeners();

    return id;
  }

  Future<List<TransactionModel>> getTransactions(int userId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );

    return result.map(TransactionModel.fromMap).toList();
  }

  Future<TransactionModel?> getTransactionById(int id, int userId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return TransactionModel.fromMap(result.first);
  }

  Future<int> deleteTransaction(int id, int userId) async {
    final db = await database;

    final result = await db.delete(
      'transactions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );

    if (result > 0) {
      notifyListeners();
    }

    return result;
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.update(
      'transactions',
      transaction.toMap()..remove('id'),
      where: 'id = ? AND user_id = ?',
      whereArgs: [transaction.id, transaction.userId],
    );
  }

  Future<Map<String, int>> getBalanceSummary(int userId) async {
    final transactions = await getTransactions(userId);

    int income = 0;
    int expense = 0;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return {'income': income, 'expense': expense, 'balance': income - expense};
  }
}
