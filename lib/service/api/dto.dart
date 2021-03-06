import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dto.g.dart';

@JsonSerializable(nullable: false)
class ReflectTypeResponse {
  ReflectTypeResponse({
    this.types,
  });

  factory ReflectTypeResponse.fromJson(Map<String, dynamic> json) => _$ReflectTypeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReflectTypeResponseToJson(this);

  final Map<String, ContentDefReflection> types;
}

@JsonSerializable(nullable: false)
class UpdateResult {
  UpdateResult({this.status, this.unsaved});

  factory UpdateResult.fromJson(Map<String, dynamic> json) => _$UpdateResultFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateResultToJson(this);

  final String status;
  final List<String> unsaved;
}

@JsonSerializable()
class ContentDefReflect {
  ContentDefReflect({
    @required this.content,
    @required this.breadcrumbs,
    @required this.children,
    @required this.reflection,
    @required this.types,
  });

  factory ContentDefReflect.fromJson(Map<String, dynamic> json) => _$ContentDefReflectFromJson(json);

  final Map<String, dynamic> content;
  final List<BreadcrumbsItem> breadcrumbs;
  final Map<String, List<ContentDefChild>> children;
  final ContentDefReflection reflection;
  final Map<String, ContentDefReflection> types;

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
    this.type,
    this.typeIdentifier,
    this.defaultValues,
  });

  factory ContentDefReflection.fromJson(Map<String, dynamic> json) => _$ContentDefReflectionFromJson(json);

  Map<String, dynamic> toJson() => _$ContentDefReflectionToJson(this);

  final String type;
  final String typeIdentifier;
  final Map<String, dynamic> defaultValues;
  final List<ContentDefPropertyReflection> properties;
}

enum PrimitiveType { String, Boolean, ZonedDateTime, Unknown }

enum ContentDefKind { Parsable, Primitive, Map, Nested, File, ContentReference, Enum }

enum FileType { File, Image }

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
    this.mapValueType,
    this.fileType,
    this.enumValues,
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

  // kind == map
  final String mapValueType;

  // kind == file
  final FileType fileType;

  // kind == enum
  final List<String> enumValues;
}

@JsonSerializable(nullable: false)
class ContentCreate {
  ContentCreate({this.typeIdentifier, this.property, this.slug, this.content});

  factory ContentCreate.fromJson(Map<String, dynamic> json) => _$ContentCreateFromJson(json);

  Map<String, dynamic> toJson() => _$ContentCreateToJson(this);

  final String typeIdentifier;
  final String property;
  final String slug;
  final Map<String, dynamic> content;
}
