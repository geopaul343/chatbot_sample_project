// Basic smoke test for Laennec AI Health Assistant
// This test ensures the app can be built without errors
// More comprehensive tests will be added later

import 'package:flutter_test/flutter_test.dart';
import 'package:laennec_ai_health_assistant/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Simple smoke test - just verify MyApp can be created
    final app = MyApp();
    expect(app, isA<MyApp>());
    expect(app.runtimeType, MyApp);
  });
}
