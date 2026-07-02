import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mboa_mench/main.dart';
import 'package:mboa_mench/core/router/app_router.dart';
import 'package:mboa_mench/core/providers/app_providers.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final testRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('MBOA MENCH')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          routerProvider.overrideWith((ref) => testRouter),
        ],
        child: const MboaMenchApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('MBOA MENCH'), findsOneWidget);
  });
}
