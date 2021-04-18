import "package:test/test.dart";
import 'package:logger/logger.dart';
import 'package:logger/src/logger.dart';

void main()
{
  // test('bisect_right_int', ()
  // {
  //   final src = "file:///pathto/Code/smarter_flutter/test/unit/game_test.dart:121:47";
  //
  //   expect(StackParsing.keepBasenameAndLineCol(src), "game_test.dart:121:47");
  //   //checkBSR(bisectRightNum);
  // });

  test('uriToDart', () {
    expect(uriToDartBasename(Uri.parse('file:///path/to/Code/dart/logger_dart/test/logger_test.dart')), 'logger_test.dart');
    expect(uriToDartBasename(Uri.parse('http://localhost:62331/aB%2Ftla701iJknCC3rfuATphYw4%2FCkfn1/test/logger_test.dart.browser_test.dart.js')), 'logger_test.dart');
  });
  //file:///path/to/Code/dart/logger_dart/test/logger_test.dart
  //http://localhost:62331/aB%2Ftla701iJknCC3rfuATphYw4%2FCkfn1/test/logger_test.dart.browser_test.dart.js

  test('logger', () {
    var l = loggerByLevel(Level.info);
    
    String? msg = l.i('something happened');
    print(msg);
    expect(msg!.startsWith('INF|logger_test.dart:'), isTrue);
    expect(msg.endsWith('| something happened'), isTrue);

  });

//
}
