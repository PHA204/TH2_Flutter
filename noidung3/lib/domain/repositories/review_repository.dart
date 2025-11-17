// lib/domain/repositories/review_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:noidung3/core/errors/failures.dart'; // ← THÊM DÒNG NÀY

abstract class ReviewRepository {
  Future<Either<Failure, Unit>> addReview({
    required String restaurantId,
    required double rating,
    required String comment,
    required List<File> images,
  });
}