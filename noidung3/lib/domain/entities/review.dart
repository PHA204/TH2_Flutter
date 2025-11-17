// lib/domain/entities/review.dart
class Review {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final List<String> imageUrls;
  final DateTime createdAt;
  
  Review({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.imageUrls,
    required this.createdAt,
  });
}