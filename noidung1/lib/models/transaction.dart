class Transaction {
  final String id;              // ID duy nhất
  final String title;           // Tiêu đề: "Mua cafe", "Lương tháng 10"
  final double amount;          // Số tiền: 50000, 15000000
  final DateTime date;          // Ngày giao dịch
  final String category;        // Danh mục: "Ăn uống", "Lương"
  final TransactionType type;   // Loại: thu hay chi

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });

  // Chuyển object thành Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),  // "2024-10-15T14:30:00"
      'category': category,
      'type': type.name,  // "income" hoặc "expense"
    };
  }

  // Tạo object từ Map khi đọc từ SQLite
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      type: map['type'] == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
    );
  }

  // Copy với giá trị mới (dùng khi update)
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
    );
  }
}

// Enum cho loại giao dịch
enum TransactionType {
  income,   // Thu nhập
  expense,  // Chi tiêu
}