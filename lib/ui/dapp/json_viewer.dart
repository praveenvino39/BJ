import 'package:flutter/material.dart';

class JsonViewer extends StatefulWidget {
  final dynamic json;

  const JsonViewer(this.json, {super.key});

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _buildRoot(widget.json),
    );
  }

  /// Build without showing the top key
  List<Widget> _buildRoot(dynamic node) {
    if (node is Map) {
      return node.keys.map((key) {
        return _buildNode(node[key], title: key);
      }).toList();
    }

    if (node is List) {
      return [
        for (int i = 0; i < node.length; i++) _buildNode(node[i], title: "[$i]")
      ];
    }

    return [
      ListTile(
        title: Text(node.toString()),
      )
    ];
  }

  Widget _buildNode(dynamic node, {required String title}) {
    if (node is Map) {
      return Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(title),
          children: node.keys.map((key) {
            return _buildNode(node[key], title: key);
          }).toList(),
        ),
      );
    }

    if (node is List) {
      return Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(title),
          children: [
            for (int i = 0; i < node.length; i++)
              _buildNode(node[i], title: "[$i]")
          ],
        ),
      );
    }

    return ListTile(
      title: Text(title),
      subtitle: Text(node.toString()),
    );
  }
}
