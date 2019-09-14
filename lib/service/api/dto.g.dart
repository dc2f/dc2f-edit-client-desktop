// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReflectTypeResponse _$ReflectTypeResponseFromJson(Map<String, dynamic> json) {
  return ReflectTypeResponse(
      types: (json['types'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, ContentDefReflection.fromJson(e as Map<String, dynamic>)),
  ));
}

Map<String, dynamic> _$ReflectTypeResponseToJson(
        ReflectTypeResponse instance) =>
    <String, dynamic>{'types': instance.types};

UpdateResult _$UpdateResultFromJson(Map<String, dynamic> json) {
  return UpdateResult(
      status: json['status'] as String,
      unsaved: (json['unsaved'] as List).map((e) => e as String).toList());
}

Map<String, dynamic> _$UpdateResultToJson(UpdateResult instance) =>
    <String, dynamic>{'status': instance.status, 'unsaved': instance.unsaved};

ContentDefReflect _$ContentDefReflectFromJson(Map<String, dynamic> json) {
  return ContentDefReflect(
      content: json['content'] as Map<String, dynamic>,
      breadcrumbs: (json['breadcrumbs'] as List)
          ?.map((e) => e == null
              ? null
              : BreadcrumbsItem.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      children: (json['children'] as Map<String, dynamic>)?.map(
        (k, e) => MapEntry(
            k,
            (e as List)
                ?.map((e) => e == null
                    ? null
                    : ContentDefChild.fromJson(e as Map<String, dynamic>))
                ?.toList()),
      ),
      reflection: json['reflection'] == null
          ? null
          : ContentDefReflection.fromJson(
              json['reflection'] as Map<String, dynamic>),
      types: (json['types'] as Map<String, dynamic>)?.map(
        (k, e) => MapEntry(
            k,
            e == null
                ? null
                : ContentDefReflection.fromJson(e as Map<String, dynamic>)),
      ));
}

Map<String, dynamic> _$ContentDefReflectToJson(ContentDefReflect instance) =>
    <String, dynamic>{
      'content': instance.content,
      'breadcrumbs': instance.breadcrumbs,
      'children': instance.children,
      'reflection': instance.reflection,
      'types': instance.types
    };

BreadcrumbsItem _$BreadcrumbsItemFromJson(Map<String, dynamic> json) {
  return BreadcrumbsItem(
      name: json['name'] as String, path: json['path'] as String);
}

Map<String, dynamic> _$BreadcrumbsItemToJson(BreadcrumbsItem instance) =>
    <String, dynamic>{'name': instance.name, 'path': instance.path};

ContentDefChild _$ContentDefChildFromJson(Map<String, dynamic> json) {
  return ContentDefChild(
      path: json['path'] as String,
      isProperty: json['isProperty'] as bool,
      rawContent: json['rawContent'] as String);
}

Map<String, dynamic> _$ContentDefChildToJson(ContentDefChild instance) =>
    <String, dynamic>{
      'path': instance.path,
      'isProperty': instance.isProperty,
      'rawContent': instance.rawContent
    };

ContentDefReflection _$ContentDefReflectionFromJson(Map<String, dynamic> json) {
  return ContentDefReflection(
      properties: (json['properties'] as List)
          .map((e) =>
              ContentDefPropertyReflection.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: json['type'] as String,
      typeIdentifier: json['typeIdentifier'] as String,
      defaultValues: json['defaultValues'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ContentDefReflectionToJson(
        ContentDefReflection instance) =>
    <String, dynamic>{
      'type': instance.type,
      'typeIdentifier': instance.typeIdentifier,
      'defaultValues': instance.defaultValues,
      'properties': instance.properties
    };

ContentDefPropertyReflection _$ContentDefPropertyReflectionFromJson(
    Map<String, dynamic> json) {
  return ContentDefPropertyReflection(
      kind: _$enumDecodeNullable(_$ContentDefKindEnumMap, json['kind']),
      name: json['name'] as String,
      optional: json['optional'] as bool,
      multiValue: json['multiValue'] as bool,
      type: _$enumDecodeNullable(_$PrimitiveTypeEnumMap, json['type']),
      parsableHint: json['parsableHint'] as String,
      allowedTypes: (json['allowedTypes'] as Map<String, dynamic>)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      baseType: json['baseType'] as String,
      mapValueType: json['mapValueType'] as String,
      fileType: _$enumDecodeNullable(_$FileTypeEnumMap, json['fileType']),
      enumValues:
          (json['enumValues'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$ContentDefPropertyReflectionToJson(
        ContentDefPropertyReflection instance) =>
    <String, dynamic>{
      'kind': _$ContentDefKindEnumMap[instance.kind],
      'name': instance.name,
      'optional': instance.optional,
      'multiValue': instance.multiValue,
      'type': _$PrimitiveTypeEnumMap[instance.type],
      'allowedTypes': instance.allowedTypes,
      'baseType': instance.baseType,
      'parsableHint': instance.parsableHint,
      'mapValueType': instance.mapValueType,
      'fileType': _$FileTypeEnumMap[instance.fileType],
      'enumValues': instance.enumValues
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$ContentDefKindEnumMap = <ContentDefKind, dynamic>{
  ContentDefKind.Parsable: 'Parsable',
  ContentDefKind.Primitive: 'Primitive',
  ContentDefKind.Map: 'Map',
  ContentDefKind.Nested: 'Nested',
  ContentDefKind.File: 'File',
  ContentDefKind.ContentReference: 'ContentReference',
  ContentDefKind.Enum: 'Enum'
};

const _$PrimitiveTypeEnumMap = <PrimitiveType, dynamic>{
  PrimitiveType.String: 'String',
  PrimitiveType.Boolean: 'Boolean',
  PrimitiveType.ZonedDateTime: 'ZonedDateTime',
  PrimitiveType.Unknown: 'Unknown'
};

const _$FileTypeEnumMap = <FileType, dynamic>{
  FileType.File: 'File',
  FileType.Image: 'Image'
};

ContentCreate _$ContentCreateFromJson(Map<String, dynamic> json) {
  return ContentCreate(
      typeIdentifier: json['typeIdentifier'] as String,
      property: json['property'] as String,
      slug: json['slug'] as String,
      content: json['content'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ContentCreateToJson(ContentCreate instance) =>
    <String, dynamic>{
      'typeIdentifier': instance.typeIdentifier,
      'property': instance.property,
      'slug': instance.slug,
      'content': instance.content
    };

// **************************************************************************
// StaticTextGenerator
// **************************************************************************

// ignore_for_file: strong_mode_implicit_dynamic_parameter, implicit_dynamic_parameter, implicit_dynamic_variable
