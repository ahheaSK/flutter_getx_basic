/// Spacing, radius and size tokens.
///
/// Using a fixed scale instead of arbitrary numbers is what keeps unrelated
/// screens looking like the same app.
class AppDimen {
  const AppDimen._();

  // --- Spacing scale (multiples of 4) ---
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // --- Corner radius ---
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  // --- Component sizes ---
  static const double buttonHeight = 50;
  static const double avatarSm = 44;
  static const double avatarLg = 96;
  static const double iconMd = 20;
}
