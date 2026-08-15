/// Mirrors the backend's `BasePageApi<T>` envelope.
///
/// ```json
/// {
///   "status": 200,
///   "pagination": { "page": 0, "size": 10, "total": 42, "totalPages": 5 },
///   "data": [ … ]
/// }
/// ```
/// Note the page metadata sits *beside* `data`, not inside it.
class PageResponse<T> {
  PageResponse({
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
    required this.items,
  });

  /// Zero-based, the same convention as Spring Data.
  final int page;
  final int size;
  final int total;
  final int totalPages;
  final List<T> items;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final Map<String, dynamic> meta =
        (json['pagination'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final List<dynamic> rows = (json['data'] as List<dynamic>?) ?? <dynamic>[];

    return PageResponse<T>(
      page: meta['page'] as int? ?? 0,
      size: meta['size'] as int? ?? rows.length,
      total: meta['total'] as int? ?? rows.length,
      totalPages: meta['totalPages'] as int? ?? 1,
      items: rows
          .whereType<Map<String, dynamic>>()
          .map(fromItem)
          .toList(growable: false),
    );
  }

  /// True while there is at least one more page to request.
  bool get hasNext => page + 1 < totalPages;

  /// Page index to ask for next.
  int get nextPage => page + 1;

  /// An empty page, handy as an initial controller state.
  static PageResponse<T> empty<T>() => PageResponse<T>(
    page: 0,
    size: 0,
    total: 0,
    totalPages: 0,
    items: const <Never>[],
  );
}
