import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('shows both checkout entry points', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Fincra SDK Example'), findsOneWidget);
    expect(find.text('Pay with WebView Checkout'), findsOneWidget);
    expect(find.text('Pay with Inline Checkout'), findsOneWidget);
  });
}
