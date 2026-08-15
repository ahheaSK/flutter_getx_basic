/// Route names, as constants so a typo is a compile error rather than a
/// blank screen at runtime.
class AppRoute {
  const AppRoute._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  /// The tabbed shell — what login and splash land on.
  static const String main = '/main';
  static const String userList = '/users';
  static const String postForm = '/posts/form';
  static const String userForm = '/users/form';
  static const String userDetail = '/users/detail';
}
