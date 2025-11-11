import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/book.dart';

class BookService {
  // Đọc sách từ assets
  Future<Book> loadBook(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return Book.fromJson(jsonData);
    } catch (e) {
      throw Exception('Không thể đọc file sách: $e');
    }
  }

  // Lấy danh sách sách có sẵn (mở rộng sau)
  Future<List<String>> getAvailableBooks() async {
    return [
      'assets/books/sample_book.json',
    ];
  }
}