// lib/presentation/screens/restaurant_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:noidung3/data/models/restaurant_model.dart';

class RestaurantListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Restaurants'),
              background: Image.asset(
                'assets/header.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('restaurants')
                .orderBy('averageRating', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final restaurants = snapshot.data!.docs;
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final restaurant = RestaurantModel.fromFirestore(
                      restaurants[index],
                    );
                    
                    return RestaurantCard(restaurant: restaurant);
                  },
                  childCount: restaurants.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}