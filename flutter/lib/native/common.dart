import 'dart:io';

final isAndroid_ = Platform.isAndroid;
final isIOS_ = Platform.isIOS;
final isWindows_ = Platform.isWindows;
final isMacOS_ = Platform.isMacOS;
final isLinux_ = Platform.isLinux;
final isWeb_ = false;
final isWebDesktop_ = false;

final isDesktop_ = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

final isWebOnWindows_ = false;
final isWebOnLinux_ = false;
final isWebOnMacOS_ = false;

/// Whether the Linux windows use the window manager's own title bar, border
/// and shadow instead of RustDesk's frameless window with a drawn title bar.
///
/// `RUSTDESK_TITLE_BAR=system|custom` forces either style. Otherwise the
/// system title bar is used on KDE Plasma, where KWin draws native
/// decorations and shadows for normal windows.
///
/// Keep in sync with `use_system_title_bar()` in `linux/my_application.cc`.
final linuxUseSystemTitleBar_ = Platform.isLinux && _linuxUseSystemTitleBar();

bool _linuxUseSystemTitleBar() {
  final forced =
      (Platform.environment['RUSTDESK_TITLE_BAR'] ?? '').toLowerCase();
  if (forced == 'system') return true;
  if (forced == 'custom') return false;
  final desktop = Platform.environment['XDG_CURRENT_DESKTOP'] ?? '';
  return desktop.toUpperCase().split(':').contains('KDE');
}
