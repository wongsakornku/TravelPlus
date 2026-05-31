import 'package:flutter_test/flutter_test.dart';
import 'package:travel_plus/main.dart';

void main() {
  testWidgets('renders My Trip home screen', (tester) async {
    await tester.pumpWidget(const TravelPlusApp());

    expect(find.text('My Trip'), findsOneWidget);
    expect(find.text('สร้างทริปใหม่'), findsOneWidget);
  });
}
