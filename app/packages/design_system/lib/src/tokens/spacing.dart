/// Spacing tokens, multiples of 4. See docs/DESIGN.md §3.
abstract final class GxSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Horizontal page padding.
  static const double page = md;

  /// Minimum touch target edge (WCAG / platform guidelines).
  static const double minTouchTarget = 44;

  /// Standard button height.
  static const double buttonHeight = 48;
}

/// Maximum content widths so wide (web, tablet) screens stay readable.
abstract final class GxLayout {
  /// Forms such as sign-in.
  static const double formMaxWidth = 440;

  /// Reading content such as a profile or a list.
  static const double contentMaxWidth = 720;

  /// Home, post and comment pages (post cards and the home sections).
  static const double feedMaxWidth = 560;

  /// Dashboards and data tables (admin panel).
  static const double dashboardMaxWidth = 1200;

  /// A story card's preview (9:16); the shared picture is three times this.
  static const double storyCardWidth = 360;

  /// Side navigation of the admin panel.
  static const double sidebarWidth = 256;

  /// From this width on, layouts show side navigation and multi-column content.
  static const double wideBreakpoint = 960;
}
