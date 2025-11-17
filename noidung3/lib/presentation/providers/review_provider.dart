// lib/presentation/providers/review_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:noidung3/core/errors/failures.dart';
import 'package:noidung3/domain/usecases/add_review_usecase.dart';

class ReviewProvider extends ChangeNotifier {
  final AddReviewUseCase addReviewUseCase;
  
  ReviewProvider({
    required this.addReviewUseCase,
  });
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  Future<bool> addReview({
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
    
    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        success = false;
      },
      (_) {
        success = true;
      },
    );
    
    _isLoading = false;
    notifyListeners();
    
    return success;
  }
}