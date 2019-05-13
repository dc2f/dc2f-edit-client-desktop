// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentDefReflect _$ContentDefReflectFromJson(Map<String, dynamic> json) {
  return ContentDefReflect(
      content: json['content'] as Map<String, dynamic>,
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
              json['reflection'] as Map<String, dynamic>));
}

Map<String, dynamic> _$ContentDefReflectToJson(ContentDefReflect instance) =>
    <String, dynamic>{
      'content': instance.content,
      'children': instance.children,
      'reflection': instance.reflection
    };

ContentDefChild _$ContentDefChildFromJson(Map<String, dynamic> json) {
  return ContentDefChild(
      path: json['path'] as String, isProperty: json['isProperty'] as bool);
}

Map<String, dynamic> _$ContentDefChildToJson(ContentDefChild instance) =>
    <String, dynamic>{'path': instance.path, 'isProperty': instance.isProperty};

ContentDefReflection _$ContentDefReflectionFromJson(Map<String, dynamic> json) {
  return ContentDefReflection(
      properties: (json['properties'] as List)
          .map((e) =>
              ContentDefPropertyReflection.fromJson(e as Map<String, dynamic>))
          .toList());
}

Map<String, dynamic> _$ContentDefReflectionToJson(
        ContentDefReflection instance) =>
    <String, dynamic>{'properties': instance.properties};

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
      baseType: json['baseType'] as String);
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
      'parsableHint': instance.parsableHint
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
  ContentDefKind.Nested: 'Nested'
};

const _$PrimitiveTypeEnumMap = <PrimitiveType, dynamic>{
  PrimitiveType.String: 'String',
  PrimitiveType.Boolean: 'Boolean',
  PrimitiveType.ZonedDateTime: 'ZonedDateTime',
  PrimitiveType.Unknown: 'Unknown'
};

// **************************************************************************
// StaticTextGenerator
// **************************************************************************

// ignore_for_file: strong_mode_implicit_dynamic_parameter