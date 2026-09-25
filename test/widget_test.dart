import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_labs/app.dart';
import 'package:mobile_labs/domain/study_plan.dart';

void main() {
  testWidgets('показывает данные студента и результат Future', (tester) async {
    await tester.pumpWidget(
      const MobileLabsApp(service: StudyPlanService(delay: Duration.zero)),
    );

    expect(find.text('Машков Матвей Сергеевич'), findsOneWidget);
    expect(find.text('ПИбд-23 · лабораторные 1 и 2'), findsOneWidget);

    final analyzeButton = find.byKey(const Key('analyzeButton'));
    await tester.ensureVisible(analyzeButton);
    await tester.pumpAndSettle();
    await tester.tap(analyzeButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('analysisResult')), findsOneWidget);
    expect(find.textContaining('Осталось: 9 ч.'), findsOneWidget);
  });
}
