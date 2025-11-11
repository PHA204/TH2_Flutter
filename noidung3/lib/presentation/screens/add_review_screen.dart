// lib/presentation/screens/add_review_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noidung3/presentation/providers/review_provider.dart';
import 'package:provider/provider.dart';

class AddReviewScreen extends StatefulWidget {
  final String restaurantId;
  
  const AddReviewScreen({Key? key, required this.restaurantId}) : super(key: key);

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 5.0;
  List<File> _selectedImages = [];
  
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    setState(() {
      _selectedImages = images.map((xFile) => File(xFile.path)).toList();
    });
  }
  
  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = Provider.of<ReviewProvider>(context, listen: false);
    
    await provider.addReview(
      restaurantId: widget.restaurantId,
      rating: _rating,
      comment: _commentController.text,
      images: _selectedImages,
    );
    
    if (provider.errorMessage == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully!')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Write Review')),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Rating slider
                Text('Rating: ${_rating.toStringAsFixed(1)}'),
                Slider(
                  value: _rating,
                  min: 1,
                  max: 5,
                  divisions: 8,
                  label: _rating.toStringAsFixed(1),
                  onChanged: (value) => setState(() => _rating = value),
                ),
                
                SizedBox(height: 20),
                
                // Comment
                TextFormField(
                  controller: _commentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Your Review',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write a review';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 20),
                
                // Image picker
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.photo),
                  label: Text('Add Photos'),
                ),
                
                // Preview images
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(8),
                          child: Stack(
                            children: [
                              Image.file(_selectedImages[index], height: 100),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                
                SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: _submitReview,
                  child: Text('Submit Review'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}