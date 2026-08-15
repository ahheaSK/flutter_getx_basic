import 'package:either_dart/either.dart';

import '../../constant/api_constant.dart';
import '../../core/util/api_client.dart';
import '../../core/util/api_exception.dart';
import '../model/response/base_response.dart';
import '../model/response/page_response.dart';
import '../model/user_model.dart';
import '../model/request/user_request.dart';

/// CRUD against `/api/users`, plus the profile image upload.
///
/// Same contract as [AuthService]: `Either<ApiException, T>` — Left is the
/// failure, Right is the value. Each method also unwraps the backend envelope,
/// so callers get a plain model: `BaseApi` → `data`, `BasePageApi` →
/// `pagination` + `data`.
class UserService {
  UserService(this._api);

  final ApiClient _api;

  /// One page of users. [filter] carries page, size, sort and the search terms.
  Future<Either<ApiException, PageResponse<UserModel>>> getPage(
    UserFilter filter,
  ) {
    return _guard(() async {
      final Map<String, dynamic> json = await _api.get(
        ApiConstant.users,
        query: filter.toQuery(),
      );
      return PageResponse<UserModel>.fromJson(json, UserModel.fromJson);
    });
  }

  Future<Either<ApiException, UserModel>> getById(int id) {
    return _guard(() async {
      return _unwrap(await _api.get(ApiConstant.userById(id)));
    });
  }

  Future<Either<ApiException, UserModel>> create(UserCreateRequest request) {
    return _guard(() async {
      return _unwrap(
        await _api.post(ApiConstant.users, body: request.toJson()),
      );
    });
  }

  Future<Either<ApiException, UserModel>> update(
    int id,
    UserUpdateRequest request,
  ) {
    return _guard(() async {
      return _unwrap(
        await _api.put(ApiConstant.userById(id), body: request.toJson()),
      );
    });
  }

  /// Soft delete — the backend stamps `deletedAt` and hides the row.
  ///
  /// Right is `void`: there is no payload, only the fact that it worked.
  Future<Either<ApiException, void>> delete(int id) {
    return _guard(() async {
      await _api.delete(ApiConstant.userById(id));
    });
  }

  /// Enable or disable login for an account.
  Future<Either<ApiException, UserModel>> setEnabled(int id, bool enabled) {
    return _guard(() async {
      return _unwrap(
        await _api.patch(
          ApiConstant.userEnabled(id),
          query: <String, dynamic>{'enabled': enabled},
        ),
      );
    });
  }

  /// Uploads a local file as the user's profile image.
  ///
  /// The returned model already carries the new `imageUrl`, so the caller can
  /// swap the avatar without re-fetching the user.
  Future<Either<ApiException, UserModel>> uploadImage(int id, String filePath) {
    return _guard(() async {
      return _unwrap(
        await _api.upload(ApiConstant.userImage(id), filePath: filePath),
      );
    });
  }

  /// Runs [body] and folds the outcome into an [Either].
  ///
  /// One place doing the try/catch keeps every method above down to the request
  /// itself — and guarantees none of them can accidentally throw at a caller
  /// that is expecting an Either.
  Future<Either<ApiException, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right<ApiException, T>(await body());
    } on ApiException catch (e) {
      return Left<ApiException, T>(e);
    }
  }

  UserModel _unwrap(Map<String, dynamic> json) {
    final BaseResponse<UserModel> res = BaseResponse<UserModel>.fromJson(
      json,
      UserModel.fromJson,
    );
    return res.data!;
  }
}
