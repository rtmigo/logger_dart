// SPDX-FileCopyrightText: (c) 2021 Artёm IG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:logger/logger.dart';
import 'package:logger/src/logger.dart';
import "package:test/test.dart";

void main() {
  test('uriToDart', () {
    expect(
        uriToDartBasename(Uri.parse('file:///path/to/Code/dart/logger_dart/test/logger_test.dart')),
        'logger_test.dart');
    expect(
        uriToDartBasename(Uri.parse(
            'http://localhost:62331/aB%2Ftla701iJknCC3rfuATphYw4%2FCkfn1/test/logger_test.dart.browser_test.dart.js')),
        'logger_test.dart');
  });

  test('logger', () {
    var l = loggerByLevel(Level.info);

    String? msg = l.i('something happened');
    print(msg);
    expect(msg!.startsWith('INF|logger_test.dart:'), isTrue);
    expect(msg.endsWith('| something happened'), isTrue);
  });
}
