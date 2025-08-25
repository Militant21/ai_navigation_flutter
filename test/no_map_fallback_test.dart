import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:ai_navigation_flutter/app.dart';
import 'package:ai_navigation_flutter/screens/no_map_fallback.dart';
import 'package:ai_navigation_flutter/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel pathProvider =
      MethodChannel('plugins.flutter.io/path_provider');

  Future<void> _mockDocsDir(String path) async {
    ServicesBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProvider,
      (MethodCall call) async {
        switch (call.method) {
          case 'getApplicationDocumentsDirectory':
            return path;
          case 'getTemporaryDirectory':
            return Directory.systemTemp.path;
          case 'getApplicationSupportDirectory':
            return path;
        }
        return null;
      },
    );
  }

  testWidgets('NoMapFallback when no map files present', (tester) async {
    final dir = await Directory.systemTemp.createTemp('aimaps_nomap_');
    await _mockDocsDir(dir.path);

    await tester.pumpWidget(const AiNavApp());
    await tester.pumpAndSettle();

    expect(find.byType(NoMapFallback), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('HomeScreen when at least one map file exists', (tester) async {
    final dir = await Directory.systemTemp.createTemp('aimaps_withmap_');
    // tegyünk be egy üres .pmtiles fájlt – elég a jelenlét
    await File('${dir.path}/dummy.pmtiles').writeAsString('');
    await _mockDocsDir(dir.path);

    await tester.pumpWidget(const AiNavApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
