import 'dart:ui';

import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/reading_settings.dart';
import '../services/book_service.dart';
import '../services/settings_service.dart';

class BookProvider extends ChangeNotifier {
  final BookService _bookService = BookService();
  final SettingsService _settingsService = SettingsService();

  Book? _currentBook;
  ReadingSettings _settings = ReadingSettings();
  int _currentPage = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  Book? get currentBook => _currentBook;
  ReadingSettings get settings => _settings;
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPages => _currentBook?.pages.length ?? 0;

  // Khởi tạo - load sách và cài đặt
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load cài đặt
      _settings = await _settingsService.loadSettings();
      
      // Load sách
      _currentBook = await _bookService.loadBook(
        '/books/sample_book.json',
      );
      
      // Chuyển đến trang đã đọc
      _currentPage = _settings.lastPageRead;
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Chuyển trang
  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      _currentPage = page;
      _settings = _settings.copyWith(lastPageRead: page);
      _settingsService.saveSettings(_settings);
      notifyListeners();
    }
  }

  // Trang tiếp theo
  void nextPage() {
    if (_currentPage < totalPages - 1) {
      goToPage(_currentPage + 1);
    }
  }

  // Trang trước
  void previousPage() {
    if (_currentPage > 0) {
      goToPage(_currentPage - 1);
    }
  }

  // Cập nhật cỡ chữ
  void updateFontSize(double size) {
    _settings = _settings.copyWith(fontSize: size);
    _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  // Chuyển chế độ sáng/tối
  void toggleDarkMode() {
    final isDark = !_settings.isDarkMode;
    _settings = _settings.copyWith(
      isDarkMode: isDark,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
      textColor: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF000000),
    );
    _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  // Chọn theme màu
  void changeTheme(String themeName) {
    switch (themeName) {
      case 'sepia':
        _settings = _settings.copyWith(
          backgroundColor: const Color(0xFFF4ECD8),
          textColor: const Color(0xFF5C4A34),
          isDarkMode: false,
        );
        break;
      case 'night':
        _settings = _settings.copyWith(
          backgroundColor: const Color(0xFF1E1E1E),
          textColor: const Color(0xFFE0E0E0),
          isDarkMode: true,
        );
        break;
      default: // light
        _settings = _settings.copyWith(
          backgroundColor: const Color(0xFFFFFFFF),
          textColor: const Color(0xFF000000),
          isDarkMode: false,
        );
    }
    _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  // Reset về cài đặt mặc định
  Future<void> resetSettings() async {
    await _settingsService.clearSettings();
    _settings = ReadingSettings();
    _currentPage = 0;
    notifyListeners();
  }
}