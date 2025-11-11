// lib/presentation/providers/review_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class ReviewProvider extends ChangeNotifier {
  final Future<dynamic> Function({
    required String restaurantId,
    required double rating,
    required String comment,
    required List<File> images,
  }) addReviewUseCase;
  final Future<dynamic> Function(String) getReviewsUseCase;

  ReviewProvider({
    required this.addReviewUseCase,
    required this.getReviewsUseCase,
  });
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  List<dynamic> _reviews = [];
  List<dynamic> get reviews => _reviews;
  
  Future<void> addReview({
    required String restaurantId,
    required double rating,
    required String comment,
    required List<File> images,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await addReviewUseCase(
      restaurantId: restaurantId,
      rating: rating,
      comment: comment,
      images: images,
    );
    
    result.fold(
      (failure) => _errorMessage = failure.message,
      (_) => loadReviews(restaurantId),
    );
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadReviews(String restaurantId) async {
    _isLoading = true;
    notifyListeners();
    
    final result = await getReviewsUseCase(restaurantId);
    
    result.fold(
      (failure) => _errorMessage = failure.message,
      (reviews) => _reviews = reviews,
    );
    
    _isLoading = false;
    notifyListeners();
  }
}