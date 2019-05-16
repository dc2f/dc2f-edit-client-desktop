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

class ContentModifications {
  ContentModifications({this.updates = const <String, dynamic>{}});

  final Map<String, dynamic> updates;

  bool get hasModifications => updates.isNotEmpty;
}

class ContentEditorBloc {
  ContentEditorBloc() {
    _editPath.add('/');
    _modifications.add(ContentModifications());
  }

  final BehaviorSubject<String> _editPath = BehaviorSubject<String>();
  final BehaviorSubject<ContentModifications> _modifications = BehaviorSubject<ContentModifications>();

  ValueObservable<String> get pathChanged => _editPath.stream;

  ValueObservable<ContentModifications> get modificationsChanged => _modifications.stream;

  String get path => _editPath.value;

  void changePath(String newPath) {
    if (!newPath.startsWith('/')) {
      newPath = '/$newPath';
    }
    _editPath.add(newPath);
    // discards changes (for now?)
    _modifications.add(ContentModifications());
  }

  void addModificationUpdate(String name, dynamic value) {
    _modifications.add(ContentModifications(updates: <String, dynamic>{
      ..._modifications.value.updates,
      name: value,
    }));
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
                              Theme(
                                data: Theme.of(context).copyWith(
//                                  focusColor: Colors.green,
//                                  highlightColor: Colors.blue,
//                                  selectedRowColor: Colors.purple,
//                                  splashColor: Colors.cyan,
//                                  backgroundColor: Colors.amber,
//                                  cardColor: Colors.deepOrange,
                                  // this looks really weird.
                                  hoverColor: Colors.transparent,
                                ),
                                child: Expanded(
                                  child: SingleChildScrollView(
                                    child: ContentProperties(
                                      reflection: snapshot.data.reflection,
                                      content: snapshot.data.content,
                                      children: snapshot.data.children,
                                      types: snapshot.data.types,
                                      onValueChanged: (String name, dynamic value) {
                                        _logger.finest('Property $name changed to $value');
                                          _contentEditorBloc.addModificationUpdate(name, value);
                                      },
                                    ),
                                  ),
                                ),
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
    final contentEditorBloc = Provider.of<ContentEditorBloc>(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
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
                      textTheme: ButtonTextTheme.primary,
                      onPressed: () {
                        Provider.of<ContentEditorBloc>(context).changePath(item.path);
                      },
                      child: Text(item.name == '' ? 'ROOT' : item.name),
                    )
                  ],
            )
            .skip(1),
        Expanded(child: Container()),
        StreamBuilder<ContentModifications>(
          stream: contentEditorBloc.modificationsChanged,
          builder: (context, snapshot) {
            _logger.finer('got modification data $snapshot');
            if (snapshot.hasData && snapshot.data.hasModifications) {
              return RaisedButton.icon(
                onPressed: () {
                  Provider.of<Deps>(context)
                      .apiService
                      .saveModifications(contentEditorBloc.path, snapshot.data.updates)
                      .then((result) {
                    if (result.unsaved.isEmpty) {
                      contentEditorBloc.changePath(contentEditorBloc.path);
                    } else {
                      _logger.warning('There have been unsaved changes. $result');
                    }
                  });
                },
                icon: Icon(Icons.save),
                label: Text('Save ${snapshot.data.updates.length} changes'),
              );
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }
}

typedef void OnPropertyChanged(String name, dynamic value);

class ContentProperties extends StatelessWidget {
  const ContentProperties({
    Key key,
    @required this.reflection,
    @required this.content,
    @required this.children,
    @required this.types,
    @required this.onValueChanged,
  }) : super(key: key);

//  final ContentDefReflect reflect;
  final ContentDefReflection reflection;
  final Map<String, dynamic> content;
  final Map<String, List<ContentDefChild>> children;
  final Map<String, ContentDefReflection> types;
  final OnPropertyChanged onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
//      shrinkWrap: false,
      children: reflection.properties.map((prop) {
        if (prop.kind == ContentDefKind.Primitive) {
          final dynamic value = content[prop.name];
          return PrimitiveContentProperty(
            prop: prop,
            initialValue: value,
            onValueChanged: (dynamic val) {
//              content[prop.name] = val;
              _logger.finest('Property for ${prop.name} changed to $val');
              onValueChanged(prop.name, val);
            },
          );
        }
        return ExpansionTile(
          key: PageStorageKey(prop.name),
          leading: Icon(Icons.subdirectory_arrow_right),
          title: Text('${prop.name} (${prop.kind})'),
          backgroundColor: Colors.white,
          children: <Widget>[
            ..._propertyDetails(prop, context),
          ],
        );
      }).toList(),
    );
  }

  Widget _debug(ContentDefPropertyReflection prop, BuildContext context) => ListTile(
        leading: Icon(Icons.bug_report),
        title: Text(
          'Deeebug. ${prop.toJson()}',
          style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 0.75, color: Colors.black38),
        ),
      );

  List<Widget> _propertyDetails(ContentDefPropertyReflection prop, BuildContext context) {
    if (prop.kind == ContentDefKind.Nested) {
      final children = this.children[prop.name];
      if (children != null) {
        return children.map((child) {
          return ListTile(
            leading: Icon(Icons.link),
            title: Text('${child.path}'),
            onTap: () {
              Provider.of<ContentEditorBloc>(context).changePath(child.path);
            },
          );
        })?.toList();
      } else {
        final dynamic subContent = content[prop.name];
        if (subContent is Map) {
          final content = subContent.cast<String, dynamic>();
          final subReflection = types[prop.baseType];
          return [
            FutureBuilder<ContentDefReflection>(
              initialData: subReflection,
              future: subReflection != null ? null : Provider.of<Deps>(context).apiService.reflectType(prop.baseType),
              builder: (context, snapshot) => !snapshot.hasData
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.green, width: 4))),
                      child: ContentProperties(
                        reflection: snapshot.data,
                        content: content,
                        children: {},
                        types: types,
                        onValueChanged: (String name, dynamic val) {
                          content[name] = val;
                          onValueChanged(prop.name, content);
                        },
                      ),
                    ),
            ),
          ];
        } else {
          // TODO allow to create?
          return [_debug(prop, context)];
        }
      }
    } else if (prop.kind == ContentDefKind.Parsable) {
      final content = children[prop.name]?.first?.rawContent;
      _logger.fine('text content: ($content)');
      return [
        TextField(
          // workaround: add key, otherwise it seems the scrolling of the ListView is confused
          // with the scrolling of the text field.
          key: PageStorageKey('${prop.name}/${DateTime.now()}'),
          decoration: InputDecoration(
            helperText: '${prop.parsableHint}',
          ),
          controller: TextEditingController(text: content ?? ''),
          onChanged: (value) {
            _logger.fine('got text field modification. {$value}');
            Provider.of<ContentEditorBloc>(context).addModificationUpdate(prop.name, value);
          },
          style: Theme.of(context).textTheme.body1.copyWith(fontFamily: 'RobotoMono'),
          maxLines: null,
          minLines: 14,
        ),
      ];
    }
    return [_debug(prop, context)];
  }
}

typedef void OnValueChanged(dynamic value);

class PrimitiveContentProperty extends StatefulWidget {
  const PrimitiveContentProperty({
    Key key,
    @required this.prop,
    this.initialValue,
    @required this.onValueChanged,
  }) : super(key: key);

  final ContentDefPropertyReflection prop;
  final dynamic initialValue;
  final OnValueChanged onValueChanged;

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
                  widget.onValueChanged(val);
                });
              },
            ),
          ),
        );
      case PrimitiveType.String:
        return ListTile(
          leading: Icon(Icons.edit),
          selected: false,
          enabled: false,
          title: TextField(
            // workaround: add key, otherwise it seems the scrolling of the ListView is confused
            // with the scrolling of the text field.
            key: PageStorageKey('${prop.name}/${DateTime.now()}'),
            decoration: InputDecoration(
              labelText: prop.name,
            ),
            controller: TextEditingController(text: value?.toString()),
            onChanged: (value) {
              _logger.fine('got text field modification. {$value}');
              widget.onValueChanged(value);
            },
          ),
        );
      case PrimitiveType.ZonedDateTime:
        return ListTile(
          leading: Icon(Icons.calendar_today),
          selected: false,
          title: Text(prop.name + ': ' + (value == null ? 'Not set' : '$value')),
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
