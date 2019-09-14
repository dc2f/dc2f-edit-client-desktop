import 'package:dc2f_edit_client_desktop/service/api/dto.dart';
import 'package:dc2f_edit_client_desktop/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../deps.dart';
import '../theme.dart';
import 'file_property_editor.dart';

final _logger = Logger('content_editor');

class ContentModifications {
  ContentModifications({this.updates = const <String, dynamic>{}});

  final Map<String, dynamic> updates;

  bool get hasModifications => updates.isNotEmpty;

  @override
  String toString() {
    return '{ContentModifications: updates=$updates}';
  }
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

class ContentEditorHeader extends StatelessWidget {
  const ContentEditorHeader({Key key, @required this.breadcrumbs, @required this.reflection}) : super(key: key);

  final List<BreadcrumbsItem> breadcrumbs;
  final ContentDefReflection reflection;

  @override
  Widget build(BuildContext context) {
    return BreadcrumbsWidget(
      breadcrumbs: breadcrumbs,
      trailing: <Widget>[
        Tooltip(
          message: '${reflection.type}',
          child: Text(
            'Type: ' +
                (reflection.typeIdentifier != null
                    ? '${reflection.typeIdentifier ?? ''}\n(${reflection.type.split('.').last})'
                    : reflection.type.split('.').last),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.body1.apply(heightFactor: 0.8, color: Colors.black12),
          ),
        ),
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
                              ContentEditorHeader(
                                breadcrumbs: snapshot.data.breadcrumbs,
                                reflection: snapshot.data.reflection,
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
  const BreadcrumbsWidget({Key key, @required this.breadcrumbs, this.trailing = const []}) : super(key: key);

  final List<BreadcrumbsItem> breadcrumbs;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final contentEditorBloc = Provider.of<ContentEditorBloc>(context);
    return StreamBuilder<ContentModifications>(
      stream: contentEditorBloc.modificationsChanged,
      builder: (context, snapshot) {
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
            ...trailing,
            Expanded(child: Container()),
            ...(() {
              _logger.finer('got modification data $snapshot');
              if (snapshot.hasData && snapshot.data.hasModifications) {
                return [
                  RaisedButton.icon(
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
                  ),
                ];
              } else {
                return <Widget>[];
              }
            })(),
          ],
        );
      },
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
          final dynamic defaultValue = reflection?.defaultValues[prop.name];
          return PrimitiveContentProperty(
            prop: prop,
            initialValue: value,
            defaultValue: defaultValue,
            onValueChanged: (dynamic val) {
//              content[prop.name] = val;
              _logger.finest('Property for ${prop.name} changed to $val');
              onValueChanged(prop.name, val);
            },
          );
        } else if (prop.kind == ContentDefKind.File) {
          final dynamic value = content[prop.name];
          return FilePropertyEditor(
            prop: prop,
            initialValue: value,
            onValueChanged: (dynamic val) {
              onValueChanged(prop.name, val);
            },
          );
        } else if (prop.kind == ContentDefKind.Enum) {
          assert(prop.multiValue == false);
          final value = content[prop.name] as String;
          final defaultValue = reflection.defaultValues[prop.name] as String;
          _logger.fine('Enum value: $value -- ${reflection.defaultValues}');
          return ListTile(
            leading: Icon(Icons.format_list_bulleted),
            title: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: prop.name, helperText: defaultValue != null ? 'Default: $defaultValue' : null),
              value: value ?? defaultValue,
              onChanged: (newValue) {
                onValueChanged(prop.name, newValue);
              },
              items: prop.enumValues.map((value) {
                return DropdownMenuItem(
                  child: Text(value),
                  value: value,
                );
              }).toList(),
            ),
          );
        }
        return ExpansionTile(
          key: PageStorageKey(prop.name),
          leading: Icon(
            Icons.subdirectory_arrow_right,
            color: Dc2fTheme.propertyIconColor(prop),
          ),
          title: Text('${prop.name} (${prop.kind})'),
          backgroundColor: Colors.white,
          children: <Widget>[
            ..._propertyDetails(prop, context),
          ],
        );
      }).toList(),
    );
  }

  Widget _debug(ContentDefPropertyReflection prop, BuildContext context, dynamic subContent) => ListTile(
        leading: Icon(Icons.bug_report),
        title: Text(
          'Deeebug. ${prop.toJson()} - subContent: $subContent',
          style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 0.75, color: Colors.black38),
        ),
      );

  List<Widget> _propertyDetails(ContentDefPropertyReflection prop, BuildContext context) {
    if (prop.kind == ContentDefKind.Nested) {
      final children = this.children[prop.name];
      if (children != null) {
        return (children.map((child) {
                  return ListTile(
                    leading: Icon(
                      Icons.link,
                      color: Dc2fTheme.propertyIconColor(prop),
                    ),
                    title: Text('${child.path}'),
                    onTap: () {
                      Provider.of<ContentEditorBloc>(context).changePath(child.path);
                    },
                  );
                })?.toList() ??
                []) +
            [
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Dc2fTheme.propertyIconColor(prop),
                ),
                title: const Text('Create new item'),
                onTap: () {
                  showModalBottomSheet<MapEntry<String, String>>(
                    context: context,
                    builder: (context) {
                      return BottomSheet(
                          onClosing: () {},
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: prop.allowedTypes?.entries?.map((entry) {
                                    return ListTile(
                                      leading: Icon(Icons.add),
                                      title: Text('${entry.key} (${entry.value})'),
                                      onTap: () => Navigator.of(context).pop(entry),
                                    );
                                  })?.toList() ??
                                  [],
                            );
                          });
                    },
                  ).then((entry) {
                    if (entry == null) {
                      return;
                    }
                    final editorBloc = Provider.of<ContentEditorBloc>(context);
                    Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (subContext) => CreateContentObject(
                        parentPath: editorBloc.path,
                        property: prop.name,
                        typeIdentifier: entry.key,
                        type: entry.value,
                      ),
                    ));
                    _logger.info('Creating new $entry.');
                  });
                },
              ),
            ];
      } else {
        final dynamic subContent = content[prop.name] ?? (prop.multiValue ? null : <String, dynamic>{});
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
          return [_debug(prop, context, subContent)];
        }
      }
    } else if (prop.kind == ContentDefKind.Parsable) {
      final parsableContent = children[prop.name]?.first?.rawContent ?? content[prop.name] as String;
      _logger.fine('text content: ($parsableContent)');
      return [
        TextField(
          // workaround: add key, otherwise it seems the scrolling of the ListView is confused
          // with the scrolling of the text field.
          key: PageStorageKey('${prop.name}/${DateTime.now()}'),
          decoration: InputDecoration(
            helperText: '${prop.parsableHint}',
          ),
          controller: TextEditingController(text: parsableContent ?? ''),
          onChanged: (value) {
            _logger.fine('got text field modification. {$value}');
            onValueChanged(prop.name, value);
          },
          style: Theme.of(context).textTheme.body1.copyWith(fontFamily: 'RobotoMono'),
          maxLines: null,
          minLines: 14,
        ),
      ];
    } else if (prop.kind == ContentDefKind.Map) {
      final dynamic subContent = content[prop.name];
      if (subContent is Map) {
        final subContentMap = subContent.cast<String, dynamic>();
        assert(prop.mapValueType != null);
        return subContentMap.entries.map((entry) {
          if (entry.value is! Map) {
            return ExpansionTile(
                key: PageStorageKey('nested${entry.key}'),
                leading: Icon(Icons.label, color: Dc2fTheme.propertyIconColor(prop)),
                title: Text(entry.key + ' -- not yet supported (${prop.mapValueType} for ${entry.value.runtimeType})'),
                initiallyExpanded: false,
                children: <Widget>[]);
          }
          final entryValue = entry.value as Map<String, dynamic>;
          return Container(
            decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.green, width: 4))),
            child: ExpansionTile(
              key: PageStorageKey('nested${entry.key}'),
              leading: Icon(Icons.label, color: Dc2fTheme.propertyIconColor(prop)),
              title: Text(entry.key),
              initiallyExpanded: false,
              children: <Widget>[
                FutureBuilder<ContentDefReflection>(
                  initialData: null,
                  future: Provider.of<Deps>(context).apiService.reflectType(prop.mapValueType),
                  builder: (context, snapshot) => !snapshot.hasData
                      ? Container()
                      : Container(
                          decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.green, width: 4))),
                          child: ContentProperties(
                            reflection: snapshot.data,
                            content: entryValue,
                            children: {},
                            types: types,
                            onValueChanged: (String name, dynamic val) {
                              entryValue[name] = val;
                              onValueChanged(prop.name, subContentMap);
                            },
                          ),
                        ),
                )
              ],
            ),
          );
//          return ContentProperties(reflection: reflection,
//              content: (entry.value as Map<String, dynamic>),
//              children: {},
//              types: types,
//              onValueChanged: (key, dynamic value) {
//
//              });
        }).toList();
      }
    }
    return [_debug(prop, context, null)];
  }
}

typedef void OnValueChanged(dynamic value);

class PrimitiveContentProperty extends StatefulWidget {
  const PrimitiveContentProperty({
    Key key,
    @required this.prop,
    this.initialValue,
    this.defaultValue,
    @required this.onValueChanged,
  }) : super(key: key);

  final ContentDefPropertyReflection prop;
  final dynamic initialValue;
  final dynamic defaultValue;
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
    value = widget.initialValue ?? widget.defaultValue;
  }

  String _multiValueToString(dynamic value) {
    if (value is List) {
      return value.cast<String>().join(', ');
    }
    return value?.toString();
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
              secondary: Icon(Icons.edit, color: Dc2fTheme.propertyIconColor(prop)),
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
          leading: Icon(Icons.edit, color: Dc2fTheme.propertyIconColor(prop)),
          selected: false,
          enabled: false,
          title: TextField(
            // workaround: add key, otherwise it seems the scrolling of the ListView is confused
            // with the scrolling of the text field.
            key: PageStorageKey('${prop.name}/${DateTime.now()}'),
            decoration: InputDecoration(
              labelText: prop.name,
              helperText: prop.multiValue ? 'Multivalue: Enter comma separated values.' : null,
            ),
            controller: TextEditingController(text: prop.multiValue ? _multiValueToString(value) : value?.toString()),
            onChanged: (value) {
              if (prop.multiValue) {
                final multiValue = value.trim().split(RegExp(r'\s*,\s*'));
                _logger.fine('saving text modification as multivalue: $multiValue');
                widget.onValueChanged(multiValue);
              } else {
                _logger.fine('got text field modification. {$value}');
                widget.onValueChanged(value);
              }
            },
          ),
        );
      case PrimitiveType.ZonedDateTime:
        return ListTile(
          leading: Icon(Icons.calendar_today, color: Dc2fTheme.propertyIconColor(prop)),
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
                  widget.onValueChanged(isoFormat.format(dateTime));
                });
              },
            );
          },
        );
      case PrimitiveType.Unknown:
        return ListTile(
          leading: Icon(Icons.broken_image, color: Dc2fTheme.propertyIconColor(prop)),
          title: Text('Unsupported property ${prop.name} for now. ${prop.type}.'),
        );
    }
    throw ArgumentError('Invalid property type ${prop.type}');
  }
}

class FileInfo {
  FileInfo(this.path, this.length);

  final String path;
  final int length;
}

class FileSelectionBloc {
  FileSelectionBloc() {
    _selectedFiles.add({});
  }

  BehaviorSubject<Map<String, FileInfo>> _selectedFiles = BehaviorSubject();

  Map<String, FileInfo> get selectedFiles => _selectedFiles.value;

  void addFileSelected(String baseName, FileInfo fileInfo) {
    _selectedFiles.add({...selectedFiles, baseName: fileInfo});
  }
}

class CreateContentBloc {
  CreateContentBloc() {
    _data.add(ContentModifications());
  }

  BehaviorSubject<ContentModifications> _data = BehaviorSubject();

  ValueObservable<ContentModifications> get onDataChanged => _data.stream;

  void addModificationUpdate(String name, dynamic value) {
    _data.add(ContentModifications(updates: <String, dynamic>{
      ..._data.value.updates,
      name: value,
    }));
  }
}

class CreateContentObject extends StatefulWidget {
  const CreateContentObject(
      {Key key, @required this.parentPath, @required this.property, this.typeIdentifier, this.type})
      : super(key: key);

  final String parentPath;
  final String property;
  final String typeIdentifier;
  final String type;

  @override
  _CreateContentObjectState createState() => _CreateContentObjectState();
}

class _CreateContentObjectState extends State<CreateContentObject> {
  CreateContentBloc bloc = CreateContentBloc();
  FileSelectionBloc fileSelectionBloc = FileSelectionBloc();
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _slugController = TextEditingController();

  @override
  Widget build(BuildContext context) {
//    final bloc = Provider.of<ContentEditorBloc>(context);
    final deps = Provider.of<Deps>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create content "${widget.typeIdentifier}"'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 8)),
            ListTile(
              title: TextFormField(
                decoration: InputDecoration(labelText: 'Slug/Name for the new object'),
                controller: _slugController,
                validator: SValidator.notEmpty(),
              ),
              trailing: RaisedButton.icon(
                icon: Icon(Icons.save),
                label: const Text('Create'),
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    _logger.finest('We can safe this thing as ${_slugController.text} ${bloc._data.value}');
                    deps.apiService.createContent(
                      parentPath: widget.parentPath,
                      slug: _slugController.text,
                      property: widget.property,
                      typeIdentifier: widget.typeIdentifier,
                      content: bloc._data.value.updates,
                      files: fileSelectionBloc.selectedFiles,
                    );
                  }
                },
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 8)),
            Provider.value(
              value: fileSelectionBloc,
              child: FutureBuilder<ContentDefReflection>(
                  future: deps.apiService.reflectType(widget.type),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return Expanded(
                      child: SingleChildScrollView(
                        child: ContentProperties(
                          reflection: snapshot.data,
                          content: <String, dynamic>{},
                          children: <String, List<ContentDefChild>>{},
                          types: {},
                          onValueChanged: (String name, dynamic value) {
                            bloc.addModificationUpdate(name, value);
                          },
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
