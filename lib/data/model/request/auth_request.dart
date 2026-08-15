/// Body for `POST /api/auth/login`.
class LoginRequest {
  LoginRequest({required this.username, required this.password});

  final String username;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'username': username,
    'password': password,
  };
}

/// Body for `POST /api/auth/register`.
///
/// `nickName` is optional — omit it and the backend generates one.
class RegisterRequest {
  RegisterRequest({
    required this.username,
    required this.password,
    this.nickName,
  });

  final String username;
  final String password;
  final String? nickName;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'username': username,
    'password': password,
    if (nickName != null && nickName!.isNotEmpty) 'nickName': nickName,
  };
}
