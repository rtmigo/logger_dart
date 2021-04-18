import "package:test/test.dart";
import 'package:logger/logger.dart';

void main()
{
  test('bisect_right_int', ()
  {
    final src = "file:///pathto/Code/smarter_flutter/test/unit/game_test.dart:121:47";

    expect(StackParsing.keepBasenameAndLineCol(src), "game_test.dart:121:47");
    //checkBSR(bisectRightNum);
  });

//
}
