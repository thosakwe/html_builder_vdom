import 'dart:html' hide Node;
import 'package:html_builder/elements.dart';
import 'package:html_builder/html_builder.dart';
import 'package:html_builder_vdom/html_builder_vdom.dart';

main() {
  var state = new State();
  var $app = querySelector('#app') as HtmlElement;
  var $text = querySelector('#text') as InputElement;
  var renderer = new DomRenderer($app);
  renderer.render(todoApp(state));

  document.body.onClick.listen((_) {
    if ($text.value.isNotEmpty) {
      state = new State()
        ..todos.addAll(state.todos)
        ..todos.add($text.value);
      $text.value = '';
      renderer.renderNode($app, todoApp(state));
    }
  });
}

Node todoApp(State state) {
  return div(c: [
    h1(c: [text('Todos (${state.todos.length})')]),
    ul(c: state.todos.map((todo) => li(c: [text(todo)])))
  ]);
}

class State {
  final List<String> todos = [];
}
