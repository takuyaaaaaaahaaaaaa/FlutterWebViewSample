import 'dart:async';
import 'dart:core';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CookieTestPage(),
    );
  }
}

class CookieTestPage extends StatefulWidget {
  @override
  _CookieTestPageState createState() => _CookieTestPageState();
}

class _CookieTestPageState extends State<CookieTestPage> {
  late InAppWebViewController _webViewController;
  final CookieManager _cookieManager = CookieManager.instance();
  final _url = "https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies";
  final _domain = "developer.mozilla.org";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InAppWebView Cookie Test'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _webViewController.reload();
        },
        child: InAppWebView(
          onWebViewCreated: (controller) async {
            _webViewController = controller;
            await _setAndGetCookie();
            await controller.loadUrl(
              urlRequest: URLRequest(url: WebUri(_url)),
            );
          },
        ),
      ),
    );
  }

  Future<void> _setAndGetCookie() async {
    // Log the current UTC time
    final nowUtc = DateTime.now().toUtc();
    developer.log('【Cookie Test】Current UTC Time: $nowUtc');

    // Initialize cookies by deleting all existing cookies
    await _cookieManager.deleteAllCookies();
    developer.log('【Cookie Test】All cookies have been deleted.');

    // Get cookies before setting a new one and log the result
    final cookiesBeforeSet = await _cookieManager.getCookies(
      url: WebUri(_domain),
    );
    developer.log('【Cookie Test】Cookies before setting: $cookiesBeforeSet');

    // Set the expiration date for 30 minutes from now
    final expiresDate =
        DateTime.now().add(const Duration(minutes: 30)).millisecondsSinceEpoch;
    developer.log(
        '【Cookie Test】Expiration date (milliseconds since epoch): $expiresDate');

    // Set a new cookie
    await _cookieManager.setCookie(
      url: WebUri(_url),
      name: "testCookie",
      domain: _domain,
      value: "12345",
      expiresDate: expiresDate,
    );
    developer.log('【Cookie Test】Cookie has been set.');

    // Get cookies after setting the new one and log the result
    final cookies = await _cookieManager.getCookies(
      url: WebUri(_url),
    );
    developer.log('【Cookie Test】Cookies after setting: $cookies');
  }
}
