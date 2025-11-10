import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseService {
  // Singleton pattern - chỉ có 1 instance duy nhất
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  // Getter cho database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Khởi tạo database
  Future<Database> _initDatabase() async {
    // Lấy đường dẫn thư mục database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    // Mở database (tạo mới nếu chưa tồn tại)
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Tạo bảng khi database được tạo lần đầu
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  // THÊM GIAO DỊCH
  Future<void> insertTransaction(Transaction transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // LẤY TẤT CẢ GIAO DỊCH
  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',  // Sắp xếp mới nhất trước
    );

    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  // LẤY GIAO DỊCH THEO KHOẢNG THỜI GIAN
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  // LẤY GIAO DỊCH THEO THÁNG
  Future<List<Transaction>> getTransactionsByMonth(
    int year,
    int month,
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    return getTransactionsByDateRange(startDate, endDate);
  }

  // CẬP NHẬT GIAO DỊCH
  Future<void> updateTransaction(Transaction transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // XÓA GIAO DỊCH
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // THỐNG KÊ THEO DANH MỤC (cho biểu đồ)
  Future<Map<String, double>> getExpensesByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await getTransactionsByDateRange(startDate, endDate);
    final expenses = transactions.where(
      (t) => t.type == TransactionType.expense
    );

    final Map<String, double> categoryTotals = {};

    for (var transaction in expenses) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }

  // TÍNH TỔNG THU/CHI
  Future<Map<String, double>> getTotals(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await getTransactionsByDateRange(startDate, endDate);
    
    double totalIncome = 0;
    double totalExpense = 0;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  // XÓA TẤT CẢ DỮ LIỆU (dùng cho reset)
  Future<void> deleteAllTransactions() async {
    final db = await database;
    await db.delete('transactions');
  }

  // ĐÓNG DATABASE
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}