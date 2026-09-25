import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_labs/domain/study_plan.dart';

void main() {
  group('StudyPlan', () {
    test('считает часы, прогресс и количество задач', () {
      final plan = createSampleStudyPlan();

      expect(plan.totalHours, 11);
      expect(plan.completedHours, 2);
      expect(plan.progress, closeTo(2 / 11, 0.0001));
      expect(plan.countByStatus(), {
        StudyTaskStatus.planned: 2,
        StudyTaskStatus.inProgress: 1,
        StudyTaskStatus.done: 1,
      });
    });

    test('ставит текущую задачу первой', () {
      final plan = createSampleStudyPlan();

      expect(plan.sortedByPriority().first.status, StudyTaskStatus.inProgress);
    });
  });

  test('StudyPlanService асинхронно формирует сводку', () async {
    const service = StudyPlanService(delay: Duration.zero);

    final result = await service.analyze(createSampleStudyPlan());

    expect(result.value.remainingHours, 9);
    expect(result.value.nextTaskTitle, 'Изучить основы языка Dart');
    expect(result.map((summary) => summary.remainingHours), 9);
  });
}
