import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:rentify/data/models/news_article.dart';

class CarNewsPage extends StatefulWidget {
  const CarNewsPage({Key? key}) : super(key: key);

  @override
  _CarNewsPageState createState() => _CarNewsPageState();
}

class _CarNewsPageState extends State<CarNewsPage> {
  late List<NewsArticle> _newsArticles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCarNews();
  }

  Future<void> _fetchCarNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Using the News API with gnews.io (free tier)
      // You can register for a free API key at https://gnews.io/
      final url =
          'https://gnews.io/api/v4/search?q=automobile+OR+car&lang=en&country=us&max=10&apikey=YOUR_API_KEY';

      // For demo purposes, let's use a sample JSON response
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _newsArticles = (data['articles'] as List)
              .map((article) => NewsArticle.fromJson(article))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch news. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;

        // For demonstration purposes, load sample data if API call fails
        _loadSampleData();
      });
    }
  }

  void _loadSampleData() {
    // Sample car news data for demonstration
    _newsArticles = [
      NewsArticle(
        title: 'New Electric Vehicle Models Set to Launch Next Year',
        description:
            'Major automakers are planning to release several new electric vehicle models in the upcoming year, promising longer range and faster charging.',
        imageUrl:
            'https://images.unsplash.com/photo-1593941707882-a5bba13938c9?q=80&w=1472&auto=format&fit=crop',
        articleUrl: 'https://example.com/ev-news',
        publishedAt: '2025-04-01T10:30:00Z',
        source: 'Auto News Daily',
      ),
      NewsArticle(
        title: 'Autonomous Driving Technology Reaches New Milestone',
        description:
            'The latest developments in self-driving car technology show promising results in urban environments, with reduced accident rates and improved navigation.',
        imageUrl:
            'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=1374&auto=format&fit=crop',
        articleUrl: 'https://example.com/autonomous-cars',
        publishedAt: '2025-04-02T14:15:00Z',
        source: 'Tech Drive Magazine',
      ),
      NewsArticle(
        title: 'Classic Car Values Continue to Rise in Collector Market',
        description:
            'Vintage automobiles from the 1960s and 1970s are seeing unprecedented value increases at auctions worldwide as collector interest grows.',
        imageUrl:
            'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=1470&auto=format&fit=crop',
        articleUrl: 'https://example.com/classic-cars',
        publishedAt: '2025-04-03T09:45:00Z',
        source: 'Classic Auto Journal',
      ),
      NewsArticle(
        title: 'Hydrogen Fuel Cell Cars: The Future or Just a Niche?',
        description:
            'As battery electric vehicles dominate the headlines, hydrogen fuel cell technology continues to develop with new infrastructure projects announced.',
        imageUrl:
            'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?q=80&w=1528&auto=format&fit=crop',
        articleUrl: 'https://example.com/hydrogen-cars',
        publishedAt: '2025-04-04T11:20:00Z',
        source: 'Future Mobility Report',
      ),
    ];
  }

  Future<void> _openArticle(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2C2B34),
      appBar: AppBar(
        title: Text('Car News', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_errorMessage != null && _newsArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchCarNews,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_newsArticles.isEmpty) {
      return Center(
        child: Text(
          'No news articles found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCarNews,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _newsArticles.length,
        itemBuilder: (context, index) {
          return _buildNewsCard(_newsArticles[index]);
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                article.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        article.source,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Text(
                      article.formattedDate,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  article.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  article.description,
                  style: TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _openArticle(article.articleUrl),
                    child: Text('READ MORE'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      textStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
