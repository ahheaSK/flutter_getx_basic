import 'package:either_dart/either.dart';

import '../../constant/api_constant.dart';
import '../../core/util/api_client.dart';
import '../../core/util/api_exception.dart';
import '../../core/util/token_storage.dart';
import '../model/request/auth_request.dart';
import '../model/response/auth_response.dart';
import '../model/response/base_response.dart';
import '../model/user_model.dart';

/// Login, register, logout.
///
/// Every call returns `Either<ApiException, T>` instead of throwing:
/// **Left = the failure, Right = the value** (the mnemonic is that "right" is
/// also the correct one). The caller cannot reach the value without deciding
/// what to do about the error first, which is the whole point — a forgotten
/// `try/catch` silently swallows a failure, a forgotten `fold` will not compile.
///
/// A service knows the endpoint and the model; it does not know about widgets,
/// snackbars, or navigation. Those belong to the controller.
class AuthService {
  AuthService(this._api, this._storage);

  final ApiClient _api;
  final TokenStorage _storage;

  bool get isLoggedIn => _storage.hasToken;

  String? get currentUsername => _storage.username;

  /// Exchanges credentials for a JWT and stores it for the next launch.
  Future<Either<ApiException, AuthResponse>> login(LoginRequest request) async {
    try {
      final Map<String, dynamic> json = await _api.post(
        ApiConstant.login,
        body: request.toJson(),
      );
      return Right<ApiException, AuthResponse>(await _persist(json));
    } on ApiException catch (e) {
      return Left<ApiException, AuthResponse>(e);
    }
  }

  /// Creates an account. The backend returns a token too, so the user is
  /// logged in straight away without a second call.
  Future<Either<ApiException, AuthResponse>> register(
    RegisterRequest request,
  ) async {
    try {
      final Map<String, dynamic> json = await _api.post(
        ApiConstant.register,
        body: request.toJson(),
      );
      return Right<ApiException, AuthResponse>(await _persist(json));
    } on ApiException catch (e) {
      return Left<ApiException, AuthResponse>(e);
    }
  }

  /// The caller's own profile, resolved from the token by the backend.
  Future<Either<ApiException, UserModel>> me() async {
    try {
      final Map<String, dynamic> json = await _api.get(ApiConstant.currentUser);
      final BaseResponse<UserModel> res = BaseResponse<UserModel>.fromJson(
        json,
        UserModel.fromJson,
      );
      return Right<ApiException, UserModel>(res.data!);
    } on ApiException catch (e) {
      return Left<ApiException, UserModel>(e);
    }
  }

  /// Logging out is purely local: the backend keeps no session to end, so the
  /// token simply stops being sent. It stays valid until it expires.
  Future<void> logout() => _storage.clear();

  /// Unwraps the `BaseApi` envelope and saves the token.
  Future<AuthResponse> _persist(Map<String, dynamic> json) async {
    final BaseResponse<AuthResponse> res = BaseResponse<AuthResponse>.fromJson(
      json,
      AuthResponse.fromJson,
    );
    final AuthResponse auth = res.data!;
    await _storage.save(token: auth.token, username: auth.user.username);
    return auth;
  }
}
