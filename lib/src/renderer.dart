import 'dart:html' hide Node;
import 'package:html_builder/html_builder.dart';

class DomRenderer extends Renderer<HtmlElement> {
  DomRenderState _root;
  final Map<int, DomRenderState> _elements = {};

  final HtmlElement target;

  DomRenderer(this.target);

  static const String ID = 'data-vdom-id';

  static String joinList(Iterable iterable) => iterable.join(' ');

  static String joinMap(Map<String, dynamic> map) =>
      map.keys.fold<String>('', (out, k) {
        var v = map[k];
        return out + '$k: $v; ';
      }).trim();

  void applyAttribute(HtmlElement target, String k, v) {
    if (v == false || v == null)
      return;
    else if (v == true) {
      target.attributes[k] = k;
    } else if (v is String) {
      target.attributes[k] = v;
    } else if (v is num) {
      target.attributes[k] = v.toString();
    } else if (v is List) {
      target.attributes[k] = joinList(v);
    } else if (v is Map) {
      target.attributes[k] = joinMap(v);
    } else
      throw new UnsupportedError('$v is not a valid attribute for key "$k".');
  }

  DomRenderState resolveNodeToState(int id, Node node, [HtmlElement target]) {
    return _elements.putIfAbsent(id, () {
      var $el = target ?? document.createElement(node.tagName);
      $el.attributes[ID] = id.toString();
      return new DomRenderState($el, node);
    });
  }

  @override
  HtmlElement render(Node rootNode) {
    var root = _root ??= resolveNodeToState(_elements.length, rootNode, target);
    renderNode(target, rootNode, root);
    return target;
  }

  DomRenderState renderNode(HtmlElement target, Node node,
      [DomRenderState renderState]) {
    var state = renderState;

    if (renderState == null) {
      int id;

      if (target.attributes.containsKey(ID))
        id = int.parse(target.attributes[ID]);
      else
        id = _elements.length;
      state = resolveNodeToState(id, node);
    }

    if (state.fresh) {
      return renderFresh(state);
    }

    return renderDiffed(state, node);
  }

  DomRenderState renderFresh(DomRenderState state) {
    // Apply attributes
    state.node.attributes.forEach((k, v) => applyAttribute(state.target, k, v));

    // Collect text
    var text = state.node.children
        .where((n) => n is TextNode)
        .map<String>((TextNode n) => n.text)
        .join();

    state.target.text = text;

    // Add children
    state.node.children.forEach((child) {
      if (child is TextNode) {
        return;
      } else {
        var childState = renderFresh(resolveNodeToState(child.hashCode, child));
        state.target.append(childState.target);
        state.children.add(childState);
      }
    });

    state._fresh = false;
    return state;
  }

  DomRenderState renderDiffed(DomRenderState state, Node newNode) {
    // Apply attributes
    newNode.attributes.forEach((k, v) {
      if (v != state.node.attributes[k]) {
        applyAttribute(state.target, k, v);
      }
    });

    // Collect text
    var text = newNode.children
        .where((n) => n is TextNode)
        .map<String>((TextNode n) => n.text)
        .join();
    if (text.isNotEmpty) state.target.text = text;

    // Diff children in memory
    int i;

    for (i = 0;
        i < state.node.children.length && i < newNode.children.length;
        i++) {
      var newChild = newNode.children[i];
      if (newChild is TextNode) {
        continue;
      }

      var oldChild = state.node.children[i];

      // Resolve a state to diff against
      int oldStateId;
      HtmlElement oldElement;
      DomRenderState oldState;

      if (state.target.children.length > i) {
        var $el = state.target.children[i];
        if ($el.tagName == oldChild.tagName.toUpperCase() && $el.attributes.containsKey(ID)) {
          oldStateId = int.parse($el.attributes[ID]);
          oldElement = $el;
        }
      } else
        oldStateId = oldChild.hashCode;

      if (oldElement == null) {
        oldState = _elements[oldStateId];
        oldElement = oldState?.target;
      } else oldState = _elements[oldStateId];

      // If there was a previous element, diff into that element
      if (oldElement != null) {
        renderDiffed(oldState, newChild);
      } else {
        // Otherwise... is this a new element?
        // TODO: New element
        throw 'Not yet supported: new elements in diff...';
      }
    }

    return state;
  }
}

class DomRenderState {
  bool _fresh = true;
  Node _node;
  final HtmlElement target;
  final List<DomRenderState> children = [];

  DomRenderState(this.target, this._node);

  bool get fresh => _fresh;

  Node get node => _node;
}
