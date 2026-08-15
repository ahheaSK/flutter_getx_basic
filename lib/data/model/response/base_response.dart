/// Mirrors the backend's `BaseApi<T>` envelope.
///
/// Every non-paginated success looks like this:
/// ```json
/// { "status": 200, "title": "OK", "timestamp": 1786, "data": { … } }
/// ```
/// so the real payload always lives under `data`.
class BaseResponse<T> {
  BaseResponse({this.status, this.title, this.data});

  final int? status;
  final String? title;
  final T? data;

  /// [fromData] converts the raw `data` map into the model type.
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromData,
  ) {
    final Object? raw = json['data'];
    return BaseResponse<T>(
      status: json['status'] as int?,
      title: json['title'] as String?,
      data: raw is Map<String, dynamic> ? fromData(raw) : null,
    );
  }
}

// /Users/_jan_codes_/Documents/course study/My/project_flutter_getx_basic



// flow work of this project



// UI -> controller ->model -> toJson -> service and 

// service fromJson -> model
