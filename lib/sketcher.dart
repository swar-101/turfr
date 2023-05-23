import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

GestureDetector buildCurrentPath(BuildContext context) {

  void onPanStart(DragStartDetails details) {
    print('User started drawing.');
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    print(point);
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    print(point);
  }


  void onPanEnd(DragEndDetails details) {
    print('User ended drawing.');
  }

  /*
  *
  * 1. `onPanStart()` is executed when the use touches the screen and starts
  *     dragging
  * 2. When the user is dragging their finger without lifting it off the screen,
  *     the app executes `onPanUpdate()`.
  * 3. `onPanEnd()` is executed when the user lifts their finger off the screen.
  *
  * To find `RenderBox` for `GestureDetector`, we used `findRenderObject()`.
  * We also used `globalToLocal()` to convert the global co-ordinates to the
  * local co-ordinates we'll use to draw the path.
  *
  * For now, we are printing the points the user touches on the screen to the
  * console, to ensure that the detection works as expected.
  *
  * We add `buildCurrentPath()` to `Stack` in the main `build()`.
  */

  return GestureDetector(
    onPanStart: onPanStart,
    onPanUpdate: onPanUpdate,
    onPanEnd: onPanEnd,
    child: RepaintBoundary(
      child: Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // Custom Paint Widget will go here
      ),
    ),
  );

  /*
  * 1. In the above code, we return `GestureDetector` from `buildCurrentPath()`.
  * 2. We use `GestureDetector`'s  `onPanStart()`, `onPanUpdate()`, `onPanEnd()`
  *     events to detect the touches (specifically the dragging on the screen).
  * 3. We also use `RepaintBoundary` to optimize the redrawing.
  *
  * */



}

