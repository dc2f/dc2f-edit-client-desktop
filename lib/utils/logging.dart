import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final _logger = Logger('oma.utils.logging');

class FlutterCrashlytics {
  FlutterCrashlytics._();

  factory FlutterCrashlytics() => _instance;

  static final _instance = FlutterCrashlytics._();


  void onError(FlutterErrorDetails details) {
//    _crashlytics.onError(details);
  }

  void log(String message, {Level priority = Level.INFO, String tag = ''}) {
//    _crashlytics.log('$tag ${priority.name} $message');
  }

  void logException(dynamic error, StackTrace stackTrace) {
  }

  void reportCrash(dynamic error, StackTrace stackTrace, {bool forceCrash}) {
  }

  void setUserInfo(String identifier, String email, String userName) {
  }
}
//
//final LogzIoApiSender logzIoApiSender = LogzIoApiSender(
//  apiToken: 'KvQOTNtCVUDMNwghVVXHkGQdyLRTyczc',
//  labels: {'app': 'priso', 'os': Platform.operatingSystem},
//);

void setupLogging() {
  FlutterError.onError = (FlutterErrorDetails details) {
    _logger.severe('flutter error ${details.toString()}', details.exception, details.stack);
    FlutterError.dumpErrorToConsole(details);
    FlutterCrashlytics().onError(details);
  };

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.loggerName} - ${rec.level.name}: ${rec.time}: ${rec.message}');

//    TODO do not send everything to crashlytics.
//    if (rec.level >= Level.INFO) {
      FlutterCrashlytics().log(rec.message, priority: rec.level, tag: rec.loggerName);
//    }

    if (rec.error != null) {
      print(rec.error);
    }
    // ignore: avoid_as
    final stackTrace = rec.stackTrace ?? (rec.error is Error ? (rec.error as Error).stackTrace : null);
    if (stackTrace != null) {
      print(stackTrace);
      if (rec.level >= Level.INFO) {
//        AnalyticsUtils.instance.analytics
//            .logEvent(name: 'logerror', parameters: {'message': rec.message, 'stack': rec.stackTrace});
        FlutterCrashlytics().logException(rec.error, stackTrace);
      }
    } else if (rec.level >= Level.SEVERE) {
//      AnalyticsUtils.instance.analytics
//          .logEvent(name: 'logerror', parameters: {'message': rec.message, 'stack': StackTrace.current.toString()});
      FlutterCrashlytics().logException(Exception('SEVERE LOG ${rec.message}'), StackTrace.current);
    }
  });
//  Logger.root.onRecord.listen(logzIoApiSender.logListener());
}

class LoggingUtil {

  static Function futureCatchErrorLog(dynamic message) {
    return (dynamic error, StackTrace stackTrace) {
      _logger.warning('Error during future: $message', error, stackTrace);
      return Future<dynamic>.error(error, stackTrace);
    };
  }
}
