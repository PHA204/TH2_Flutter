import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  // Danh sách giao dịch hiện tại
  List<Transaction> _transactions = [];
  
  // Loading state
  bool _isLoading = false;
  
  // Tháng hiện tại đang xem
  DateTime _selectedMonth = DateTime.now();

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;

  // Lấy giao dịch theo loại
  List<Transaction> get incomeTransactions => 
      _transactions.where((t) => t.type == TransactionType.income).toList();
  
  List<Transaction> get expenseTransactions => 
      _transactions.where((t) => t.type == TransactionType.expense).toList();

  // Tính tổng thu
  double get totalIncome {
    return incomeTransactions.fold(0, (sum, t) => sum + t.amount);
  }

  // Tính tổng chi
  double get totalExpense {
    return expenseTransactions.fold(0, (sum, t) => sum + t.amount);
  }

  // Số dư
  double get balance => totalIncome - totalExpense;

  // LOAD DỮ LIỆU TỪ DATABASE
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _db.getTransactionsByMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // THÊM GIAO DỊCH MỚI
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _db.insertTransaction(transaction);
      await loadTransactions();  // Reload lại danh sách
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;  // Throw lại để UI xử lý
    }
  }

  // CẬP NHẬT GIAO DỊCH
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _db.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  // XÓA GIAO DỊCH
  Future<void> deleteTransaction(String id) async {
    try {
      await _db.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  // CHUYỂN THÁNG
  void changeMonth(int monthsToAdd) {
    _selectedMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + monthsToAdd,
    );
    loadTransactions();
  }

  // DỮ LIỆU CHO BIỂU ĐỒ TRÒN
  Map<String, double> getCategoryData() {
    final Map<String, double> data = {};
    
    for (var transaction in expenseTransactions) {
      data[transaction.category] = 
          (data[transaction.category] ?? 0) + transaction.amount;
    }
    
    return data;
  }

  // DỮ LIỆU CHO BIỂU ĐỒ CỘT (7 ngày gần nhất)
  Map<DateTime, double> getDailyExpenses({int days = 7}) {
    final Map<DateTime, double> data = {};
    final now = DateTime.now();
    
    // Khởi tạo 7 ngày với giá trị 0
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      data[date] = 0;
    }
    
    // Cộng dồn chi tiêu theo ngày
    for (var transaction in expenseTransactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      if (data.containsKey(date)) {
        data[date] = data[date]! + transaction.amount;
      }
    }
    
    return data;
  }

  // NHÓM GIAO DỊCH THEO NGÀY (cho ListView)
  Map<DateTime, List<Transaction>> getTransactionsGroupedByDate() {
    final Map<DateTime, List<Transaction>> grouped = {};
    
    for (var transaction in _transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }
    
    return grouped;
  }
}