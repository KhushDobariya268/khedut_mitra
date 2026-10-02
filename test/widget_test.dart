import 'package:flutter_test/flutter_test.dart';
import 'package:khedut_mitra/main.dart';

void main() {
  testWidgets('App renders welcome screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const KhedutMitraApp());
    expect(find.text('ખેડૂત મિત્ર'), findsWidgets);
  });
}
