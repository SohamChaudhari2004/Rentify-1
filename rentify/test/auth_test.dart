import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rentify/services/auth_service.dart';
import 'helper/auth_test_helper.dart';
import 'package:placexext/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Enable test mode before any tests run
  setUpAll(() {
    AuthService.isTestMode = true;
    print('Test mode enabled for all authentication tests');
  });

  group('Authentication Flow Tests', () {
    testWidgets('✅ Login with valid credentials and navigate to home', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Check if starting at splash screen
      final bool startedAtSplash = find.byType(Scaffold).evaluate().isNotEmpty;
      if (startedAtSplash) {
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // If directed to onboarding, tap the "Get Started" button
      final getStartedFinder = find.text('Get Started');
      if (getStartedFinder.evaluate().isNotEmpty) {
        await tester.tap(getStartedFinder);
        await tester.pumpAndSettle();
      }

      // Find the Login tab by type and text
      final loginTabFinder = find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Login'),
      );
      if (loginTabFinder.evaluate().isNotEmpty) {
        await tester.tap(loginTabFinder.first);
        await tester.pumpAndSettle();
      }

      // Wait for login screen to appear
      final emailFieldFinder = find.byKey(const Key('emailField'));
      final passwordFieldFinder = find.byKey(const Key('passwordField'));

      await TestHelper.waitForElement(tester, emailFieldFinder);
      await TestHelper.waitForElement(tester, passwordFieldFinder);

      print('✅ Login form found, entering credentials');

      // Enter valid test credentials
      await TestHelper.enterCredentials(
        tester,
        email: 'test@example.com', // Valid test account
        password: 'Test@123',
      );

      print('✅ Entered credentials');

      // Tap login button
      final loginButtonFinder = find.byKey(const Key('loginButton'));
      await TestHelper.waitForElement(tester, loginButtonFinder);

      await tester.ensureVisible(loginButtonFinder);
      await tester.tap(loginButtonFinder);

      print('✅ Tapped login button');

      // Check for successful login - since we're in test mode, we'll consider the test passed
      // if we go past the login without crashing
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Add a verification that login was successful
      final backButtonFinder = find.byType(BackButton);
      final menuIconFinder = find.byIcon(Icons.menu);

      final bool isEitherFound =
          backButtonFinder.evaluate().isNotEmpty ||
          menuIconFinder.evaluate().isNotEmpty;

      expect(isEitherFound, isTrue, reason: 'Navigation post-login expected');
      print('✅ Successfully logged in and navigated to another screen');
    });

    testWidgets('❌ Login with invalid credentials shows error', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find the Login tab by type and text (using a more specific finder)
      final loginTabFinder = find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Login'),
      );
      if (loginTabFinder.evaluate().isNotEmpty) {
        await tester.tap(loginTabFinder.first);
        await tester.pumpAndSettle();
      }

      // Wait for login form
      final emailFieldFinder = find.byKey(const Key('emailField'));
      final passwordFieldFinder = find.byKey(const Key('passwordField'));

      await TestHelper.waitForElement(tester, emailFieldFinder);
      await TestHelper.waitForElement(tester, passwordFieldFinder);

      // Enter invalid credentials
      await TestHelper.enterCredentials(
        tester,
        email:
            'invalid@example.com', // This will trigger the error in test mode
        password: 'wrongpassword',
      );

      // Tap login button
      final loginButtonFinder = find.byKey(const Key('loginButton'));
      await TestHelper.waitForElement(tester, loginButtonFinder);

      await tester.ensureVisible(loginButtonFinder);
      await tester.tap(loginButtonFinder);

      // Wait for error dialog to appear
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check that an error dialog is shown
      final errorFinder = find.text('Error');
      expect(errorFinder, findsOneWidget);

      print('✅ Error dialog shown for invalid credentials');

      // Dismiss the dialog
      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }
});
});
}
