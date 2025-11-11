import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/page_content.dart';
import 'settings_screen.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({Key? key}) : super(key: key);

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late PageController _pageController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BookProvider>(context, listen: false);
    _pageController = PageController(initialPage: provider.currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        final book = provider.currentBook;
        
        if (book == null) {
          return const Scaffold(
            body: Center(child: Text('Không có sách')),
          );
        }

        return Scaffold(
          backgroundColor: provider.settings.backgroundColor,
          
          // APP BAR
          appBar: _showControls
              ? AppBar(
                  title: Text(book.title),
                  backgroundColor: provider.settings.backgroundColor,
                  foregroundColor: provider.settings.textColor,
                  elevation: 0,
                  actions: [
                    // NÚT CÀI ĐẶT
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                )
              : null,
          
          // BODY - PAGE VIEW
          body: GestureDetector(
            onTap: _toggleControls,
            child: PageView.builder(
              controller: _pageController,
              itemCount: book.pages.length,
              onPageChanged: (index) {
                provider.goToPage(index);
              },
              itemBuilder: (context, index) {
                return PageContent(
                  page: book.pages[index],
                  settings: provider.settings,
                );
              },
            ),
          ),
          
          // BOTTOM BAR
          bottomNavigationBar: _showControls
              ? _buildBottomControls(provider, book.pages.length)
              : null,
        );
      },
    );
  }

  Widget _buildBottomControls(BookProvider provider, int totalPages) {
    return Container(
      color: provider.settings.backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SLIDER
          Row(
            children: [
              Text(
                '${provider.currentPage + 1}',
                style: TextStyle(
                  color: provider.settings.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Slider(
                  value: provider.currentPage.toDouble(),
                  min: 0,
                  max: (totalPages - 1).toDouble(),
                  divisions: totalPages - 1,
                  onChanged: (value) {
                    final page = value.toInt();
                    provider.goToPage(page);
                    _pageController.jumpToPage(page);
                  },
                ),
              ),
              Text(
                '$totalPages',
                style: TextStyle(
                  color: provider.settings.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // PREVIOUS
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: provider.settings.textColor,
                ),
                onPressed: provider.currentPage > 0
                    ? () {
                        provider.previousPage();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
              
              // THEME TOGGLE
              IconButton(
                icon: Icon(
                  provider.settings.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: provider.settings.textColor,
                ),
                onPressed: () {
                  provider.toggleDarkMode();
                },
              ),
              
              // TABLE OF CONTENTS
              IconButton(
                icon: Icon(
                  Icons.menu_book,
                  color: provider.settings.textColor,
                ),
                onPressed: () {
                  _showTableOfContents(context, provider);
                },
              ),
              
              // NEXT
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: provider.settings.textColor,
                ),
                onPressed: provider.currentPage < totalPages - 1
                    ? () {
                        provider.nextPage();
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTableOfContents(BuildContext context, BookProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: provider.settings.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mục lục',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: provider.settings.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.currentBook!.pages.length,
                  itemBuilder: (context, index) {
                    final isCurrentPage = index == provider.currentPage;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrentPage
                            ? Colors.blue
                            : Colors.grey[300],
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrentPage
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Trang ${index + 1}',
                        style: TextStyle(
                          color: provider.settings.textColor,
                          fontWeight: isCurrentPage
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isCurrentPage
                          ? Icon(
                              Icons.play_arrow,
                              color: Colors.blue,
                            )
                          : null,
                      onTap: () {
                        provider.goToPage(index);
                        _pageController.jumpToPage(index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}