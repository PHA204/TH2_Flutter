// lib/presentation/widgets/restaurant_card.dart
import 'package:flutter/material.dart';
import 'package:noidung3/domain/entities/restaurant.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  
  const RestaurantCard({Key? key, required this.restaurant}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to restaurant detail
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
          // ));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant image
            CachedNetworkImage(
              imageUrl: restaurant.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Colors.grey[300],
                child: Icon(Icons.restaurant, size: 50),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Address
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Rating and reviews
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text(
                        restaurant.averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${restaurant.reviewCount} reviews)',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Categories
                  Wrap(
                    spacing: 8,
                    children: restaurant.categories.take(3).map((category) {
                      return Chip(
                        label: Text(
                          category,
                          style: TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.blue[50],
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}