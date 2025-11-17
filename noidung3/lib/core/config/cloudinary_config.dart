// lib/core/config/cloudinary_config.dart

/// Config cho Cloudinary
/// Tách riêng để dễ quản lý và thay đổi
class CloudinaryConfig {
  // TODO: Cập nhật giá trị này
  static const String cloudName = 'dwnzqig9h'; // Ví dụ: 'dkm3xfz9p'
  static const String uploadPreset = 'restaurant_reviews'; // Ví dụ: 'restaurant_reviews'
  
  // Folder mặc định để lưu ảnh
  static const String defaultFolder = 'restaurant_reviews';
  
  // Giới hạn số ảnh upload cùng lúc
  static const int maxImagesPerReview = 5;
  
  // Validate config
  static bool isConfigured() {
    return cloudName != 'dwnzqig9h' && 
           uploadPreset != 'restaurant_reviews';
  }
  
  // Hiển thị thông báo nếu chưa config
  static String getConfigWarning() {
    if (!isConfigured()) {
      return '''
❌ Chưa cấu hình Cloudinary!

Vui lòng cập nhật:
1. Mở file: lib/core/config/cloudinary_config.dart
2. Thay đổi:
   - cloudName = 'your_cloud_name' → Cloud Name của bạn
   - uploadPreset = 'your_upload_preset' → Upload Preset của bạn

Xem hướng dẫn chi tiết trong file Setup Guide.
''';
    }
    return '';
  }
}