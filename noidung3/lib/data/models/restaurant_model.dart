// lib/data/models/restaurant_model.dart
import 'package:noidung3/domain/entities/restaurant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel extends Restaurant {
  RestaurantModel({
    required super.id,
    required super.name,
    required super.address,
    required super.imageUrl,
    required super.averageRating,
    required super.reviewCount,
    required super.categories,
  });
  
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      categories: List<String>.from(data['categories'] ?? []),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'categories': categories,
    };
  }
}