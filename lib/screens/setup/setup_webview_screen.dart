import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:ceras/constants/route_paths.dart' as routes;

class MyWebView extends StatelessWidget {
  final String title;
  final String selectedUrl;
  // final Function() onSuccess;
  // final Function() onFailure;

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  MyWebView({
    @required this.title,
    @required this.selectedUrl,
    // @required this.onSuccess,
    // @required this.onFailure,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: WebView(
          initialUrl: selectedUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
            onPageStarted: (String url) {
              if(url.startsWith('https://happy-developer.com')) {
                // https://happy-developer.com/?user_id=8f4274ca-aa9e-458f-8b8f-93951d9b01c5&resource=FITBIT&reference_id=1234&lan=en#_=_

                var uri = Uri.dataFromString(url); //converts string to a uri
                Map<String, String> params = uri.queryParameters; // query parameters automatically populated
                var reference_id = params['reference_id']; // return value of parameter "param1" from uri
                var resource = params['resource'];
                print(reference_id + resource);
                Navigator.of(context).pushNamed(
                  routes.SetupConnectedRoute,
                  arguments: {
                    'deviceData': null,
                    'displayImage': "https://tryterra.co/terra_api_logo.webp",
                  },
                );
              } else if(url.startsWith('https://sad-developer.com')) {
                Navigator.of(context).pushNamed(
                  routes.UnabletoconnectRoute
                );
              }
            },
        ));
  }
}