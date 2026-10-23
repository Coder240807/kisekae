class SearchHistoryItem {
  final int id;
  final String query;
  final int searchCount;
  final DateTime? lastSearchedAt;
  final DateTime? createdAt;

  SearchHistoryItem({
    required this.id,
    required this.query,
    required this.searchCount,
    this.lastSearchedAt,
    this.createdAt,
  });

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      id: json['id'] as int? ?? 0,
      query: json['query'] as String? ?? '',
      searchCount: json['search_count'] as int? ?? 1,
      lastSearchedAt: DateTime.tryParse(
        json['last_searched_at'] as String? ?? '',
      ),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
