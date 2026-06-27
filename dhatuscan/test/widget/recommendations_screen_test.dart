import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhatuscan/core/utils/score_calculator.dart';
import 'package:dhatuscan/screens/recommendations/recommendations_screen.dart';

Widget _wrap(Widget child, {List<AffectedDhatu>? arguments}) {
  return MaterialApp(
    onGenerateRoute: (settings) {
      return MaterialPageRoute(
        settings: RouteSettings(arguments: arguments),
        builder: (_) => child,
      );
    },
  );
}

void main() {
  group('RecommendationsScreen Widget Tests', () {
    testWidgets('balanced state (empty list) shows congratulations card and no tiles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const RecommendationsScreen(),
          arguments: [], // Empty list representing Sama Dhatu (balanced)
        ),
      );
      await tester.pumpAndSettle();

      // Should show congratulations text
      expect(find.text('Sama Dhatu (Sustained Balance)'), findsOneWidget);
      expect(find.text('Congratulations! Your Dhatus are in a state of perfect balance. Maintain your healthy lifestyle, pure diet, and regular daily routines.'), findsOneWidget);

      // Should not find any ExpansionTile
      expect(find.byType(ExpansionTile), findsNothing);
    });

    testWidgets('imbalanced state shows Dhatu tiles and all 5 recommendation categories',
        (WidgetTester tester) async {
      final affectedList = [
        AffectedDhatu(
          dhatu: 'Rasa',
          type: 'Vriddhi',
          status: 'Severe',
          percent: 85.0,
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          const RecommendationsScreen(),
          arguments: affectedList,
        ),
      );
      await tester.pumpAndSettle();

      // Should not show congratulations text
      expect(find.text('Sama Dhatu (Sustained Balance)'), findsNothing);

      // Should find the ExpansionTile representing Rasa Vriddhi
      expect(find.byType(ExpansionTile), findsOneWidget);
      expect(find.text('Rasa Dhatu — Vriddhi'), findsOneWidget);
      expect(find.text('Status: Severe'), findsOneWidget);

      // Tap to expand the tile
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Check for the presence of the 5 categories
      expect(find.text('Pathya Aahar (Recommended Diet)'), findsOneWidget);
      expect(find.text('Apathya Aahar (Diet to Avoid)'), findsOneWidget);
      expect(find.text('Pathya Vihara (Recommended Lifestyle)'), findsOneWidget);
      expect(find.text('Apathya Vihara (Lifestyle to Avoid)'), findsOneWidget);
      expect(find.text('Aushadha (Ayurvedic Medicine)'), findsOneWidget);
    });
  });
}
