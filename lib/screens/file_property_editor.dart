import 'dart:io';

import 'package:dc2f_edit_client_desktop/service/api/dto.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import '../theme.dart';
import 'content_editor.dart';

final _logger = Logger('file_property_editor');

class FilePropertyEditor extends StatefulWidget {
  FilePropertyEditor({
    Key key,
    this.prop,
    this.initialValue,
    this.onValueChanged,
  }) : super(key: key);

  final ContentDefPropertyReflection prop;
  final dynamic initialValue;
  final OnValueChanged onValueChanged;

  @override
  _FilePropertyEditorState createState() => _FilePropertyEditorState();
}

class _FilePropertyEditorState extends State<FilePropertyEditor> {
  dynamic value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        widget.prop.fileType == FileType.Image ? Icons.image : Icons.file_upload,
        color: Dc2fTheme.propertyIconColor(widget.prop),
      ),
      title: value == null
          ? Text('Nothing selected', style: Theme.of(context).textTheme.body1.apply(color: Colors.black12))
          : Text('$value'),
      onTap: () {
        showOpenPanel(
          (result, paths) {
            _logger.fine('got result $result with paths $paths');
//                          File(paths[0]).readAsBytes()
            if (result == FileChooserResult.ok) {
              final baseName = p.basename(paths[0]);
              widget.onValueChanged(baseName);
              final file = File(paths[0]);
              Provider.of<FileSelectionBloc>(context).addFileSelected(baseName, FileInfo(paths[0], file.lengthSync()));
              setState(() {
                value = baseName;
              });
            }
          },
          allowedFileTypes: ['gif', 'png', 'jpg', 'svg', 'ico'],
          confirmButtonText: 'Select',
        );
      },
    );
  }
}
