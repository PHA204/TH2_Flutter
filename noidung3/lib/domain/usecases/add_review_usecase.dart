// lib/domain/usecases/add_review_usecase.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:noidung3/core/errors/failures.dart';
import 'package:noidung3/domain/repositories/review_repository.dart'; // Import từ file mới

class ValidationFailure extends Failure {
  final String message;
  ValidationFailure(this.message) : super('');

  @override
  String toString() => 'ValidationFailure: $message';
}

class AddReviewUseCase {
  final ReviewRepository repository;
  
  AddReviewUseCase(this.repository);
  
  Future<Object> call({
    required String restaurantId,
    required double rating,
    required String comment,
    required List<File> images,
  }) async {
    // Validate
    if (rating < 1 || rating > 5) {
      return Left(ValidationFailure('Rating must be between 1 and 5'));
    }
    if (comment.trim().isEmpty) {
      return Left(ValidationFailure('Comment cannot be empty'));
    }
    
    return await repository.addReview(
      restaurantId: restaurantId,
      rating: rating,
      comment: comment,
      images: images,
    );
  }
}