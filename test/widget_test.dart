import 'package:flutter_test/flutter_test.dart';
import 'package:maranny_two/main.dart';

void main() {
  testWidgets('Maranny app renders the splash screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MARANNY'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
