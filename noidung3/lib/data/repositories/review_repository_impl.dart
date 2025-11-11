// lib/data/repositories/review_repository_impl.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noidung3/data/datasources/remote/cloudinary_service.dart';

// Minimal Failure types so this repository can return Either<Failure, Unit>.
// If you already have a shared Failure implementation in your project,
// replace these with an import from that file.
abstract class Failure {
  final String message;
  Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class ReviewRepositoryImpl {
  final FirebaseFirestore firestore;
  final CloudinaryService cloudinaryService;
  
  ReviewRepositoryImpl({
    required this.firestore,
    required this.cloudinaryService,
  });
  
  Future<Either<Failure, Unit>> addReview({
    required String restaurantId,
    required double rating,
    required String comment,
    required List<File> images,
  }) async {
    try {
      // 1. Upload ảnh lên Cloudinary
      List<String> imageUrls = [];
      for (var image in images) {
        final url = await cloudinaryService.uploadImage(image);
        imageUrls.add(url);
      }
      
      // 2. Lưu review vào Firestore
      final user = FirebaseAuth.instance.currentUser!;
      final reviewData = {
        'restaurantId': restaurantId,
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'rating': rating,
        'comment': comment,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await firestore.collection('reviews').add(reviewData);
      
      // 3. Cập nhật rating trung bình của nhà hàng
      await _updateRestaurantRating(restaurantId);
      
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  Future<void> _updateRestaurantRating(String restaurantId) async {
    final reviews = await firestore
        .collection('reviews')
        .where('restaurantId', isEqualTo: restaurantId)
        .get();
    
    double totalRating = 0;
    for (var doc in reviews.docs) {
      totalRating += (doc.data()['rating'] as num).toDouble();
    }
    
    final averageRating = reviews.docs.isEmpty ? 0.0 : totalRating / reviews.docs.length;
    
    await firestore.collection('restaurants').doc(restaurantId).update({
      'averageRating': averageRating,
      'reviewCount': reviews.docs.length,
    });
  }
}