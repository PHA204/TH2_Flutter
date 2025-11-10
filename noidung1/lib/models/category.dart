import 'package:flutter/material.dart';
import 'package:noidung1/models/transaction.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final Color color;

  CategoryModel({
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Danh sách category mặc định
class Categories {
  static final List<CategoryModel> expenseCategories = [
    CategoryModel(
      name: 'Ăn uống',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    CategoryModel(
      name: 'Di chuyển',
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    CategoryModel(
      name: 'Mua sắm',
      icon: Icons.shopping_bag,
      color: Colors.pink,
    ),
    CategoryModel(
      name: 'Giải trí',
      icon: Icons.movie,
      color: Colors.purple,
    ),
    CategoryModel(
      name: 'Hóa đơn',
      icon: Icons.receipt,
      color: Colors.red,
    ),
    CategoryModel(
      name: 'Sức khỏe',
      icon: Icons.health_and_safety,
      color: Colors.green,
    ),
    CategoryModel(
      name: 'Giáo dục',
      icon: Icons.school,
      color: Colors.indigo,
    ),
    CategoryModel(
      name: 'Khác',
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  ];

  static final List<CategoryModel> incomeCategories = [
    CategoryModel(
      name: 'Lương',
      icon: Icons.account_balance_wallet,
      color: Colors.green,
    ),
    CategoryModel(
      name: 'Thưởng',
      icon: Icons.card_giftcard,
      color: Colors.amber,
    ),
    CategoryModel(
      name: 'Đầu tư',
      icon: Icons.trending_up,
      color: Colors.teal,
    ),
    CategoryModel(
      name: 'Khác',
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  ];

  // Lấy CategoryModel từ tên
  static CategoryModel? getCategoryByName(String name, TransactionType type) {
    final list = type == TransactionType.income 
        ? incomeCategories 
        : expenseCategories;
    
    try {
      return list.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }
}