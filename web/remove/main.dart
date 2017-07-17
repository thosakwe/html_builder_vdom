import 'dart:collection';
import 'dart:html' hide Node;
import 'package:html_builder/elements.dart';
import 'package:html_builder/html_builder.dart';
import 'package:html_builder_vdom/html_builder_vdom.dart';

main() {
  var q = new Queue<String>.from(
      'ask not what your country can do for you but what you can do for your country'
          .split(' '));
  var $app = querySelector('#app');
  var renderer = new DomRenderer($app);
  renderer.render(quoteApp(q));

  document.body.onClick.listen((_) {
    if (q.isNotEmpty) {
      q.removeFirst();
      renderer.renderNode($app, quoteApp(q));
    }
  });
}

Node quoteApp(Queue<String> words) {
  return div(c: [
    h1(c: [text('Words: (${words.length})')]),
    br(),
    ul(c: words.map((word) => li(c: [text(word)])))
  ]);
}
