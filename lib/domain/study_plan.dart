enum StudyTaskStatus { planned, inProgress, done }

extension StudyTaskStatusView on StudyTaskStatus {
  String get label => switch (this) {
    StudyTaskStatus.planned => 'Запланировано',
    StudyTaskStatus.inProgress => 'В процессе',
    StudyTaskStatus.done => 'Готово',
  };

  int get priority => switch (this) {
    StudyTaskStatus.inProgress => 0,
    StudyTaskStatus.planned => 1,
    StudyTaskStatus.done => 2,
  };
}

class StudyTask {
  const StudyTask({
    required this.title,
    required this.durationHours,
    required this.status,
  });

  final String title;
  final int durationHours;
  final StudyTaskStatus status;

  bool get isCompleted => status == StudyTaskStatus.done;

  StudyTask copyWith({
    String? title,
    int? durationHours,
    StudyTaskStatus? status,
  }) {
    return StudyTask(
      title: title ?? this.title,
      durationHours: durationHours ?? this.durationHours,
      status: status ?? this.status,
    );
  }
}

class StudyPlan {
  StudyPlan({required List<StudyTask> tasks})
    : tasks = List<StudyTask>.unmodifiable(tasks);

  final List<StudyTask> tasks;

  int get totalHours => tasks.fold(0, (sum, task) => sum + task.durationHours);

  int get completedHours => tasks
      .where((task) => task.isCompleted)
      .fold(0, (sum, task) => sum + task.durationHours);

  double get progress => tasks.isEmpty ? 0 : completedHours / totalHours;

  Map<StudyTaskStatus, int> countByStatus() {
    final counts = <StudyTaskStatus, int>{
      for (final status in StudyTaskStatus.values) status: 0,
    };

    for (final task in tasks) {
      counts.update(task.status, (count) => count + 1);
    }

    return counts;
  }

  List<StudyTask> sortedByPriority() {
    final sortedTasks = List<StudyTask>.of(tasks);
    sortedTasks.sort(
      (first, second) =>
          first.status.priority.compareTo(second.status.priority),
    );
    return sortedTasks;
  }
}

class AnalysisResult<T> {
  const AnalysisResult({required this.value, required this.createdAt});

  final T value;
  final DateTime createdAt;

  R map<R>(R Function(T value) transform) => transform(value);
}

class StudyPlanSummary {
  const StudyPlanSummary({
    required this.statusCounts,
    required this.remainingHours,
    required this.nextTaskTitle,
  });

  final Map<StudyTaskStatus, int> statusCounts;
  final int remainingHours;
  final String nextTaskTitle;
}

class StudyPlanService {
  const StudyPlanService({this.delay = const Duration(milliseconds: 450)});

  final Duration delay;

  Future<AnalysisResult<StudyPlanSummary>> analyze(StudyPlan plan) async {
    await Future<void>.delayed(delay);

    final pendingTasks = <StudyTask>[];
    for (final task in plan.sortedByPriority()) {
      if (!task.isCompleted) {
        pendingTasks.add(task);
      }
    }

    final remainingHours = pendingTasks.fold(
      0,
      (sum, task) => sum + task.durationHours,
    );

    return AnalysisResult<StudyPlanSummary>(
      value: StudyPlanSummary(
        statusCounts: plan.countByStatus(),
        remainingHours: remainingHours,
        nextTaskTitle: pendingTasks.isEmpty
            ? 'Все задачи завершены'
            : pendingTasks.first.title,
      ),
      createdAt: DateTime.now(),
    );
  }
}

StudyPlan createSampleStudyPlan() {
  return StudyPlan(
    tasks: const [
      StudyTask(
        title: 'Настроить Flutter и Android SDK',
        durationHours: 2,
        status: StudyTaskStatus.done,
      ),
      StudyTask(
        title: 'Изучить основы языка Dart',
        durationHours: 4,
        status: StudyTaskStatus.inProgress,
      ),
      StudyTask(
        title: 'Закрепить асинхронное программирование',
        durationHours: 3,
        status: StudyTaskStatus.planned,
      ),
      StudyTask(
        title: 'Подготовить демонстрацию приложения',
        durationHours: 2,
        status: StudyTaskStatus.planned,
      ),
    ],
  );
}
