import 'dart:async';

import 'request/authorization_request.dart';
import 'model/config.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';

class DesktopRequestCode {
  final Config _config;
  final AuthorizationRequest _authorizationRequest;
  final _redirectUriHost;
  String? _code;

  DesktopRequestCode(Config config)
      : _config = config,
        _authorizationRequest = AuthorizationRequest(config),
        _redirectUriHost = Uri.parse(config.redirectUri).host;

  Future<String?> requestCode() async {
    _code = null;
    final urlParams = _constructUrlParams();
    final launchUri = Uri.parse('${_authorizationRequest.url}?$urlParams');
    final webView = await WebviewWindow.create();

    final timer = Future.delayed(Duration(minutes: 1));

    final codeCompleter = Completer<String?>();

    webView.addOnUrlRequestCallback((url) {
      final encoded = Uri.parse(url);
      if (encoded.hasQuery && encoded.queryParameters['code'] != null) {
        _code = encoded.queryParameters['code'];
        codeCompleter.complete(_code);
      }
      // TODO: Handle error query params etc
    });
    webView.launch(launchUri.toString());

    await Future.any([codeCompleter.future, timer]);

    webView.close();

    return _code;
  }

  Future<void> clearCookies() async {
    await WebviewWindow.clearAll();
  }

  String _constructUrlParams() => _mapToQueryParams(
      _authorizationRequest.parameters, _config.customParameters);

  String _mapToQueryParams(
      Map<String, String> params, Map<String, String> customParams) {
    final queryParams = <String>[];

    params.forEach((String key, String value) =>
        queryParams.add('$key=${Uri.encodeQueryComponent(value)}'));

    customParams.forEach((String key, String value) =>
        queryParams.add('$key=${Uri.encodeQueryComponent(value)}'));
    return queryParams.join('&');
  }
}
