import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cashiere_system/core/theme/app_theme.dart';

void main() {
  testWidgets('App theme builds and applies correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: Text('Cashiere System')),
        ),
      ),
    );

    expect(find.text('Cashiere System'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
