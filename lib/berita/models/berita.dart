import 'package:intl/intl.dart';

/// A single news article entry (aggregated from Google CSE or seed data).
class Berita {
  final String id;
  final String title;
  final String source;
  final String url;
  final String? imageUrl;
  final String snippet;
  final DateTime publishedAt;

  const Berita({
    required this.id,
    required this.title,
    required this.source,
    required this.url,
    required this.imageUrl,
    required this.snippet,
    required this.publishedAt,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    final publishedRaw = json['publishedAt'] as String? ?? '';
    final parsed = DateTime.tryParse(publishedRaw) ?? DateTime.now();
    return Berita(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled',
      source: json['source'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      snippet: json['snippet'] as String? ?? '',
      publishedAt: parsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'source': source,
        'url': url,
        'imageUrl': imageUrl,
        'snippet': snippet,
        'publishedAt': publishedAt.toIso8601String(),
      };

  /// Friendly relative date ("3 hours ago", "Yesterday", "Jul 12").
  String get relativeDate {
    final now = DateTime.now();
    final diff = now.difference(publishedAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(publishedAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Berita &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          url == other.url;

  @override
  int get hashCode => Object.hash(id, title, url);
}
