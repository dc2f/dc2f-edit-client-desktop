import 'package:meta/meta.dart';

import 'environment/env.dart';
import 'service/api/api_service.dart';

class Deps {
  Deps._({@required this.env, @required this.apiService});

  factory Deps({@required Env env}) => Deps._(env: env, apiService: ApiService(ApiCaller(apiEndpoint: env.backendUrl)));

  final Env env;
  final ApiService apiService;
}
