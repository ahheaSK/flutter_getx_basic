import 'package:dio/dio.dart';

import '../../constant/api_constant.dart';
import '../../constant/app_constant.dart';
import 'api_exception.dart';
import 'logger.dart';
import 'token_storage.dart';

/// The one place that talks HTTP.
///
/// Services call [get] / [post] / [put] / [delete] and receive a decoded JSON
/// map. Everything tedious happens here once:
///
/// * the Bearer token is attached to every request
/// * a 401 clears the stored token and reports itself as [ApiException]
/// * `DioException` — timeouts, no connection, error statuses — is translated
///   into that same [ApiException], so no controller ever imports Dio
class ApiClient {
  ApiClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstant.baseUrl,
        connectTimeout: AppConstant.connectTimeout,
        receiveTimeout: AppConstant.receiveTimeout,
        contentType: Headers.jsonContentType,
        // Accept every status so error bodies reach _handle instead of being
        // thrown by Dio before the server's "detail" message can be read.
        validateStatus: (_) => true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final String? token = _tokenStorage.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          Logger.d('API', '${options.method} ${options.path}');
          return handler.next(options);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  late final Dio _dio;

  /// Exposed so `SseService` can reuse the same configured client.
  Dio get dio => _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return _send(() => _dio.get(path, queryParameters: query));
  }

  Future<Map<String, dynamic>> post(String path, {Object? body}) async {
    return _send(() => _dio.post(path, data: body));
  }

  Future<Map<String, dynamic>> put(String path, {Object? body}) async {
    return _send(() => _dio.put(path, data: body));
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return _send(() => _dio.patch(path, queryParameters: query));
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _send(() => _dio.delete(path));
  }

  /// Multipart upload — used by the profile image endpoint.
  ///
  /// The field name must be `file`: the backend declares `@RequestPart("file")`.
  Future<Map<String, dynamic>> upload(
    String path, {
    required String filePath,
    String field = 'file',
  }) async {
    final FormData form = FormData.fromMap(<String, dynamic>{
      field: await MultipartFile.fromFile(filePath),
    });
    return _send(() => _dio.post(path, data: form));
  }

  /// Runs the request and turns anything that is not a 2xx into [ApiException].
  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final Response<dynamic> response = await request();
      final int status = response.statusCode ?? 0;
      final dynamic data = response.data;

      if (status >= 200 && status < 300) {
        if (data is Map<String, dynamic>) return data;
        // A 200 with an empty body (some DELETEs) is still a success.
        return <String, dynamic>{};
      }

      throw _fromErrorBody(status, data);
    } on DioException catch (e) {
      // The request never completed: no network, DNS failure, timeout.
      throw ApiException(_networkMessage(e));
    }
  }

  /// Reads the backend's `BaseError` shape; falls back to a generic message.
  ApiException _fromErrorBody(int status, dynamic data) {
    String message = 'Request failed ($status)';
    String? trackingId;

    if (data is Map<String, dynamic>) {
      final Object? detail = data['detail'];
      if (detail is String && detail.isNotEmpty) message = detail;
      final Object? id = data['trackingId'];
      if (id is String) trackingId = id;
    }

    // The token is gone or expired — drop it so the app stops pretending
    // to be logged in. Routing to login is the controller's decision.
    if (status == 401) _tokenStorage.clear();

    Logger.e('API', '$status $message');
    return ApiException(message, statusCode: status, trackingId: trackingId);
  }

  String _networkMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to answer. Try again.';
      case DioExceptionType.connectionError:
        return 'Cannot reach the server at ${ApiConstant.baseUrl}.\n'
            'Is the backend running, and is the address right for this device?';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return e.message ?? 'Network error.';
    }
  }
}
