// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:iot_demo/main.dart';

void main() {
  testWidgets('IoT Demo app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IoTDemoApp());

    // Verify that the app loads with device list
    expect(find.text('设备列表'), findsOneWidget);
    expect(find.text('数据监控'), findsOneWidget);
    expect(find.text('设备控制'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
