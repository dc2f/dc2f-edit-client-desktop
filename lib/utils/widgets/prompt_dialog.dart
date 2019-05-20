import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PromptDialog extends StatelessWidget {
  PromptDialog({Key key, @required this.title}) : super(key: key);

  final String title;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        FlatButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
        ),
      ],
    );
  }
}
