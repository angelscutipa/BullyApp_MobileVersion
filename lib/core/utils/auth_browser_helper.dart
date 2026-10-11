import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AuthChromeSafariBrowser extends ChromeSafariBrowser {
  final VoidCallback? onClosedCallback;

  AuthChromeSafariBrowser({this.onClosedCallback});

  @override
  void onClosed() {
    onClosedCallback?.call();
    super.onClosed();
  }
}

class AuthBrowserHelper {
  static final AuthBrowserHelper _instance = AuthBrowserHelper._internal();
  factory AuthBrowserHelper() => _instance;
  AuthBrowserHelper._internal();

  AuthChromeSafariBrowser? _browser;

  Future<void> openGoogleAuth({
    required WebUri url,
    required VoidCallback onAuthCompleted,
  }) async {
    _browser = AuthChromeSafariBrowser(
      onClosedCallback: onAuthCompleted,
    );

    await _browser!.open(
      url: url,
      settings: ChromeSafariBrowserSettings(
        shareState: CustomTabsShareState.SHARE_STATE_OFF,
        barCollapsingEnabled: true,
        dismissButtonStyle: DismissButtonStyle.CLOSE,
        showTitle: true,
      ),
    );
  }

  Future<void> closeAuthBrowser() async {
    if (_browser != null) {
      try {
        await _browser!.close();
      } catch (e) {
        debugPrint("Error closing AuthChromeSafariBrowser: $e");
      }
      _browser = null;
    }
  }
}
