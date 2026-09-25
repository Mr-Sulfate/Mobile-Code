import 'package:flutter/material.dart';
import 'package:mobile_labs/domain/study_plan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.service, super.key});

  final StudyPlanService service;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StudyPlan _plan = createSampleStudyPlan();
  AnalysisResult<StudyPlanSummary>? _result;
  bool _isLoading = false;

  Future<void> _runAnalysis() async {
    setState(() => _isLoading = true);
    final result = await widget.service.analyze(_plan);
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Машков Матвей Сергеевич',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 2),
            Text(
              'ПИбд-33 · лабораторные 1 и 2',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PlanHeader(plan: _plan),
                  const SizedBox(height: 18),
                  Text(
                    'Учебные задачи',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._plan.sortedByPriority().map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TaskCard(task: task),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: const Key('analyzeButton'),
                    onPressed: _isLoading ? null : _runAnalysis,
                    icon: _isLoading
                        ? SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.bolt_rounded),
                    label: Text(
                      _isLoading
                          ? 'Выполняется Future...'
                          : 'Запустить анализ Future',
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _result == null
                        ? const SizedBox.shrink()
                        : Padding(
                            key: const Key('analysisResult'),
                            padding: const EdgeInsets.only(top: 14),
                            child: _AnalysisCard(result: _result!),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.plan});

  final StudyPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercent = (plan.progress * 100).round();

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'План подготовки',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Пример на Dart считает прогресс и выбирает следующую задачу.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: plan.progress,
                      backgroundColor: theme.colorScheme.surface.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$progressPercent%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${plan.completedHours} из ${plan.totalHours} часов завершено',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final StudyTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (task.status) {
      StudyTaskStatus.done => (Icons.check_circle_rounded, Colors.green),
      StudyTaskStatus.inProgress => (Icons.timelapse_rounded, Colors.orange),
      StudyTaskStatus.planned => (Icons.schedule_rounded, Colors.blueGrey),
    };

    return Card(
      color: theme.colorScheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text('${task.status.label} · ${task.durationHours} ч.'),
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.result});

  final AnalysisResult<StudyPlanSummary> result;

  @override
  Widget build(BuildContext context) {
    final summary = result.value;
    final statusText = StudyTaskStatus.values
        .map((status) => '${status.label}: ${summary.statusCounts[status]}')
        .join(' · ');

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_graph_rounded),
                SizedBox(width: 8),
                Text(
                  'Результат асинхронного анализа',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Следующая задача: ${summary.nextTaskTitle}'),
            const SizedBox(height: 4),
            Text('Осталось: ${summary.remainingHours} ч.'),
            const SizedBox(height: 4),
            Text(statusText),
          ],
        ),
      ),
    );
  }
}
