import 'package:either_dart/either.dart';

import '../../constant/api_constant.dart';
import '../../core/util/api_client.dart';
import '../../core/util/api_exception.dart';
import '../model/response/base_response.dart';
import '../model/response/page_response.dart';
import '../model/post_model.dart';

/// Posts. Same `Either<ApiException, T>` contract as the other services —
/// Left is the failure, Right is the value.
class PostService {
  PostService(this._api);

  final ApiClient _api;

  /// One page of posts, newest first unless the query says otherwise.
  Future<Either<ApiException, PageResponse<PostModel>>> getPage({
    int page = 0,
    int size = 10,
    String? title,
    bool? published,
  }) {
    return _guard(() async {
      final Map<String, dynamic> json = await _api.get(
        ApiConstant.posts,
        query: <String, dynamic>{
          'page': page,
          'size': size,
          'sortBy': 'createdAt',
          'direction': 'desc',
          // `?value` drops the entry when the value is null, so an unused
          // filter never reaches the query string.
          if (title != null && title.isNotEmpty) 'title': title,
          'published': ?published,
        },
      );
      return PageResponse<PostModel>.fromJson(json, PostModel.fromJson);
    });
  }

  Future<Either<ApiException, PostModel>> getById(int id) {
    return _guard(
      () async => _unwrap(await _api.get(ApiConstant.postById(id))),
    );
  }

  /// The author is taken from the token server-side — nothing to pass here.
  Future<Either<ApiException, PostModel>> create({
    required String title,
    String? content,
    bool published = true,
  }) {
    return _guard(() async {
      return _unwrap(
        await _api.post(
          ApiConstant.posts,
          body: <String, dynamic>{
            'title': title,
            if (content != null && content.isNotEmpty) 'content': content,
            'published': published,
          },
        ),
      );
    });
  }

  /// Null fields keep their stored value, so this doubles as "toggle publish".
  Future<Either<ApiException, PostModel>> update(
    int id, {
    String? title,
    String? content,
    bool? published,
  }) {
    return _guard(() async {
      return _unwrap(
        await _api.put(
          ApiConstant.postById(id),
          body: <String, dynamic>{
            // Null means "leave it alone", and the backend's mapper ignores
            // absent fields — so omitting is exactly the right wire format.
            'title': ?title,
            'content': ?content,
            'published': ?published,
          },
        ),
      );
    });
  }

  /// The backend refuses this with 400 unless the caller wrote the post.
  Future<Either<ApiException, void>> delete(int id) {
    return _guard(() async => _api.delete(ApiConstant.postById(id)));
  }

  Future<Either<ApiException, PostModel>> uploadImage(int id, String filePath) {
    return _guard(() async {
      return _unwrap(
        await _api.upload(ApiConstant.postImage(id), filePath: filePath),
      );
    });
  }

  Future<Either<ApiException, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right<ApiException, T>(await body());
    } on ApiException catch (e) {
      return Left<ApiException, T>(e);
    }
  }

  PostModel _unwrap(Map<String, dynamic> json) =>
      BaseResponse<PostModel>.fromJson(json, PostModel.fromJson).data!;
}
