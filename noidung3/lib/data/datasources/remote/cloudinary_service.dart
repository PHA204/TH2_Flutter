// lib/data/datasources/remote/cloudinary_service.dart
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
class CloudinaryService {
  final cloudinary = CloudinaryPublic('your_cloud_name', 'your_upload_preset', cache: false);
  
  Future<String> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path,
          folder: 'restaurant_reviews',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
  
  Future<void> deleteImage(String publicId) async {
    // Cần gọi API backend để xóa vì cần api_secret
  }
}