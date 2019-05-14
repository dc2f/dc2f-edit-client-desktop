import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dto.g.dart';

@JsonSerializable()
class ContentDefReflect {
  ContentDefReflect({
    @required this.content,
    @required this.breadcrumbs,
    @required this.children,
    @required this.reflection,
  });

  factory ContentDefReflect.fromJson(Map<String, dynamic> json) => _$ContentDefReflectFromJson(json);

  final Map<String, dynamic> content;
  final List<BreadcrumbsItem> breadcrumbs;
  final Map<String, List<ContentDefChild>> children;
  final ContentDefReflection reflection;

  Map<String, dynamic> toJson() => _$ContentDefReflectToJson(this);
}

@JsonSerializable(nullable: false)
class BreadcrumbsItem {
  BreadcrumbsItem({
    this.name,
    this.path,
  });

  factory BreadcrumbsItem.fromJson(Map<String, dynamic> json) => _$BreadcrumbsItemFromJson(json);

  Map<String, dynamic> toJson() => _$BreadcrumbsItemToJson(this);

  final String name;
  final String path;
}

@JsonSerializable()
class ContentDefChild {
  ContentDefChild({
    this.path,
    this.isProperty,
    this.rawContent,
  });

  factory ContentDefChild.fromJson(Map<String, dynamic> json) => _$ContentDefChildFromJson(json);

  Map<String, dynamic> toJson() => _$ContentDefChildToJson(this);

  final String path;
  final bool isProperty;
  /// for parsable content, contains the raw string representation.
  final String rawContent;
}

@JsonSerializable(nullable: false)
class ContentDefReflection {
  ContentDefReflection({
    this.properties,
  });

  factory ContentDefReflection.fromJson(Map<String, dynamic> json) => _$ContentDefReflectionFromJson(json);

  Map<String, dynamic> toJson() => _$ContentDefReflectionToJson(this);

  final List<ContentDefPropertyReflection> properties;
}

enum PrimitiveType { String, Boolean, ZonedDateTime, Unknown }

enum ContentDefKind { Parsable, Primitive, Map, Nested }

@JsonSerializable(nullable: true)
class ContentDefPropertyReflection {
  ContentDefPropertyReflection({
    this.kind,
    this.name,
    this.optional,
    this.multiValue,
    this.type,
    this.parsableHint,
    this.allowedTypes,
    this.baseType,
  });

  factory ContentDefPropertyReflection.fromJson(Map<String, dynamic> json) =>
      _$ContentDefPropertyReflectionFromJson(json);

  Map<String, dynamic> toJson() => _$ContentDefPropertyReflectionToJson(this);

  final ContentDefKind kind;
  final String name;
  final bool optional;
  final bool multiValue;

  // kind == primitive
  final PrimitiveType type;

  // kind == nested
  final Map<String, String> allowedTypes;
  final String baseType;

  // kind == parsable
  final String parsableHint;
}
