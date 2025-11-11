// lib/domain/entities/restaurant.dart
class Restaurant {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final double averageRating;
  final int reviewCount;
  final List<String> categories;
  
  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.categories,
  });
}