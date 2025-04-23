import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelper {
  /// Waits for a UI element to appear with a timeout
  static Future<void> waitForElement(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    bool found = false;
    final DateTime start = DateTime.now();

    do {
      await tester.pump(const Duration(milliseconds: 100));
      found = finder.evaluate().isNotEmpty;
    } while (!found && DateTime.now().difference(start) < timeout);

    expect(found, isTrue, reason: 'Element $finder not found within $timeout');
  }

  /// Helper method to enter credentials into login form
  static Future<void> enterCredentials(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    // Find and enter email
    final emailFieldFinder = find.byKey(const Key('emailField'));
    await tester.ensureVisible(emailFieldFinder);
    await tester.enterText(emailFieldFinder, email);
    
    // Find and enter password
    final passwordFieldFinder = find.byKey(const Key('passwordField'));
    await tester.ensureVisible(passwordFieldFinder);
    await tester.enterText(passwordFieldFinder, password);
    
    await tester.pumpAndSettle();
  }
}