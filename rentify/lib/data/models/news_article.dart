import 'package:intl/intl.dart';

class NewsArticle {
  final String title;
  final String description;
  final String imageUrl;
  final String articleUrl;
  final String publishedAt;
  final String source;

  NewsArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.articleUrl,
    required this.publishedAt,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description available',
      imageUrl: json['urlToImage'] ?? '',
      articleUrl: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      source: json['source']?['name'] ?? 'Unknown',
    );
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(publishedAt);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }
}
