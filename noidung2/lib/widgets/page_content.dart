import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/reading_settings.dart';
import 'custom_page_painter.dart';

class PageContent extends StatelessWidget {
  final BookPage page;
  final ReadingSettings settings;

  const PageContent({
    Key? key,
    required this.page,
    required this.settings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CustomPagePainter(
        backgroundColor: settings.backgroundColor,
        decorationColor: settings.textColor,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // PAGE NUMBER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trang ${page.number}',
                  style: TextStyle(
                    fontSize: 14,
                    color: settings.textColor.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.book,
                  size: 16,
                  color: settings.textColor.withOpacity(0.5),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  page.content,
                  style: TextStyle(
                    fontSize: settings.fontSize,
                    color: settings.textColor,
                    height: 1.8,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // BOTTOM DECORATION
            Container(
              width: 50,
              height: 3,
              decoration: BoxDecoration(
                color: settings.textColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}