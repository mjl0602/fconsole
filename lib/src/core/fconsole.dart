import 'package:fconsole/src/model/log.dart';
import 'package:flutter/material.dart';

import '../model/log.dart';
import 'shake_detector.dart';

class FConsole extends ChangeNotifier {
  ConsoleOptions options = ConsoleOptions();
  ShakeDetector shakeDetector;

  ValueNotifier isShow = ValueNotifier(false);

  static FConsole _instance;

  factory FConsole() => _getInstance();

  static FConsole get instance => _getInstance();

  static FConsole _getInstance() {
    if (_instance == null) {
      _instance = FConsole._();
    }
    return _instance;
  }

  FConsole._();

  void start({ConsoleOptions options}) {
    this.options = options ?? ConsoleOptions();
  }

  void startShakeListener(Function() onShake) {
    stopShakeListener();
    shakeDetector = ShakeDetector.autoStart(onPhoneShake: () {
      ///detecotor phone shake
      onShake?.call();
    });
  }

  void stopShakeListener() {
    if (shakeDetector != null) {
      shakeDetector.stopListening();
      shakeDetector = null;
    }
  }

  List<Log> allLog = [];
  List<Log> errorLog = [];
  List<Log> verboselog = [];
  int currentLogIndex = 0;

  static log(dynamic log) {
    if (log != null) {
      Log lg = Log(log, LogType.log);
      FConsole.instance.verboselog.add(lg);
      FConsole.instance.allLog.add(lg);
      FConsole.instance.notifyListeners();
    }
  }

  List<Log> logs(int logType) {
    if (logType == 0) {
      return allLog;
    }
    if (logType == 1) {
      return verboselog;
    }
    if (logType == 2) {
      return errorLog;
    }
    return null;
  }

  static error(dynamic error) {
    if (error != null) {
      Log lg = Log(error, LogType.error);
      FConsole.instance.errorLog.add(lg);
      FConsole.instance.allLog.add(lg);
      FConsole.instance.notifyListeners();
    }
  }

  void clear(bool clearAll) {
    if (clearAll) {
      allLog.clear();
      verboselog.clear();
      errorLog.clear();
    } else {
      if (currentLogIndex == 0) {
        allLog.clear();
      } else if (currentLogIndex == 1) {
        verboselog.clear();
      } else if (currentLogIndex == 2) {
        errorLog.clear();
      }
    }
    FConsole.instance.notifyListeners();
  }
}

class ConsoleOptions {
  final bool showTime;
  final String timeFormat;
  final ConsoleDisplayMode displayMode;

  ConsoleOptions({
    this.showTime = true,
    this.timeFormat = "HH:mm:ss",
    this.displayMode = ConsoleDisplayMode.Shake,
  });
}

///How to show the console button
enum ConsoleDisplayMode {
  None, //Don't show
  Shake, //by shake
  Always, // always show
}
