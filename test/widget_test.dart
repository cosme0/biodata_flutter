import 'package:flutter_test/flutter_test.dart';

import 'package:biodata_app/main.dart';

void main() {
  testWidgets('Biodata form renders', (WidgetTester tester) async {
    await tester.pumpWidget(const BiodataApp());

    expect(find.text('Biodata Form'), findsOneWidget);
    expect(find.text('Basic Information'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
  });
}