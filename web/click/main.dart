import 'dart:html' hide Node;
import 'package:html_builder/elements.dart';
import 'package:html_builder/html_builder.dart';
import 'package:html_builder_vdom/html_builder_vdom.dart';

main() {
  int clickCount;
  var $app = querySelector('#app') as HtmlElement;
  var renderer = new DomRenderer($app);
  renderer.render(clickApp(clickCount = 0));

  $app.onClick.listen((_) {
    renderer.renderNode($app, clickApp(++clickCount));
  });
}

Node clickApp(int clickCount) {
  return div(p: {
    'data-clicks': clickCount
  }, c: [
    h1(c: [text('Clicked $clickCount time(s)')]),
    img(
        id: 'cookie-img',
        src: 'http://i.imgur.com/74OTDuc.png',
        width: 200,
        height: 200),
    br()
  ]);
}
