/// Body for `POST /api/users` — creating a user as an admin.
class UserCreateRequest {
  UserCreateRequest({
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

/// Body for `PUT /api/users/{id}`.
///
/// There is no password field: the backend keeps credential changes on their
/// own endpoint. Fields left null keep their stored value.
class UserUpdateRequest {
  UserUpdateRequest({required this.username, this.nickName});

  final String username;
  final String? nickName;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'username': username,
    if (nickName != null) 'nickName': nickName,
  };
}

/// Query parameters for `GET /api/users`.
///
/// Only non-empty values are sent, which is what makes the backend's optional
/// predicates drop out of the WHERE clause.
class UserFilter {
  UserFilter({
    this.username,
    this.nickName,
    this.enabled,
    this.page = 0,
    this.size = 10,
    this.sortBy = 'createdAt',
    this.direction = 'desc',
  });

  final String? username;
  final String? nickName;
  final bool? enabled;
  final int page;
  final int size;

  /// Must be one the backend allows: id, username, nickName, enabled,
  /// createdAt, updatedAt. Anything else silently falls back to username.
  final String sortBy;

  /// `asc` or `desc`.
  final String direction;

  Map<String, dynamic> toQuery() => <String, dynamic>{
    'page': page,
    'size': size,
    'sortBy': sortBy,
    'direction': direction,
    if (username != null && username!.isNotEmpty) 'username': username,
    if (nickName != null && nickName!.isNotEmpty) 'nickName': nickName,
    if (enabled != null) 'enabled': enabled,
  };

  UserFilter copyWith({
    String? username,
    bool? enabled,
    int? page,
    String? sortBy,
    String? direction,
  }) => UserFilter(
    username: username ?? this.username,
    nickName: nickName,
    enabled: enabled ?? this.enabled,
    page: page ?? this.page,
    size: size,
    sortBy: sortBy ?? this.sortBy,
    direction: direction ?? this.direction,
  );
}
