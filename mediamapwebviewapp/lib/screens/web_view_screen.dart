import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  static const String _homeURL = "https://cleantalk.org";
  late InAppWebViewController _controllerWeb;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  bool _webIsLoading = false;
  bool _webCanGoBack = false;
  bool _webCanGoForward = false;
  String _webUrl = '';

  final TextEditingController _controllerEdit = TextEditingController();

  void _setVariables() {
    _controllerWeb.getUrl().then((value) {
      String _newUrl = value.toString();
      if (_newUrl != _webUrl) {
        setState(() {
          _webUrl = _newUrl;
          _controllerEdit.text = _newUrl;
        });
      }
    });
    _controllerWeb.canGoBack().then((value) {
      if (value != _webCanGoBack) {
        setState(() {
          _webCanGoBack = value;
        });
      }
    });
    _controllerWeb.canGoForward().then((value) {
      if (value != _webCanGoForward) {
        setState(() {
          _webCanGoForward = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_webUrl != '' ? _webUrl : 'WebView Screen'),
      ),
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  _controllerWeb.loadUrl(
                      urlRequest: URLRequest(url: Uri.parse(_homeURL)));
                },
                icon: const Icon(Icons.home),
              ),
              IconButton(
                onPressed: _webCanGoBack
                    ? () {
                        _controllerWeb.goBack();
                      }
                    : null,
                icon: const Icon(Icons.arrow_back),
              ),
              IconButton(
                onPressed: _webCanGoForward
                    ? () {
                        _controllerWeb.goForward();
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward),
              ),
              _webIsLoading
                  ? IconButton(
                      onPressed: () {
                        _controllerWeb.stopLoading();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : IconButton(
                      onPressed: () {
                        _controllerWeb.reload();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
              Expanded(
                child: TextField(
                  controller: _controllerEdit,
                  onSubmitted: (s) {
                    _controllerWeb.loadUrl(
                        urlRequest: URLRequest(url: Uri.parse(s)));
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      //borderSide: BorderSide(width: 1.0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        _controllerWeb.loadUrl(
                            urlRequest: URLRequest(
                                url: Uri.parse(_controllerEdit.text)));
                      },
                      child: const Icon(
                        Icons.forward,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: InAppWebView(
              onLoadStart: (controller, uri) {
                setState(() {
                  _webIsLoading = true;
                });
                _setVariables();
              },
              onLoadError: (controller, uri, errorCode, errorText) {
                setState(() {
                  _webIsLoading = false;
                });
                _setVariables();
              },
              onLoadStop: (controller, uri) {
                setState(() {
                  _webIsLoading = false;
                });
                _setVariables();
              },
              onWebViewCreated: (controller) {
                _controllerWeb = controller;
                _setVariables();
              },
              initialOptions: options,
              //initialUrlRequest: URLRequest(url: Uri.parse(_homeURL)),
            ),
          )
        ],
      ),
    );
  }
}