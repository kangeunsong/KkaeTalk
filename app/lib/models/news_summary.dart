class NewsSummary {
  final String url;
  final int originalLength;
  final int summaryLength;
  final String originalText;
  final String summary;

  NewsSummary({
    required this.url,
    required this.originalLength,
    required this.summaryLength,
    required this.originalText,
    required this.summary,
  });

  factory NewsSummary.fromJson(Map<String, dynamic> json) {
    return NewsSummary(
      url: json['url'] as String,
      originalLength: json['original_length'] as int,
      summaryLength: json['summary_length'] as int,
      originalText: json['original_text'] as String,
      summary: json['summary'] as String,
    );
  }
}
