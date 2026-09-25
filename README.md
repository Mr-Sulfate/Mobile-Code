# Лабораторные работы 1 и 2

Flutter-приложение студента Машкова Матвея Сергеевича, группа ПИбд-33.

## Лабораторная работа 1

- Создан пустой Flutter-проект с обязательной платформой Android.
- В `AppBar` указаны ФИО и группа.
- Проект подготовлен к сборке, тестированию и запуску на Android.

## Лабораторная работа 2

Осмысленный пример представляет план подготовки к мобильной разработке. В
`lib/domain/study_plan.dart` используются:

- классы с полями и методами: `StudyTask`, `StudyPlan`, `StudyPlanService`;
- `enum StudyTaskStatus`;
- циклы `for`;
- generics: `List<StudyTask>` и `AnalysisResult<T>`;
- анонимные функции в `where`, `fold`, `sort` и `map`;
- `Future` в методе `StudyPlanService.analyze`;
- `extension StudyTaskStatusView`.

Пример работает и в интерфейсе приложения, и отдельно в консоли.

## Команды

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
dart run bin/lab2_demo.dart
```

Путь проекта содержит кириллицу. Если Android Gradle Plugin или компилятор
шейдеров сообщает об этом ошибку, используйте обёртку с временными ASCII-путями:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\flutter_project.ps1 analyze
powershell -ExecutionPolicy Bypass -File .\tool\flutter_project.ps1 test
powershell -ExecutionPolicy Bypass -File .\tool\flutter_project.ps1 build apk --debug
powershell -ExecutionPolicy Bypass -File .\tool\flutter_project.ps1 run
```

Готовый debug APK создаётся в `build/app/outputs/flutter-apk/app-debug.apk`.
