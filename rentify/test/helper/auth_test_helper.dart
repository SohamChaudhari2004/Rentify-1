import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelper {
  static Future<void> waitForElement(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    bool found = false;
    final DateTime start = DateTime.now();

    while (!found) {
      await tester.pump(const Duration(milliseconds: 100));
      found = finder.evaluate().isNotEmpty;

      if (DateTime.now().difference(start) > timeout) {
        throw Exception('Timed out waiting for element');
      }
    }
  }

  static Future<void> enterCredentials(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    final emailFieldFinder = find.byKey(const Key('emailField'));
    final passwordFieldFinder = find.byKey(const Key('passwordField'));

    await tester.enterText(emailFieldFinder, email);
    await tester.enterText(passwordFieldFinder, password);
    await tester.pump();
  }
}
