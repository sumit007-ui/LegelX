// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

final Set<String> _registeredViews = {};

void registerWebView(String viewType, String htmlContent) {
  if (_registeredViews.contains(viewType)) return;
  _registeredViews.add(viewType);

  ui.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.setAttribute('srcdoc', htmlContent);
      iframe.style.border = 'none';
      iframe.style.width = '100%';
      iframe.style.height = '100%';
      return iframe;
    },
  );
}
