import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/js_injections.dart';

class BullyWebView extends StatelessWidget {
  final String initialUrl;
  final Function(InAppWebViewController) onWebViewCreated;
  final Function(String, InAppWebViewController?) onUrlChanged;
  final Function(bool) onLoadingChanged;
  final Function(bool) onErrorOccurred;
  final Function(Map<String, dynamic>)? onTokenReceived;

  const BullyWebView({
    super.key,
    required this.initialUrl,
    required this.onWebViewCreated,
    required this.onUrlChanged,
    required this.onLoadingChanged,
    required this.onErrorOccurred,
    this.onTokenReceived,
  });

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(initialUrl),
      ),
      initialSettings: InAppWebViewSettings(
        userAgent: 'Mozilla/5.0 (Linux; Android) AppleWebKit/537.36 BullyAppMobile/1.0',
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        cacheMode: CacheMode.LOAD_DEFAULT,
        thirdPartyCookiesEnabled: true,
        sharedCookiesEnabled: true,
        supportMultipleWindows: false,
        javaScriptCanOpenWindowsAutomatically: false,
        allowsBackForwardNavigationGestures: true,
        transparentBackground: false,
        disableDefaultErrorPage: true,
        overScrollMode: OverScrollMode.NEVER,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        useHybridComposition: true,
        mediaPlaybackRequiresUserGesture: false,
        useOnDownloadStart: true,
      ),
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(
          source: JSInjections.hideWebFooter,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: true,
        ),
      ]),
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onDownloadStartRequest: (controller, downloadRequest) async {
        if (await canLaunchUrl(downloadRequest.url)) {
          await launchUrl(downloadRequest.url,
              mode: LaunchMode.externalApplication);
        }
      },
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
          handlerName: 'onTokenReceived',
          callback: (args) {
            if (args.isNotEmpty && args[0] is Map) {
              final Map<String, dynamic> tokenData = Map<String, dynamic>.from(args[0] as Map);
              onTokenReceived?.call(tokenData);
            }
          },
        );
        onWebViewCreated(controller);
      },
      onUpdateVisitedHistory: (controller, url, isReload) {
        if (url != null) {
          onUrlChanged(url.toString(), controller);
        }
      },
      onLoadStart: (controller, url) {
        if (url != null) {
          onErrorOccurred(false);
          onLoadingChanged(true);
          onUrlChanged(url.toString(), controller);
        }
      },
      onLoadStop: (controller, url) async {
        if (url != null) {
          onLoadingChanged(false);
          onUrlChanged(url.toString(), controller);
        }

        // Meta Viewport Injection
        await controller.evaluateJavascript(source: JSInjections.metaViewport);

        // Anti "Descargar App" Injection
        await controller.evaluateJavascript(source: JSInjections.antiDownloadApp);

        // Ocultar Footer Web del sitio
        await controller.evaluateJavascript(source: JSInjections.hideWebFooter);
      },
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame ?? true) {
          onErrorOccurred(true);
          onLoadingChanged(false);
        }
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final uri = navigationAction.request.url;
        if (uri == null) return NavigationActionPolicy.ALLOW;

        final String urlStr = uri.toString();
        final String lowerUrl = urlStr.toLowerCase();
        final String host = uri.host.toLowerCase();

        // Bloqueo de YouTube
        if (lowerUrl.startsWith('https://www.youtube.com/')) {
          return NavigationActionPolicy.CANCEL;
        }

        // DETECCIÓN DE DESCARGAS
        final bool isDownloadableFile = lowerUrl.endsWith('.pdf') ||
            lowerUrl.endsWith('.jpg') ||
            lowerUrl.endsWith('.jpeg') ||
            lowerUrl.endsWith('.png') ||
            lowerUrl.endsWith('.zip') ||
            lowerUrl.contains('download');

        if (isDownloadableFile) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationActionPolicy.CANCEL;
          }
        }

        // Permitir rutas de la app y dominios de OAuth (Google, Facebook, Apple)
        const String domain = "bullyapp.com.pe";
        final bool isOAuthDomain = host.contains("google.com") ||
            host.contains("accounts.google") ||
            host.contains("facebook.com") ||
            host.contains("facebook.net") ||
            host.contains("appleid.apple.com");

        final bool isAppDomain = host.isEmpty || host.contains(domain) || lowerUrl.startsWith('about:');

        // Redirigir a navegador externo solo si es un enlace ajeno a la app y NO es OAuth
        if (!isAppDomain && !isOAuthDomain) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationActionPolicy.CANCEL;
          }
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}
