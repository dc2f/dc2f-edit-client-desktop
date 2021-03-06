
import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

class StaticTextGenerator extends Generator {

  StaticTextGenerator(this.content);

  final String content;

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) => content;
}

Builder staticTextBuilder(BuilderOptions options) =>
    SharedPartBuilder([StaticTextGenerator(options.config['content'] as String ?? '')], 'static_text');
