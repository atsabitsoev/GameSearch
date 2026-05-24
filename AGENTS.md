# AGENTS.md — GameSearch

Инструкции для AI-агента (Cursor / Codex / Claude) по работе с этим iOS-проектом.

## Проект

- **Имя**: GameSearch (iOS-приложение, SwiftUI, iOS 18+)
- **Корень**: `/Users/atsamaz/Documents/GameSearch`
- **Xcode-проект**: `GameSearch.xcodeproj` (без workspace, SPM-зависимости вшиты в проект)
- **Основная схема**: `GameSearch`
- **Bundle ID**: `com.bitsoev.gamesearchea`
- **Зависимости**: Firebase (Firestore, Core), AppMetrica, SwiftSoup, CachedAsyncImage, локальный SPM-пакет `AnalyticsModule`
- **Симулятор по умолчанию**: `iPhone 17 Pro` — `8A4A9C9D-01CB-4E07-962D-8C3E58E3ED14`

## Подключённые MCP-серверы

В проекте работают **два MCP** одновременно. Чёткое разделение обязанностей:

| Сервер | Назначение | Когда использовать |
|---|---|---|
| `xcode-tools` (Apple, `xcrun mcpbridge`) | Build, test, навигация по проекту, диагностика | Любые операции, требующие реальной модели проекта в открытом Xcode |
| `XcodeBuildMCP` (community) | Симулятор, UI-автоматизация, логи, LLDB-дебаг | Всё что вокруг симулятора и runtime |

> **Правило конфликта**: если задачу могут выполнить оба сервера (build, test, get_build_log) — **всегда выбирай `xcode-tools`**. `XcodeBuildMCP` использовать **только** для того, чего нет у Apple-bridge.

### Что должно быть включено перед началом работы

1. Xcode запущен, проект `GameSearch.xcodeproj` открыт.
2. В Xcode → Settings → Intelligence → Model Context Protocol → **"Allow external agents to use Xcode tools" = ON**.
3. При первом подключении агента Xcode покажет alert — подтвердить.
4. На статус-баре Xcode загорится индикатор внешнего подключения.

Если индикатора нет — `xcode-tools` не подключился, build/test делать через него бессмысленно (упадёт).

---

## Сборка и тесты — через `xcode-tools`

Apple-bridge оперирует **открытым в Xcode проектом**, дополнительных параметров обычно не нужно.

| Действие | Инструмент `xcode-tools` |
|---|---|
| Сборка активной схемы | `BuildProject` |
| Прочитать build-лог | `GetBuildLog` |
| Запустить все тесты | `RunAllTests` |
| Запустить конкретные тесты | `RunSomeTests` |
| Список тестов | `GetTestList` |
| Получить диагностику Navigator | `XcodeListNavigatorIssues` |
| Перечитать ошибки в файле | `XcodeRefreshCodeIssuesInFile` |
| Файловые операции внутри проекта | `XcodeRead/Write/Update/Glob/Grep/LS/MakeDir/RM/MV` |

> Для правок исходников **в проекте** предпочитай `XcodeWrite/Update/Edit` Apple-bridge — он гарантированно обновит индекс Xcode и Navigator увидит изменения мгновенно. Cursor-овский Write/Edit тоже работает, но индекс Xcode может отстать до ручного редактирования любого файла в Xcode.

---

## Симулятор — через `XcodeBuildMCP`

XcodeBuildMCP читает дефолты из переменных окружения (см. `~/.cursor/mcp.json`), поэтому большинство команд можно вызывать без аргументов. Если что-то не подхватилось — один раз выполни:

```
session_use_defaults_profile({ global: true, persist: true })
```

### Полный цикл «собрать → поставить → запустить»

Поскольку build делает Apple-bridge, в XcodeBuildMCP нужны только установка и запуск:

```
1. get_sim_app_path({ })                  → путь к .app после успешного BuildProject
2. open_sim({ })                          → открыть Simulator.app (один раз за сессию)
3. boot_sim({ })                          → если симулятор выключен
4. install_app_sim({ appPath })
5. launch_app_sim({ bundleId: "com.bitsoev.gamesearchea" })
```

### UI и взаимодействие

| Задача | Инструмент |
|---|---|
| Скриншот | `screenshot` |
| Древо UI (accessibility) | `snapshot_ui` |
| Тап / свайп | `gesture` |
| Долгое нажатие | `long_press` |
| Аппаратные кнопки (Home, Lock, Volume) | `button` |
| Ввод текста через клавиатуру | `key_sequence` / `key_press` |
| Запись видео | `record_sim_video` |

> Перед `screenshot`/`snapshot_ui` убедись, что приложение в foreground (`launch_app_sim` сделает это). Для координат тапов сначала бери `snapshot_ui` — там есть точные frame'ы элементов, не угадывай по скриншоту.

### Остановка / перезапуск

```
stop_app_sim({ bundleId: "com.bitsoev.gamesearchea" })
launch_app_sim({ bundleId: "com.bitsoev.gamesearchea" })
```

---

## Логи приложения

Используй workflow `logging` из XcodeBuildMCP:

- стартовать поток логов конкретного приложения — на запуске `launch_app_sim` есть опция `captureLogs: true`, она вернёт `sessionId`;
- остановить и получить дамп — `stop_log_capture({ sessionId })`;
- для системных логов симулятора — `xcrun simctl spawn <UUID> log stream --predicate 'subsystem == "com.bitsoev.gamesearchea"'` через `Shell` (как fallback).

---

## Дебаггинг (LLDB через XcodeBuildMCP)

Только runtime-дебаг. Для статического анализа кода — `XcodeListNavigatorIssues` Apple-bridge.

### Сценарий A: подключиться к уже запущенному приложению

```
1. launch_app_sim({ bundleId, waitForDebugger: false })
2. debug_attach_sim({ bundleId: "com.bitsoev.gamesearchea" })
3. debug_breakpoint_add({ file: "GameSearch/.../SomeFile.swift", line: 42 })
4. debug_continue({ })
5. ... ждёшь срабатывания ...
6. debug_stack({ })          → текущий стек
7. debug_variables({ })      → локальные переменные / self
8. debug_lldb_command({ command: "po viewModel" })   → произвольная команда LLDB
9. debug_detach({ })
```

### Сценарий B: ловить bug на самом старте (до `application(_:didFinishLaunching…)`)

```
1. debug_breakpoint_add(...)        ← добавить breakpoint заранее
2. launch_app_sim({ bundleId, waitForDebugger: true })
3. debug_attach_sim({ bundleId })   ← приложение зависнет до коннекта
4. debug_continue({ })              ← после этого пойдёт init
```

### Полезные LLDB-команды через `debug_lldb_command`

| Команда | Зачем |
|---|---|
| `po <expr>` | Pretty-print любого Swift-выражения |
| `expr -l swift -- <expr>` | Выполнить Swift код в контексте паузы |
| `bt all` | Стеки всех потоков |
| `thread list` | Список потоков |
| `frame variable -R` | Сырое представление переменных фрейма |
| `image lookup -rn <pattern>` | Найти символ по regex |
| `breakpoint list` / `breakpoint disable <id>` | Управление точками без удаления |

### Анализ креша

```
1. debug_attach_sim({ bundleId })
2. ... падает ...
3. debug_lldb_command({ command: "thread info" })    ← reason / signal
4. debug_stack({ })                                  ← где именно
5. debug_lldb_command({ command: "register read" })  ← если EXC_BAD_ACCESS
6. debug_detach({ })
```

---

## Известные подводные камни

1. **XcodeBuildMCP build падает на этом проекте** с `Incremental build using xcodemake failed`. Это конфликт инкрементального wrapper'а с тяжёлыми SPM-зависимостями (Firebase + AppMetrica + gRPC). Решение: **не билди через `XcodeBuildMCP`** — для build только `xcode-tools`. Если по какой-то причине нужно build именно через XcodeBuildMCP — сначала `session_set_defaults({ preferXcodebuild: true, persist: true })`.
2. **Активный профиль XcodeBuildMCP**. По умолчанию активен именованный профиль `GameSearch`, который пустой. Один раз: `session_use_defaults_profile({ global: true, persist: true })`. Тогда `(default)` подхватит переменные из `mcp.json`.
3. **Симулятор архитектуры**. Сборка идёт под `x86_64-apple-ios18.0-simulator` (через Rosetta), это нормально. Если нужно нативно arm64 — в session defaults `arch: "arm64"`.
4. **Не открыт Xcode** ⇒ `xcode-tools` не работает. mcpbridge цепляется только к запущенному и открытому проекту.
5. **Firebase warning**: предупреждение `Metadata extraction skipped. No AppIntents.framework dependency found` — безобидное, игнорируем.
6. **Симулятор не реагирует на жесты** ⇒ скорее всего, приложение не в foreground. Сделай `launch_app_sim` ещё раз или `open_sim`.

---

## Хороший типичный workflow для агента

Задача «исправь баг X и проверь на симуляторе»:

```
1. XcodeGrep / XcodeRead     (xcode-tools)   найти место
2. XcodeWrite / XcodeUpdate  (xcode-tools)   исправить
3. BuildProject              (xcode-tools)   собрать
4. GetBuildLog               (xcode-tools)   если упало — разобрать
5. get_sim_app_path / install_app_sim / launch_app_sim   (XcodeBuildMCP)
6. snapshot_ui + screenshot  (XcodeBuildMCP) подтвердить визуально
7. (опционально) debug_attach_sim + breakpoint + variables   (XcodeBuildMCP)
```

Задача «расследуй краш»:

```
1. launch_app_sim                              (XcodeBuildMCP)
2. debug_attach_sim                            (XcodeBuildMCP)
3. воспроизвести руками или жестами            (XcodeBuildMCP gesture/button)
4. debug_stack + debug_variables + lldb po     (XcodeBuildMCP)
5. найти файл — XcodeRead / XcodeGrep          (xcode-tools)
6. исправить — XcodeWrite                      (xcode-tools)
7. BuildProject → install → launch → проверить
```
