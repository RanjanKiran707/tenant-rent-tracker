import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/main.dart';

void main() {
  testWidgets('app shows the title', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Rent Book'), findsOneWidget);
  });
}
