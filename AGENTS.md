# AGENTS.md

This file provides coding guidelines and development commands for AI coding agents working in the HemuLock repository.

## Project Overview
HemuLock is a macOS menu bar application (Swift 5, macOS 11+) that monitors system events (lock/unlock, sleep/wake) and triggers notifications or scripts. It follows an event-driven, layered architecture with clear separation of concerns.

## Build, Lint, and Test Commands

### Building
```bash
# Open project in Xcode
open HemuLock.xcodeproj

# Command-line build (Release)
xcodebuild -project HemuLock.xcodeproj -scheme HemuLock -configuration Release build

# Command-line build (Debug)
xcodebuild -project HemuLock.xcodeproj -scheme HemuLock -configuration Debug build

# Clean build
xcodebuild -project HemuLock.xcodeproj -scheme HemuLock clean

# Build and archive for distribution
xcodebuild -project HemuLock.xcodeproj -scheme HemuLock archive -archivePath HemuLock.xcarchive
```

**Important**: Use the "HemuLock" scheme, NOT "HemuLockHelper".

### Testing
- No test targets are currently configured in this project.
- Manual testing requires running the app in Xcode (Cmd+R) or building and running the .app bundle.

### Linting
- No SwiftLint configuration (`.swiftlint.yml`) exists.
- No formal linting is currently enforced.
- Follow the code style guidelines below to maintain consistency.

### Code Signing (Local Development)
If you encounter signature issues when running locally:
```bash
xcode-select --install
sudo codesign --force --deep --sign - /Applications/HemuLock.app/
```

## Code Style Guidelines

### File Header Comments
All Swift files begin with a standard header:
```swift
//
//  FileName.swift
//  HemuLock
//
//  Created by [author] on [date].
//
```

### Imports
- Group imports alphabetically.
- Foundation/AppKit/Cocoa imports come first, followed by third-party frameworks.
- Use specific imports when possible (e.g., `import Foundation` not `import Cocoa` if only Foundation is needed).
- Common imports: `Foundation`, `AppKit`, `Cocoa`, `SwiftUI`, `Logging`, `Moya`, `SQLite`, `DefaultsKit`, `LaunchAtLogin`, `Settings`.

Example:
```swift
import AppKit
import Foundation
import Logging
import UserNotifications
```

### Formatting
- **Indentation**: 4 spaces (no tabs).
- **Line Length**: No strict limit, but aim for readability (~120 chars when practical).
- **Braces**: Opening brace on same line as declaration.
- **Spacing**: Single blank line between methods/sections; two lines between major sections.
- **MARK Comments**: Use `// MARK: - Section Name` to organize code within files.

### Types
- **Type Inference**: Use Swift's type inference where unambiguous.
- **Explicit Types**: Declare types when it improves clarity or is required (e.g., enum raw values, protocol conformance).
- **Structs vs Classes**: Use `struct` for models/value types (e.g., `AppConfig`, `Record`). Use `class` for reference types, managers, singletons, and objects with lifecycle (e.g., `EventObserver`, `NotifyManager`).
- **Enums**: Use for type-safe constants (e.g., `Event`, `Notify`, `MenuItem`). Enums should have `rawValue` and/or `tag` properties for persistence/identification.

### Naming Conventions
- **Types/Classes/Structs/Enums**: PascalCase (e.g., `EventObserver`, `AppConfig`, `NotifyError`).
- **Functions/Variables/Properties**: camelCase (e.g., `handleEvent`, `isExecScript`, `mainMenu`).
- **Constants**: camelCase for local/instance constants, PascalCase for global/static (rare).
- **Singletons**: Use `static let shared = ClassName()` pattern.
- **Booleans**: Prefix with `is`, `has`, `should`, or `can` (e.g., `isLaunchAtLogin`, `isRecordEvent`).
- **Manager Classes**: Suffix with `Manager` (e.g., `NotifyManager`, `ScriptManager`, `DisturbModeManager`).
- **Enums**: Use descriptive case names. Raw values are UPPERCASE_SNAKE_CASE for localization keys (e.g., `"SYSTEM_LOCK"`).

### Documentation Comments
Use triple-slash (`///`) or block doc comments (`/** ... */`) for public APIs and complex logic:
```swift
/**
 Brief description.
 
 Detailed explanation (optional).
 
 - Parameters:
   - param1: Description
   - param2: Description
   
 - Returns: Description
 - Throws: Description of errors thrown
 */
func exampleMethod(param1: String, param2: Int) throws -> Bool {
    // Implementation
}
```

Use inline comments (`//`) sparingly for clarifications:
```swift
// Screen sleep observer
NSWorkspace.shared.notificationCenter.addObserver(...)
```

### Error Handling
- **Custom Errors**: Define domain-specific error enums (e.g., `NotifyError`, `DatabaseError`).
- **Throwing**: Use `throws` for expected, recoverable errors.
- **Try?**: Use `try?` for non-critical operations where failure can be safely ignored (e.g., optional script execution, DB writes).
- **Try!**: Avoid `try!` except for truly fatal errors or during initialization where failure is unrecoverable.
- **Catching**: Catch errors at boundaries (e.g., in `EventObserver.handleEvent`) and provide fallback behavior (e.g., system notifications).

Example:
```swift
do {
    try NotifyManager.shared.send(title: "Title", message: "Message")
} catch NotifyError.invalidConfig {
    logger.error("Invalid notification config")
    SystemNotificationManager.shared.sendNotification(title: "Error", body: "CONFIG_INVALID".localized)
} catch {
    logger.error("Notification failed: \(error)")
}
```

### State Management
- **Global State**: Use the single `appState` global variable (`AppStateContainer` instance).
- **Configuration Updates**: ALWAYS update config via `appState.appConfig.property = value` to trigger auto-persistence. NEVER call `DefaultsManager.shared.setConfig(...)` directly.
- **@Published**: `AppStateContainer` uses `@Published` for SwiftUI reactivity. Changes to `appConfig` automatically persist via `didSet`.
- **@EnvironmentObject**: SwiftUI views access state via `@EnvironmentObject var appState: AppStateContainer`.

Correct:
```swift
appState.appConfig.isExecScript = true  // ✅ Triggers didSet, auto-saves
```

Incorrect:
```swift
DefaultsManager.shared.setConfig(...)  // ❌ Bypasses observation
```

### Singletons and Managers
- All managers follow the singleton pattern: `static let shared = ManagerName()`.
- Managers are stateless business logic components (no mutable instance state beyond dependencies).
- Manager methods should be instance methods on `shared`, not static methods.

### Logging
- Use the `Logging` framework via `LogManager`.
- Each class should have a private logger: `private let logger = LogManager.shared.logger(for: "ClassName")`.
- Log levels: `trace`, `debug`, `info`, `notice`, `warning`, `error`, `critical`.
- Use structured logging: `logger.info("Event triggered: \(event.name)")`.

### Localization
- All user-facing strings use `.localized` extension: `"SYSTEM_LOCK".localized`.
- Localization keys are UPPERCASE_SNAKE_CASE.
- Keys defined in `en.lproj/Localizable.strings` and `zh-Hans.lproj/Localizable.strings`.

## Architecture Guidelines

### Event-Driven Core
- `EventObserver` is the central event handler using `NSWorkspace.notificationCenter` and `DistributedNotificationCenter`.
- All events defined in `Event` enum map to macOS notification names.
- Event flow: System → EventObserver → (Record + Notify + Script) based on config.

### Manager Pattern
- Isolate business logic in `Managers/` (e.g., `NotifyManager`, `ScriptManager`, `DisturbModeManager`).
- Managers are stateless and use singleton pattern.

### Repository Pattern
- `RecordRepository` is the single source for event history CRUD.
- Returns domain `Record` models, never raw SQLite types.

### Menu System
- `MenuController.createMenu()` builds static menu structure with enum-based tags.
- `AppDelegate.menuWillOpen()` updates dynamic state (checkmarks, history items).
- **Never cache `NSMenuItem` references**—always look up by tag: `menu.item(withTag:)`.

### SwiftUI Views
- Use `Settings.Pane` for preference panels.
- Access state via `@EnvironmentObject var appState: AppStateContainer`.
- Inject `appState` via `.environmentObject(appState)`.

## Important Gotchas

1. **Typo Preserved**: `Event.screenSeeep` (typo in "sleep") is preserved for backward compatibility. Do not "fix" this.
2. **Notification Centers**: System lock/unlock use `DistributedNotificationCenter.default`; all other events use `NSWorkspace.shared.notificationCenter`.
3. **Script Path**: Scripts must be at `~/Library/Application Scripts/com.cyberstack.HemuLock/script` (a **file**, not a directory).
4. **History Limit**: UI displays only 12 most recent event records (no pagination).
5. **LaunchAtLogin**: Requires manual entitlement configuration in Xcode if updating.
6. **Legacy File**: `Resources/config.json` is unused—config stored in UserDefaults only.

## Dependencies (Swift Package Manager)
- `Alamofire` 5.8.1, `Moya` 15.0.3 (networking)
- `DefaultsKit` (UserDefaults wrapper, master branch)
- `SQLite.swift` 0.14.1 (database)
- `LaunchAtLogin`, `Settings` 3.1.0 (sindresorhus utilities)
- `swift-log` (logging)
- `ReactiveSwift` 6.7.0, `RxSwift` 6.6.0 (Moya dependencies)

## Development Workflows

### Adding a New Event
1. Add case to `Event` enum with `rawValue`, `tag`, and `notification` mapping.
2. Update localization files (`Localizable.strings` in `en.lproj` and `zh-Hans.lproj`).
3. No changes needed to `EventObserver`—automatically handled via `Event.allCases`.

### Adding a New Notification Service
1. Add `Moya.TargetType` case to `NotifyAPI` enum (baseURL, path, method, task).
2. Add config struct to `NotifyConfig` model with required API parameters.
3. Update `NotifyManager.send()` switch statement with new case and validation.
4. Add entry to `Notify` enum with unique `tag`.
5. Update preference view to add UI for new service configuration.

### Config Updates
Always update via `appState.appConfig` for auto-persistence. Direct `DefaultsManager.setConfig()` bypasses observation.

## References
- Additional architecture details: See `CLAUDE.md` and `.github/copilot-instructions.md`.
- Project repo: https://github.com/liopoos/HemuLock
