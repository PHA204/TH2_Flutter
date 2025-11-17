// lib/data/datasources/remote/cloudinary_service.dart
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:noidung3/core/config/cloudinary_config.dart';

class CloudinaryService {
  late final CloudinaryPublic cloudinary;
  
  CloudinaryService() {
    // Kiểm tra config trước khi khởi tạo
    if (!CloudinaryConfig.isConfigured()) {
      throw Exception(CloudinaryConfig.getConfigWarning());
    }
    
    cloudinary = CloudinaryPublic(
      CloudinaryConfig.cloudName,
      CloudinaryConfig.uploadPreset,
      cache: false,
    );
  }
  
  /// Upload một ảnh lên Cloudinary
  Future<String> uploadImage(File imageFile) async {
    try {
      print('📤 Uploading image: ${imageFile.path}');
      
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: CloudinaryConfig.defaultFolder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      print('✅ Upload success: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('❌ Upload failed: $e');
      throw Exception('Upload failed: $e');
    }
  }
  
  /// Upload nhiều ảnh cùng lúc với progress callback
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, {
    Function(int current, int total)? onProgress,
  }) async {
    // Kiểm tra giới hạn số ảnh
    if (imageFiles.length > CloudinaryConfig.maxImagesPerReview) {
      throw Exception(
        'Maximum ${CloudinaryConfig.maxImagesPerReview} images allowed'
      );
    }
    
    List<String> uploadedUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        onProgress?.call(i + 1, imageFiles.length);
        
        final url = await uploadImage(imageFiles[i]);
        uploadedUrls.add(url);
      } catch (e) {
        print('Failed to upload image ${i + 1}: $e');
        rethrow;
      }
    }
    
    return uploadedUrls;
  }
  
  /// Lấy public_id từ URL để có thể xóa sau này
  String? extractPublicId(String imageUrl) {
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      
      final uploadIndex = segments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex >= segments.length - 1) {
        return null;
      }
      
      final pathAfterUpload = segments.skip(uploadIndex + 1).toList();
      if (pathAfterUpload.first.startsWith('v')) {
        pathAfterUpload.removeAt(0);
      }
      
      final publicId = pathAfterUpload.join('/');
      return publicId.substring(0, publicId.lastIndexOf('.'));
    } catch (e) {
      return null;
    }
  }
  
  /// Tạo thumbnail URL từ URL gốc
  /// Cloudinary hỗ trợ transform URL để resize ảnh
  String getThumbnailUrl(String originalUrl, {int width = 300, int height = 300}) {
    try {
      // Ví dụ URL gốc:
      // https://res.cloudinary.com/demo/image/upload/v1234/restaurant_reviews/abc.jpg
      // 
      // Thumbnail URL:
      // https://res.cloudinary.com/demo/image/upload/w_300,h_300,c_fill/v1234/restaurant_reviews/abc.jpg
      
      final transformParams = 'w_$width,h_$height,c_fill';
      return originalUrl.replaceFirst('/upload/', '/upload/$transformParams/');
    } catch (e) {
      return originalUrl; // Fallback về URL gốc nếu lỗi
    }
  }
}