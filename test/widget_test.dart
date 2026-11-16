import 'package:flutter_test/flutter_test.dart';
import 'package:movequest/main.dart';

void main() {
  testWidgets('Welcome screen loads', (tester) async {
    await tester.pumpWidget(const MoveQuestApp());

    expect(find.text('MoveQuest'), findsOneWidget);
    expect(find.text('Click to Start'), findsOneWidget);
  });

  testWidgets('Welcome screen navigates to Home', (tester) async {
    await tester.pumpWidget(const MoveQuestApp());

    await tester.tap(find.text('Click to Start'));
    await tester.pumpAndSettle();

    expect(find.text('Meet Spud!'), findsOneWidget);
    expect(find.text('Start Adventure'), findsOneWidget);
  });

  testWidgets('Adventure button displays placeholder message',
      (tester) async {
    await tester.pumpWidget(const MoveQuestApp());

    await tester.tap(find.text('Click to Start'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Adventure'));
    await tester.pump();

    expect(
      find.text('Adventure Map is coming next!'),
      findsOneWidget,
    );
  });
}
