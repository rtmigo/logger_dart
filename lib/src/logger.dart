import 'package:meta/meta.dart';
import 'package:stack_trace/stack_trace.dart';

enum Level {
  verbose,
  info,
  warning,
  error,
  nothing,
}

class LevLogger {
  LevLogger(this.logger, this.level);

  final Logger logger;
  final Level level;

  void log(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    this.logger.log(this.level, message, error, stackTrace);
  }
}

@internal
String uriToDartBasename(Uri uri) {

  String filename = uri.toString().split('/').last;
  if (filename.endsWith('.dart.js')) {
    return filename.split('.dart.').first+'.dart';
  }
  return filename;
}

class Logger {
  Logger({minLevel = Level.info}) {
    this._minLevel = minLevel;
    this._prevGlobalLevel = minLevelGlobal;
  }

  Level? _prevGlobalLevel;
  LevLogger? _mbInfo, _mbVerbose, _mbError, _mbWarning;

  static Level minLevelGlobal = Level.verbose;

  Level get minLevel => _minLevel;

  set minLevel(Level l) {
    this._minLevel = l;
    this._reinitLLs();
  }

  LevLogger? _createLL(Level subLevel) {
    if (subLevel.index >= this.minLevel.index && subLevel.index >= Logger.minLevelGlobal.index) {
      return LevLogger(this, subLevel);
    }
    return null;
  }

  void _reinitLLs() {
    this._mbVerbose = _createLL(Level.verbose);
    this._mbInfo = _createLL(Level.info);
    this._mbWarning = _createLL(Level.warning);
    this._mbError = _createLL(Level.error);
  }

  void _reinitSubsIfStaticChanged() {
    if (Logger.minLevelGlobal != this._prevGlobalLevel) {
      this._prevGlobalLevel = Logger.minLevelGlobal;
      _reinitLLs();
    }
  }

  LevLogger? get verbose {
    _reinitSubsIfStaticChanged();
    return this._mbVerbose;
  }

  LevLogger? get info {
    _reinitSubsIfStaticChanged();
    return this._mbInfo;
  }

  LevLogger? get warning {
    _reinitSubsIfStaticChanged();
    return this._mbWarning;
  }

  LevLogger? get error {
    _reinitSubsIfStaticChanged();
    return this._mbError;
  }

  late Level _minLevel;

  /// Log a message at level [Level.verbose].
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.verbose, message, error, stackTrace);
  }

  /// Log a message at level [Level.info].
  String? i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    return log(Level.info, message, error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.warning, message, error, stackTrace);
  }

  /// Log a message at level [Level.error].
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.error, message, error, stackTrace);
  }

  String formatStackTrace(StackTrace stackTrace, int methodCount) {

    for (var frame in Trace.parse(stackTrace.toString()).frames) {
      //print('package: ${frame.package}');
      if (  frame.package == 'logger' &&
            frame.member?.startsWith('Logger.') == true ) {
        continue;
      }

      String filename = uriToDartBasename(frame.uri);
      return '$filename:${frame.line}';
    }

    throw ArgumentError('Failed to format the stack trace');
  }

  static String levelToPrefix(Level l) {
    switch (l) {
      case Level.verbose:
        return 'VRB';
      case Level.info:
        return 'INF';
      case Level.warning:
        return 'WRN';
      case Level.error:
        return 'ERR';
      case Level.nothing:
        throw ArgumentError.value(l);
    }
  }

  /// Log a message with [level].
  String? log(Level level, dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (level == Level.nothing) throw ArgumentError('Log events cannot have Level.nothing');

    if (error != null && error is StackTrace) {
      throw ArgumentError('Error parameter cannot take a StackTrace!');
    }

    if (level.index >= this.minLevel.index && level.index >= Logger.minLevelGlobal.index) {
      String result = '${levelToPrefix(level)}|${this.formatStackTrace(StackTrace.current, 0)}| $message';
      print(result);
      return result;
    }

    return null;
  }
}

Logger loggerByLevel(Level level) {
  final result = Logger(minLevel: level);
  return result;
}