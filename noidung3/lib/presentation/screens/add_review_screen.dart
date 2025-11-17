// lib/presentation/screens/add_review_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noidung3/core/config/cloudinary_config.dart';
import 'package:noidung3/presentation/providers/review_provider.dart';
import 'package:provider/provider.dart';

class AddReviewScreen extends StatefulWidget {
  final String restaurantId;
  
  const AddReviewScreen({Key? key, required this.restaurantId}) : super(key: key);

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 5.0;
  List<File> _selectedImages = [];
  
  @override
  void initState() {
    super.initState();
    _checkCloudinaryConfig();
  }
  
  void _checkCloudinaryConfig() {
    if (!CloudinaryConfig.isConfigured()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConfigWarning();
      });
    }
  }
  
  void _showConfigWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Cấu hình Cloudinary'),
        content: Text(CloudinaryConfig.getConfigWarning()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImages() async {
    // Kiểm tra giới hạn
    if (_selectedImages.length >= CloudinaryConfig.maxImagesPerReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum ${CloudinaryConfig.maxImagesPerReview} images allowed',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    // Kiểm tra tổng số ảnh sau khi thêm
    final totalImages = _selectedImages.length + images.length;
    if (totalImages > CloudinaryConfig.maxImagesPerReview) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can only add ${CloudinaryConfig.maxImagesPerReview - _selectedImages.length} more image(s)',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Chỉ lấy số ảnh cho phép
      final allowedCount = CloudinaryConfig.maxImagesPerReview - _selectedImages.length;
      setState(() {
        _selectedImages.addAll(
          images.take(allowedCount).map((xFile) => File(xFile.path))
        );
      });
      return;
    }
    
    setState(() {
      _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
    });
  }
  
  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!CloudinaryConfig.isConfigured()) {
      _showConfigWarning();
      return;
    }
    
    final provider = Provider.of<ReviewProvider>(context, listen: false);
    
    final success = await provider.addReview(
      restaurantId: widget.restaurantId,
      rating: _rating,
      comment: _commentController.text,
      images: _selectedImages,
    );
    
    if (!mounted) return;
    
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to submit review'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Review'),
        elevation: 0,
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Rating section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Rating',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _rating.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < _rating.round() ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 30,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            Slider(
                              value: _rating,
                              min: 1,
                              max: 5,
                              divisions: 8,
                              label: _rating.toStringAsFixed(1),
                              onChanged: (value) => setState(() => _rating = value),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Comment section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Review',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _commentController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: 'Share your experience...',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please write a review';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Photos section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Add Photos',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${_selectedImages.length}/${CloudinaryConfig.maxImagesPerReview}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _selectedImages.length >= CloudinaryConfig.maxImagesPerReview
                                  ? null
                                  : _pickImages,
                              icon: const Icon(Icons.photo_camera),
                              label: Text(_selectedImages.isEmpty 
                                ? 'Add Photos' 
                                : 'Add More Photos'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 45),
                              ),
                            ),
                            
                            // Preview images
                            if (_selectedImages.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.file(
                                              _selectedImages[index],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: -5,
                                            right: -5,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                                size: 28,
                                              ),
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
                              const SizedBox(height: 8),
                              Text(
                                '💡 Tip: Photos will be uploaded to Cloudinary',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit button
                    ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit Review',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
              
              // Loading overlay với progress
              if (provider.isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Uploading ${_selectedImages.length} photo(s)...',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please wait',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}