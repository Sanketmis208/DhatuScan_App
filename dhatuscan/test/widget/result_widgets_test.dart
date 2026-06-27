import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhatuscan/core/constants/app_colors.dart';
import 'package:dhatuscan/models/result_model.dart';
import 'package:dhatuscan/widgets/result/dhatu_bar_chart.dart';
import 'package:dhatuscan/widgets/result/health_score_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('HealthScoreCard Widget Tests', () {
    testWidgets('renders healthIndex, healthGrade, and balanceStatus correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const HealthScoreCard(
            healthIndex: 75.4,
            healthGrade: 'Good',
            balanceStatus: 'Mild Imbalance',
            isLoading: false,
          ),
        ),
      );

      // Verify text elements are rendered
      expect(find.text('75.4'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Mild Imbalance'), findsOneWidget);
      expect(find.text('Ayurvedic Health Score'), findsOneWidget);
    });

    testWidgets('shows loading shimmer when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const HealthScoreCard(
            isLoading: true,
          ),
        ),
      );

      // Should not find the score text but find shimmer/placeholders
      expect(find.text('75.4'), findsNothing);
      expect(find.byType(HealthScoreCard), findsOneWidget);
    });

    testWidgets('renders different grade strings correctly',
        (WidgetTester tester) async {
      final grades = ['Excellent', 'Good', 'Fair', 'Poor'];

      for (final grade in grades) {
        await tester.pumpWidget(
          _wrap(
            HealthScoreCard(
              healthIndex: 50.0,
              healthGrade: grade,
              balanceStatus: 'Sama Dhatu',
              isLoading: false,
            ),
          ),
        );

        expect(find.text(grade), findsOneWidget);
      }
    });
  });

  group('DhatuBarChart Widget Tests', () {
    testWidgets('assigns correct colors to bar rods based on status',
        (WidgetTester tester) async {
      final vkResults = [
        DhatuVKResult(
          dhatu: 'Rasa',
          vriddhiScore: 2,
          kshayaScore: 1,
          vriddhiMax: 21,
          kshayaMax: 18,
          vriddhiPercent: 10.0,
          kshayaPercent: 50.0,
          vriddhiStatus: 'No Significant Change',
          kshayaStatus: 'Mild',
          dominant: 'Kshaya',
        ),
        DhatuVKResult(
          dhatu: 'Rakta',
          vriddhiScore: 10,
          kshayaScore: 8,
          vriddhiMax: 36,
          kshayaMax: 12,
          vriddhiPercent: 70.0,
          kshayaPercent: 85.0,
          vriddhiStatus: 'Moderate',
          kshayaStatus: 'Severe',
          dominant: 'Kshaya',
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          DhatuBarChart(vkResults: vkResults),
        ),
      );

      // Verify chart container exists
      expect(find.byType(DhatuBarChart), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);

      // Inspect fl_chart configuration via the widget
      final barChartFinder = find.byType(BarChart);
      final BarChart barChartWidget = tester.widget(barChartFinder);
      final data = barChartWidget.data;

      expect(data.barGroups.length, 2);

      // Rod 0 (Vriddhi) for Rasa -> 'No Significant Change' -> Success Color
      expect(data.barGroups[0].barRods[0].color, AppColors.success);
      // Rod 1 (Kshaya) for Rasa -> 'Mild' -> Yellow Color
      expect(data.barGroups[0].barRods[1].color, const Color(0xFFFFCA28));

      // Rod 0 (Vriddhi) for Rakta -> 'Moderate' -> Warning Color
      expect(data.barGroups[1].barRods[0].color, AppColors.warning);
      // Rod 1 (Kshaya) for Rakta -> 'Severe' -> Error Color
      expect(data.barGroups[1].barRods[1].color, AppColors.error);
    });
  });
}
