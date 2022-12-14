// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scopedmodel_demo/main.dart';

void main() {
  testWidgets(
      'Counter increments test with the CounterModel => FAIL because the model contains an async function called',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(model: CounterModel()));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget,);
    expect(find.text('1'), findsNothing,);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing,);
    expect(find.text('1'), findsOneWidget,);
  },);

  testWidgets('Counter increments test with the TestModel => SUCCESS',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(model: TestModel()));

    // Verify that our counter starts at 0.
    expect(find.text('111'), findsOneWidget,);
    expect(find.text('113'), findsNothing,);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('111'), findsNothing,);
    expect(find.text('113'), findsOneWidget,);
  },);
}

class TestModel extends AbstractModel {
  int _counter = 111;

  @override
  int get counter => _counter;

  @override
  void increment() {
    _counter += 2;
    notifyListeners();
  }
}
