// ignore_for_file: avoid_print

import 'package:mobile_labs/domain/study_plan.dart';

Future<void> main() async {
  final plan = createSampleStudyPlan();
  final service = StudyPlanService(delay: Duration.zero);
  final result = await service.analyze(plan);

  print('Учебный план: ${plan.completedHours}/${plan.totalHours} ч.');
  for (final status in StudyTaskStatus.values) {
    print('${status.label}: ${result.value.statusCounts[status]}');
  }
  print('Следующая задача: ${result.value.nextTaskTitle}');
  print('Осталось часов: ${result.value.remainingHours}');
}
