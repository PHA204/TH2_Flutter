import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: provider.settings.backgroundColor,
          appBar: AppBar(
            title: const Text('Cài đặt'),
            backgroundColor: provider.settings.backgroundColor,
            foregroundColor: provider.settings.textColor,
            elevation: 0,
            actions: [
              // NÚT RESET
              TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xác nhận'),
                      content: const Text(
                        'Bạn có chắc muốn khôi phục cài đặt mặc định?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Đồng ý'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true && context.mounted) {
                    await provider.resetSettings();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã khôi phục cài đặt mặc định'),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'Reset',
                  style: TextStyle(color: provider.settings.textColor),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // FONT SIZE
              _buildSection(
                title: 'Kích thước chữ',
                provider: provider,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 14,
                            color: provider.settings.textColor,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: provider.settings.fontSize,
                            min: 12,
                            max: 32,
                            divisions: 20,
                            label: provider.settings.fontSize.round().toString(),
                            onChanged: (value) {
                              provider.updateFontSize(value);
                            },
                          ),
                        ),
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 24,
                            color: provider.settings.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kích thước hiện tại: ${provider.settings.fontSize.round()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: provider.settings.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // THEME
              _buildSection(
                title: 'Giao diện',
                provider: provider,
                child: Column(
                  children: [
                    _buildThemeOption(
                      context,
                      provider: provider,
                      themeName: 'light',
                      label: 'Sáng',
                      icon: Icons.light_mode,
                      backgroundColor: const Color(0xFFFFFFFF),
                      textColor: const Color(0xFF000000),
                    ),
                    const SizedBox(height: 12),
                    _buildThemeOption(
                      context,
                      provider: provider,
                      themeName: 'sepia',
                      label: 'Sepia',
                      icon: Icons.wb_sunny_outlined,
                      backgroundColor: const Color(0xFFF4ECD8),
                      textColor: const Color(0xFF5C4A34),
                    ),
                    const SizedBox(height: 12),
                    _buildThemeOption(
                      context,
                      provider: provider,
                      themeName: 'night',
                      label: 'Tối',
                      icon: Icons.dark_mode,
                      backgroundColor: const Color(0xFF1E1E1E),
                      textColor: const Color(0xFFE0E0E0),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // PREVIEW
              _buildSection(
                title: 'Xem trước',
                provider: provider,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: provider.settings.backgroundColor,
                    border: Border.all(
                      color: provider.settings.textColor.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Trăm năm trong cõi người ta,\nChữ tài chữ mệnh khéo là ghét nhau.\nTrải qua một cuộc bể dâu,\nNhững điều trông thấy mà đau đớn lòng.',
                    style: TextStyle(
                      fontSize: provider.settings.fontSize,
                      color: provider.settings.textColor,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // INFO
              _buildSection(
                title: 'Thông tin',
                provider: provider,
                child: Column(
                  children: [
                    _buildInfoRow(
                      provider: provider,
                      label: 'Trang đã đọc',
                      value: '${provider.currentPage + 1}/${provider.totalPages}',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      provider: provider,
                      label: 'Tiến độ',
                      value: '${((provider.currentPage + 1) / provider.totalPages * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required BookProvider provider,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: provider.settings.textColor,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: provider.settings.backgroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: provider.settings.textColor.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required BookProvider provider,
    required String themeName,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    final isSelected = provider.settings.backgroundColor == backgroundColor;
    
    return InkWell(
      onTap: () => provider.changeTheme(themeName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trăm năm trong cõi người ta',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BookProvider provider,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: provider.settings.textColor.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: provider.settings.textColor,
          ),
        ),
      ],
    );
  }
}