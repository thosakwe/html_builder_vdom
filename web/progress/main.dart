import 'dart:html' hide Node;
import 'package:html_builder/elements.dart';
import 'package:html_builder/html_builder.dart';
import 'package:html_builder_vdom/html_builder_vdom.dart';

main() {
  bool up = true;
  int progress;
  var $app = querySelector('#app') as HtmlElement;
  var renderer = new DomRenderer($app);
  renderer.render(clickApp(progress = 0));

  $app.onClick.listen((_) {
    if (progress <= 0)
      up = true;
    else if (progress >= 100) up = false;

    var p = up ? (progress += 10) : (progress -= 10);
    renderer.renderNode($app, clickApp(p));
  });
}

Node clickApp(int value) {
  return div(c: [
    h1(p: {
      'style': {'-webkit-tap-highlight-color': 'red'}
    }, c: [
      text('Click to change progress')
    ]),
    br(),
    progress(value: value, max: 100)
  ]);
}
