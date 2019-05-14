import 'package:dc2f_edit_client_desktop/service/api/dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import '../deps.dart';

final _logger = Logger('content_editor');

class ContentEditorBloc {
  ContentEditorBloc() {
    _editPath.add('/');
  }

  final BehaviorSubject<String> _editPath = BehaviorSubject<String>();

  ValueObservable<String> get pathChanged => _editPath.stream;

  void changePath(String newPath) {
    if (!newPath.startsWith('/')) {
      newPath = '/$newPath';
    }
    _editPath.add(newPath);
  }
}

class PathEditor extends StatefulWidget {
  const PathEditor({Key key, this.initialPath}) : super(key: key);

  final String initialPath;

  @override
  _PathEditorState createState() => _PathEditorState();
}

class _PathEditorState extends State<PathEditor> {
  TextEditingController _pathController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pathController.text = widget.initialPath;
  }

  @override
  void didUpdateWidget(PathEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPath != widget.initialPath) {
      _pathController.text = widget.initialPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            decoration: InputDecoration(),
            controller: _pathController,
          ),
        ),
        const Padding(padding: EdgeInsets.only(left: 8)),
        RaisedButton(
          child: const Text('Load'),
          onPressed: () {
            Provider.of<ContentEditorBloc>(context).changePath(_pathController.text);
//            setState(() {
//              _loading = Provider.of<Deps>(context).apiService.reflectContentPath(_pathController.text);
//            });
          },
        )
      ],
    );
  }
}

class ContentEditor extends StatefulWidget {
  @override
  _ContentEditorState createState() => _ContentEditorState();
}

class _ContentEditorState extends State<ContentEditor> {
  ContentEditorBloc _contentEditorBloc;

  @override
  void initState() {
    super.initState();
    _contentEditorBloc = ContentEditorBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _contentEditorBloc,
      child: StreamBuilder<String>(
          stream: _contentEditorBloc.pathChanged,
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  PathEditor(
                    initialPath: snapshot.data,
                  ),
                  FutureBuilder<ContentDefReflect>(
                    future: Provider.of<Deps>(context).apiService.reflectContentPath(snapshot.data),
                    builder: (context, snapshot) {
                      _logger.finer('snapshot changed to $snapshot');
                      if (snapshot.connectionState == ConnectionState.none) {
                        return Container();
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData) {
                        return Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              BreadcrumbsWidget(
                                breadcrumbs: snapshot.data.breadcrumbs,
                              ),
                              ContentProperties(
                                reflect: snapshot.data,
                              ),
                            ],
                          ),
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
          }),
    );
  }
}

class BreadcrumbsWidget extends StatelessWidget {
  const BreadcrumbsWidget({Key key, @required this.breadcrumbs}) : super(key: key);

  final List<BreadcrumbsItem> breadcrumbs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.my_location,
          color: Colors.black38,
        ),
        ...breadcrumbs
            .expand(
              (item) => [
                    const Text('/'),
                    FlatButton(
                      onPressed: () {
                        Provider.of<ContentEditorBloc>(context).changePath(item.path);
                      },
                      child: Text(item.name == '' ? 'ROOT' : item.name),
                    )
                  ],
            )
            .skip(1),
      ],
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
            return PrimitiveContentProperty(
              prop: prop,
              initialValue: value,
            );
          }
          return ExpansionTile(
            key: PageStorageKey(prop.name),
            leading: Icon(Icons.subdirectory_arrow_right),
            title: Text('${prop.name} (${prop.kind})'),
            backgroundColor: Colors.white,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.bug_report),
                title: Text(
                  'Deeebug. ${prop.toJson()}',
                  style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 0.75, color: Colors.black38),
                ),
              ),
              ..._propertyDetails(prop, context),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _propertyDetails(ContentDefPropertyReflection prop, BuildContext context) {
    if (prop.kind == ContentDefKind.Nested) {
      return reflect.children[prop.name]?.map((child) {
            return ListTile(
              leading: Icon(Icons.link),
              title: Text('${child.path}'),
              onTap: () {
                Provider.of<ContentEditorBloc>(context).changePath(child.path);
              },
            );
          })?.toList() ??
          [];
    } else if (prop.kind == ContentDefKind.Parsable) {
      final content = reflect.children[prop.name]?.first?.rawContent;
      return [
        TextField(
          // workaround: add key, otherwise it seems the scrolling of the ListView is confused
          // with the scrolling of the text field.
          key: PageStorageKey('${prop.name}/${DateTime.now()}'),
          decoration: InputDecoration(
            helperText: '${prop.parsableHint}',
          ),
          controller: TextEditingController(text: content ?? ''),
          style: Theme.of(context).textTheme.body1.copyWith(fontFamily: 'RobotoMono'),
          maxLines: null,
          minLines: 10,
        ),
      ];
    }
    return [
      ListTile(
        title: Text('lorem'),
      ),
    ];
    return [];
  }
}

class PrimitiveContentProperty extends StatefulWidget {
  const PrimitiveContentProperty({Key key, this.prop, this.initialValue}) : super(key: key);

  final ContentDefPropertyReflection prop;
  final dynamic initialValue;

  @override
  _PrimitiveContentPropertyState createState() => _PrimitiveContentPropertyState();
}

class _PrimitiveContentPropertyState extends State<PrimitiveContentProperty> {
  dynamic value;
  static DateFormat isoFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final prop = widget.prop;
    switch (prop.type) {
      case PrimitiveType.Boolean:
        return Opacity(
          opacity: value == null ? 0.5 : 1,
          child: InkWell(
            onLongPress: () {
              setState(() {
                value = null;
              });
            },
            child: SwitchListTile(
              secondary: Icon(Icons.edit),
              title: Text('${prop.name}${prop.optional ? '' : ' *'}'),
              value: value as bool ?? false,
              onChanged: (val) {
                setState(() {
                  value = val;
                });
              },
            ),
          ),
        );
      case PrimitiveType.String:
        return ListTile(
          leading: Icon(Icons.edit),
          title: TextField(
            decoration: InputDecoration(
              labelText: prop.name,
            ),
            controller: TextEditingController(text: value?.toString()),
          ),
        );
      case PrimitiveType.ZonedDateTime:
        return ListTile(
          leading: Icon(Icons.calendar_today),
          title: Text(prop.name + ': ' + (value == null ? 'Not set' : '$value (${value.runtimeType})')),
          onTap: () {
            _logger.fine('opening date picker. example format ${isoFormat.format(DateTime.now())}');
            DatePicker.showDateTimePicker(
              context,
              currentTime: value == null ? DateTime.now() : isoFormat.parse(value as String),
              onConfirm: (dateTime) {
                setState(() {
                  value = isoFormat.format(dateTime);
                });
              },
            );
          },
        );
      case PrimitiveType.Unknown:
        return ListTile(
          leading: Icon(Icons.broken_image),
          title: Text('Unsupported property ${prop.name} for now. ${prop.type}.'),
        );
    }
    throw ArgumentError('Invalid property type ${prop.type}');
  }
}
