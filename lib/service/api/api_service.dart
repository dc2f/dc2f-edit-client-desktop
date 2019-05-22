import 'dart:convert';
import 'dart:io';

import 'package:dc2f_edit_client_desktop/screens/content_editor.dart';
import 'package:meta/meta.dart';
import 'package:logging/logging.dart';
import 'package:dio/dio.dart';

import 'dto.dart';

final _logger = Logger('api-service');

class ApiService {
  ApiService(this.apiCaller);

  final ApiCaller apiCaller;

  Future<ContentDefReflect> reflectContentPath(String path) {
    if (!path.startsWith('/')) {
//      throw ArgumentError.value(path, 'Path must start with slash.');
      path = '/$path';
    }
    return _logApiError(apiCaller.get('/reflect$path').then((json) => ContentDefReflect.fromJson(json)));
  }

  Future<UpdateResult> saveModifications(String path, Map<String, dynamic> updates) {
    _logger.finest('Saving modifications.');
    return _logApiError(
      apiCaller.patch('/update$path', data: <String, dynamic>{'updates': updates}).then((json) {
        _logger.finest('Got update response $json');
        return UpdateResult.fromJson(json);
      }),
    );
  }

  Future<ReflectTypeResponse> reflectTypes(Set<String> type) {
    // TODO cache reflected types..
    return _logApiError(
      apiCaller
          .get(Uri(path: '/type/', queryParameters: <String, dynamic>{'type': type}).toString().toString())
          .then((json) => ReflectTypeResponse.fromJson(json)),
    );
  }

  Future<ContentDefReflection> reflectType(String baseType) {
    return reflectTypes({baseType}).then((val) => val.types[baseType]);
  }

  Future<String> createContent({
    @required String parentPath,
    @required String slug,
    @required String property,
    @required String typeIdentifier,
    @required Map<String, dynamic> content,
    @required Map<String, FileInfo> files,
  }) async {
    final beginResponse = await apiCaller.post(
      '/createChild/begin$parentPath',
      data: ContentCreate(
        typeIdentifier: typeIdentifier,
        property: property,
        slug: slug,
        content: content,
      ).toJson(),
    );
    final transaction = beginResponse['transaction'] as String;
    final headers =<String, dynamic>{
      'x-transaction': transaction,
    };
    await apiCaller.post(
      '/createChild/upload$parentPath',
      headers: headers,
      formData: FormData.from(<String, dynamic>{
        'files': files.entries.map((entry) => UploadFileInfo(File(entry.value.path), entry.key)).toList(),
      }),
    );
    final response = await apiCaller.post('/createChild/commit', headers: headers);
    final path = response['path'] as String;
    _logger.fine('Saved content, available as $path');
    return path;
  }
}

Future<T> _logApiError<T>(Future<T> then) => then.catchError((dynamic err, StackTrace stackTrace) {
      _logger.warning('Error during api call.', err, stackTrace);
      return Future<T>.error(err, stackTrace);
    });

class ApiCallerException implements Exception {
  ApiCallerException(this.message);

  String message;

  @override
  String toString() {
    return 'ApiCallerException{message=$message}';
  }
}

class UnauthorizedException extends ApiCallerException {
  UnauthorizedException(String message) : super(message);
}

class BadRequestException extends ApiCallerException {
  BadRequestException(String message) : super(message);
}

class ApiCaller {
  ApiCaller({@required String apiEndpoint}) : apiEndpoint = apiEndpoint.replaceAll(RegExp(r'/+$'), '');

  final String apiEndpoint;
  final Dio dio = Dio();

  Future<Map<String, dynamic>> _callApi(
    String path, {
    String method,
    Map<String, dynamic> data,
    FormData formData,
    bool ignoreOkResult = false,
    Map<String, dynamic> headers,
  }) {
    _logger.fine('calling api $method: $apiEndpoint$path');

    return dio
        .request<String>(
      '$apiEndpoint$path',
      data: data ?? formData,
      options: Options(
        method: method,
        responseType: ResponseType.plain,
        validateStatus: (status) =>
            status == HttpStatus.ok || status == HttpStatus.unauthorized || status == HttpStatus.badRequest,
        headers: headers,
      ),
    )
        .then((response) {
      if (response.statusCode == HttpStatus.unauthorized) {
        return Future.error(UnauthorizedException('Endpoint returned unauthorized.'), StackTrace.current);
      }
      if (ignoreOkResult) {
        return <String, dynamic>{};
      }
      final Map<String, dynamic> data = json.decode(response.data) as Map<String, dynamic>;
      if (response.statusCode == HttpStatus.badRequest) {
        _logger.warning('Bad request, $data');
        return Future.error(BadRequestException(data['message'] as String));
      }
      return data;
    }, onError: (dynamic error, StackTrace stackTrace) {
      _logger.warning('Error while calling api endpoint $path', error, stackTrace);
      return Future<Map<String, dynamic>>.error(error, stackTrace);
    });
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic> data,
    bool ignoreOkResult = false,
    FormData formData,
    Map<String, dynamic> headers,
  }) {
    return _callApi(
      path,
      method: 'POST',
      data: data,
      formData: formData,
      headers: headers,
      ignoreOkResult: ignoreOkResult,
    );
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic> data, bool ignoreOkResult = false}) {
    return _callApi(
      path,
      method: 'PUT',
      data: data,
      ignoreOkResult: ignoreOkResult,
    );
  }

  Future<Map<String, dynamic>> get(String path, {bool ignoreOkResult = false}) {
    return _callApi(
      path,
      method: 'GET',
      data: null,
      ignoreOkResult: ignoreOkResult,
    );
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic> data, bool ignoreOkResult = false}) {
    return _callApi(
      path,
      method: 'PATCH',
      data: data,
      ignoreOkResult: ignoreOkResult,
    );
  }
}
