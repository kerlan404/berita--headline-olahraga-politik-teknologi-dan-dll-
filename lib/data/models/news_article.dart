class NewsArticle {
  final String? sourceName;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String? content;

  NewsArticle({
    this.sourceName,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    // Handling nested source object from NewsAPI
    String? srcName;
    if (json['source'] != null && json['source'] is Map) {
      srcName = json['source']['name'];
    } else if (json['sourceName'] != null) {
      srcName = json['sourceName'];
    }

    return NewsArticle(
      sourceName: srcName ?? 'Unknown Source',
      author: json['author'] as String?,
      title: json['title'] ?? 'No Title',
      description: json['description'] as String?,
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] ?? DateTime.now().toIso8601String(),
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceName': sourceName,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
    };
  }
}
