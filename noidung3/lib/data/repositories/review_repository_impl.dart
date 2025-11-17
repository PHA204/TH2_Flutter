// lib/data/repositories/review_repository_impl.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noidung3/core/errors/failures.dart';
import 'package:noidung3/data/datasources/remote/cloudinary_service.dart';
import 'package:noidung3/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore firestore;
  final CloudinaryService cloudinaryService;
  
  ReviewRepositoryImpl({
    required this.firestore,
    required this.cloudinaryService,
  });
  
  @override
  Future<Either<Failure, Unit>> addReview({
    required String restaurantId,
    required double rating,
    required String comment,
    required List<File> images,
  }) async {
    try {
      List<String> imageUrls = [];
      for (var image in images) {
        final url = await cloudinaryService.uploadImage(image);
        imageUrls.add(url);
      }
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left(ServerFailure('User not authenticated'));
      }
      
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
      await _updateRestaurantRating(restaurantId);
      
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to add review: $e'));
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