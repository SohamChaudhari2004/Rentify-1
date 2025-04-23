import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:rentify/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('performance test', (WidgetTester tester) async {
    await tester.pumpWidget(app.MyApp());

    final timeline = await tester.runAsync(() async {
      return await (tester.binding as IntegrationTestWidgetsFlutterBinding).traceTimeline(() async {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
      });
    });

    print('Timeline data captured');
  });
}
