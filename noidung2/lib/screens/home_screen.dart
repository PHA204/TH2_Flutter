import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'reader_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện Sách'),
        centerTitle: true,
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, child) {
          // LOADING STATE
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR STATE
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${provider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.initialize(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // BOOK LOADED
          final book = provider.currentBook;
          if (book == null) {
            return const Center(
              child: Text('Không có sách'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BOOK CARD
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReaderScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // BOOK ICON
                          Container(
                            width: 80,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue[700]!,
                                  Colors.blue[500]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.menu_book,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          
                          const SizedBox(width: 20),
                          
                          // BOOK INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tác giả: ${book.author}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.article,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${book.pages.length} trang',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // PROGRESS BAR
                                LinearProgressIndicator(
                                  value: (provider.currentPage + 1) / 
                                         book.pages.length,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue[600]!,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Đã đọc: ${provider.currentPage + 1}/${book.pages.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // ARROW ICON
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // ACTION BUTTONS
                const Text(
                  'Thao tác nhanh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    // CONTINUE READING
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.play_arrow,
                        label: 'Tiếp tục đọc',
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReaderScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // START FROM BEGINNING
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.refresh,
                        label: 'Đọc lại từ đầu',
                        color: Colors.orange,
                        onTap: () {
                          provider.goToPage(0);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReaderScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}