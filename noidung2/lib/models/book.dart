class Book {
  final String title;
  final String author;
  final List<BookPage> pages;

  Book({
    required this.title,
    required this.author,
    required this.pages,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      pages: (json['pages'] as List)
          .map((page) => BookPage.fromJson(page))
          .toList(),
    );
  }
}

class BookPage {
  final int number;
  final String content;

  BookPage({
    required this.number,
    required this.content,
  });

  factory BookPage.fromJson(Map<String, dynamic> json) {
    return BookPage(
      number: json['number'] ?? 0,
      content: json['content'] ?? '',
    );
  }
}