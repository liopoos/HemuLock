# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
HemuLock is a macOS menu bar application that monitors system events (lock/unlock, sleep/wake) and triggers notifications or scripts. It is built with Swift 5, targeting macOS 11+.

## Common Development Tasks

### Building
This is an Xcode-based Swift project.
- **Open Project**: Open `HemuLock.xcodeproj` in Xcode.
- **Scheme**: Use the "HemuLock" scheme (not HemuLockHelper).
- **Build**: `Cmd+B` or `Product > Build` in Xcode.
- **Run**: `Cmd+R` or `Product > Run` in Xcode.

**Command-line build:**
```bash
# Build from terminal
xcodebuild -project HemuLock.xcodeproj -scheme HemuLock -configuration Release build

# Clean build
xcodebuild -project HemuLock.xcodeproj -scheme HemuLock clean

# Build and archive (for distribution)
xcodebuild -project HemuLock.xcodeproj -scheme HemuLock archive -archivePath HemuLock.xcarchive
```

### Testing
- No test targets are currently configured in the project.

### Linting
- No SwiftLint configuration file (`.swiftlint.yml`) found, so no linting is currently configured.

### Local Code Signing
If you encounter signature issues when running the app locally:
```bash
xcode-select --install
sudo codesign --force --deep --sign - /Applications/HemuLock.app/
```

## High-Level Code Architecture and Structure

### Architecture Pattern
The application follows a layered, event-driven architecture with clear separation of concerns.

**Core Components:**
- **Entry Point** (`HemuLock/AppDelegate.swift`): Initializes the application, creates the menu bar icon, and sets up the `EventObserver`.
- **Event System** (`HemuLock/EventObserver.swift`): The central component that observes 6 macOS system events (Screen Sleep/Wake, System Sleep/Wake, System Lock/Unlock) using `NSWorkspace` and `DistributedNotificationCenter`. It dispatches actions to record events, send notifications, or execute scripts, respecting "Do Not Disturb" mode.
- **State Management**:
    - `HemuLock/AppStateContainer.swift`: A single global state holder (`appState`) accessible app-wide.
    - `HemuLock/Models/AppConfig.swift`: Defines the main application configuration structure.
    - `HemuLock/Managers/DefaultsManager.swift`: Handles persistence of `AppConfig` to `UserDefaults` using DefaultsKit. Configuration changes via `appState` automatically persist.
- **Manager Layer** (`HemuLock/Managers/`): Contains stateless business logic components:
    - `NotifyManager.swift`: Handles HTTP requests to notification services (Pushover, Bark, ServerCat) via Moya.
    - `ScriptManager.swift`: Executes user-defined bash scripts from a sandboxed directory (`~/Library/Application Scripts/com.cyberstack.HemuLock/script`).
    - `DisturbModeManager.swift`: Manages the time-based "Do Not Disturb" logic.
    - `SQLiteManager.swift`: A wrapper for SQLite.swift to manage database connections.
    - `DefaultsManager.swift`: A wrapper for DefaultsKit for `UserDefaults` persistence.
- **Repository Pattern** (`HemuLock/Repository/RecordRepository.swift`): Provides CRUD operations for event history, abstracting direct database interactions using `SQLite.swift`.
- **API Layer** (`HemuLock/API/NotifyAPI.swift`): Defines `Moya.TargetType` implementations for interacting with the various notification service APIs.
- **View Layer** (`HemuLock/Views/Preference/`): Contains SwiftUI views for the application's preferences panels (General, Notify, Do Not Disturb, History).
- **Enums** (`HemuLock/Enums/`): Provides type safety and organization for `Event` types, `Notify` service types, `MenuItem` tags, and `NotifyError` types.

### Key Technical Details

- **C/Swift Bridge**: `sleep.c/h` is exposed via `HemuLock-Bridging-Header.h` and used for IOKit power management calls (`sleepNow()`).
- **Menu System**: `MenuController` defines the static menu structure. Dynamic elements (e.g., history items, checkmarks) are updated in `AppDelegate.menuWillOpen()`.
- **Localization**: User-facing strings use `.localized` extensions, with keys mapping to `en.lproj` and `zh-Hans.lproj` files.
- **Sandboxing**: Scripts must reside in `~/Library/Application Scripts/com.cyberstack.HemuLock/script` (a file, not a folder). The script receives the event name as its first argument (e.g., `$1 = "SYSTEM_LOCK"`).

### File Organization
```
HemuLock/
├── AppDelegate.swift         # Entry point, menu delegate
├── AppStateContainer.swift   # Global state holder
├── EventObserver.swift       # Core event handling
├── Enums/                    # Tag-based enums (Event, MenuItem, Notify)
├── Managers/                 # Stateless business logic
├── Models/                   # Codable data structures
├── Repository/               # Database access layer
├── API/                      # Moya TargetType definitions
├── Views/Preference/         # SwiftUI settings panels
└── Resources/config.json     # Unused legacy file
├── Assets.xcassets/          # App icons and images
├── *.lproj/                  # Localization files (en, zh-Hans)
├── sleep.c / sleep.h         # C bridge for IOKit
├── Info.plist                # App metadata
└── HemuLock.entitlements     # Sandbox permissions
```

### Development Workflow
- **Adding Events**: Add a case to the `Event` enum and update localization files. `EventObserver` automatically handles new events.
- **Adding Notify Services**: Add a case to `NotifyAPI` enum, a config struct to `NotifyConfig`, update `NotifyManager.send()` and `Notify` enum.
- **Config Updates**: Always update via `appState.appConfig` to ensure auto-persistence through `DefaultsManager`.

### Dependencies (Swift Package Manager)
- `Alamofire`, `Moya` (networking)
- `DefaultsKit` (UserDefaults wrapper)
- `SQLite.swift` (database)
- `LaunchAtLogin`, `Settings` (sindresorhus utilities)
- `SkyLightWindow` (overlay views - currently experimental)

## Important Notes from Copilot Instructions

- **Config Updates**: Always update configuration via `appState.appConfig` for auto-persistence; direct `DefaultsManager.shared.setConfig(...)` bypasses observation.
- **Error Handling**: Throw custom `NotifyError` enums for user-facing issues. Catch in `EventObserver` and send system notifications as fallback. Use `try?` for non-critical operations.
- **Menu Updates**: Never cache `NSMenuItem` references; lookup by tag each time (e.g., `mainMenu.items.first { $0.tag == ... }`).
- **Gotchas**:
    - `Event.screenSeeep` typo is preserved for compatibility.
    - System lock/unlock use `DistributedNotificationCenter`, others use `NSWorkspace`.
    - `LaunchAtLogin` updates require manual entitlement configuration in Xcode.
    - Historical records are limited to 12 items in UI.
