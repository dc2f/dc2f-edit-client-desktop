import 'package:dc2f_edit_client_desktop/service/api/dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../deps.dart';

final _logger = Logger('content_editor');

class ContentEditor extends StatefulWidget {
  @override
  _ContentEditorState createState() => _ContentEditorState();
}

class _ContentEditorState extends State<ContentEditor> {
  final TextEditingController _pathController = TextEditingController(text: '/');

  Future<ContentDefReflect> _loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(),
                  controller: _pathController,
                ),
              ),
              RaisedButton(
                child: const Text('Load'),
                onPressed: () {
                  setState(() {
                    _loading = Provider.of<Deps>(context).apiService.reflectContentPath(_pathController.text);
                  });
                },
              )
            ],
          ),
          FutureBuilder<ContentDefReflect>(
            future: _loading,
            builder: (context, snapshot) {
              _logger.finer('snapshot changed to $snapshot');
              if (snapshot.connectionState == ConnectionState.none) {
                return Container();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return ContentProperties(
                  reflect: snapshot.data,
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('error: ${snapshot.error}'));
              }
              _logger.shout('Invalid snapshot state $snapshot');
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}

class ContentProperties extends StatelessWidget {
  const ContentProperties({Key key, this.reflect}) : super(key: key);

  final ContentDefReflect reflect;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        shrinkWrap: false,
        children: reflect.reflection.properties.map((prop) {
          if (prop.kind == ContentDefKind.Primitive) {
            final dynamic value = reflect.content[prop.name];
            if (prop.type == PrimitiveType.Boolean) {
              return CheckboxListTile(
                title: Text('${prop.name}'),
                value: true,
                onChanged: (val) {},
              );
            } else if (prop.type == PrimitiveType.String) {
              return ListTile(
                title: TextField(
                  decoration: InputDecoration(
                    labelText: prop.name,
                  ),
                  controller: TextEditingController(text: value?.toString()),
                ),
              );
            }
          }
          return ExpansionTile(
            title: Text('${prop.name} (${prop.kind})'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.bug_report),
                title: Text('Deeebug. ${prop.toJson()}'),
              ),
              ..._propertyDetails(prop),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _propertyDetails(ContentDefPropertyReflection prop) {
    if (prop.kind == ContentDefKind.Nested) {
      return reflect.children[prop.name]?.map((child) {
            return ListTile(
              leading: Icon(Icons.subdirectory_arrow_right),
              title: Text('${child.path}'),
            );
          })?.toList() ??
          [];
    }
    return [
      ListTile(
        title: Text('lorem'),
      ),
    ];
    return [];
  }
}
