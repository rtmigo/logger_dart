// todo use stack_trace module

enum Level {
  verbose,
  info,
  warning,
  error,
  nothing,
}

class StackLine {
  StackLine(String line) {
    var match = _deviceStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return;
    }

    this.pkg = match.group(2);
  }

  String? pkg;

  // регексы отсюда https://github.com/leisim/logger/blob/master/lib/src/printers/pretty_printer.dart

  /// Matches a stacktrace line as generated on Android/iOS devices.
  /// For example:
  /// #1      Logger.log (package:logger/src/logger.dart:115:29)
  static final _deviceStackTraceRegex = RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');

  /// Matches a stacktrace line as generated by Flutter web.
  /// For example:
  /// packages/logger/src/printers/pretty_printer.dart 91:37
  static final _webStackTraceRegex = RegExp(r'^((packages|dart-sdk)\/[^\s]+\/)');

  /// Matches a stacktrace line as generated by browser Dart.
  /// For example:
  /// dart:sdk_internal
  /// package:logger/src/logger.dart
  static final _browserStackTraceRegex = RegExp(r'^(?:package:)?(dart:[^\s]+|[^\s]+)');
}

class StackParsing {
  static String keepBasenameAndLineCol(String txt) {
    final parts = txt.split("/");
    return parts[parts.length - 1];
  }
}

class LevLogger {
  LevLogger(this.logger, this.level);

  final RcdLogger logger;
  final Level level;

  void log(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    this.logger.log(this.level, message, error, stackTrace);
  }
}

class RcdLogger {
  RcdLogger({minLevel = Level.info}) {
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
    if (subLevel.index >= this.minLevel.index && subLevel.index >= RcdLogger.minLevelGlobal.index)
      return LevLogger(this, subLevel);
    return null;
  }

  _reinitLLs() {
    this._mbVerbose = _createLL(Level.verbose);
    this._mbInfo = _createLL(Level.info);
    this._mbWarning = _createLL(Level.warning);
    this._mbError = _createLL(Level.error);
  }

  void _reinitSubsIfStaticChanged() {
    if (RcdLogger.minLevelGlobal != this._prevGlobalLevel) {
      this._prevGlobalLevel = RcdLogger.minLevelGlobal;
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
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.info, message, error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.warning, message, error, stackTrace);
  }

  /// Log a message at level [Level.error].
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.error, message, error, stackTrace);
  }

  bool isInterestingStacktraceLine(StackLine line) {
    if (line.pkg == null) {
      return false;
    }
    if (line.pkg!.contains('/logger.dart:')) {
      return false;
    }
    return true;
  }

  String formatStackTrace(StackTrace stackTrace, int methodCount) {
    var lines = stackTrace.toString().split('\n');

    for (var line in lines) {
      var l = StackLine(line);
      if (isInterestingStacktraceLine(l)) {
        assert(l.pkg != null);
        return StackParsing.keepBasenameAndLineCol(l.pkg!);
      }
    }

    throw ArgumentError("Failed to parse");
  }

  static String levelToPrefix(Level l) {
    switch (l) {
      case Level.verbose:
        return "VRB";
      case Level.info:
        return "INF";
      case Level.warning:
        return "WRN";
      case Level.error:
        return "ERR";
      case Level.nothing:
        throw ArgumentError.value(l);
    }
  }

  /// Log a message with [level].
  void log(Level level, dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (level == Level.nothing) throw ArgumentError('Log events cannot have Level.nothing');

    if (error != null && error is StackTrace) {
      throw ArgumentError('Error parameter cannot take a StackTrace!');
    }

    if (level.index >= this.minLevel.index && level.index >= RcdLogger.minLevelGlobal.index) {
      print("${levelToPrefix(level)}|${this.formatStackTrace(StackTrace.current, 0)}| $message");
    }
  }
}

RcdLogger loggerByLevel(Level level) {
  final result = RcdLogger(minLevel: level);
  return result;
}