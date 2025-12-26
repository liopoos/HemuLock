# HemuLock AI Coding Instructions

## Project Overview
HemuLock is a macOS menu bar application that monitors system events (lock/unlock, sleep/wake) and triggers notifications or scripts. Built with Swift 5, targeting macOS 10.15+.

## Architecture Pattern

### Event-Driven Core
- **EventObserver**: Central event handler using NSWorkspace & DistributedNotificationCenter
- All 6 system events defined in `Event` enum map to macOS notification names
- Event flow: System → EventObserver → (Record + Notify + Script) based on config

### State Management
- **Global State**: Single `AppStateContainer` instance (`appState`) accessible app-wide
- Uses `@Published` properties with SwiftUI's `ObservableObject` protocol
- All config changes auto-persist via `DefaultsManager` (DefaultsKit wrapper)
- Config stored as single `AppConfig` struct - no partial updates

### Manager Pattern
All business logic isolated in Managers:
- `NotifyManager`: HTTP requests via Moya (Pushover/Bark/ServerCat APIs)
- `ScriptManager`: User script execution in sandboxed directory
- `DisturbModeManager`: Time-based "Do Not Disturb" logic
- `SQLiteManager`: Database wrapper (SQLite.swift)
- `DefaultsManager`: UserDefaults persistence layer

### Repository Pattern
- `RecordRepository`: Single source for event history CRUD
- Owns SQLiteManager instance, creates table on init
- Returns domain `Record` models, never raw SQLite types

## Key Technical Details

### C/Swift Bridge
- `sleep.c/h` exposed via `HemuLock-Bridging-Header.h`
- Used for IOKit power management calls (`sleepNow()`)

### Menu System
- `MenuController` creates static menu structure with enum-based tags
- `AppDelegate.menuWillOpen()` updates dynamic state (checkmarks, history items)
- Tags from `MenuItem` & `Event` enums used for item identification
- History records inserted/removed dynamically at runtime

### Localization
- All user-facing strings use `.localized` extension on String
- Keys like `"SYSTEM_LOCK"` map to 3 `.lproj` folders (en/zh-Hans/base)
- Event names stored as raw values (e.g., "SYSTEM_LOCK") - these are localization keys

### Do Not Disturb
- Time range checked in `DisturbModeManager.inDisturb()` before notify/script execution
- Blocks events during configured weekday hours
- Separate flags for blocking notify vs script (`DoNotDisturbConfig.type`)

### Sandboxing
- Scripts must be in `~/Library/Application Scripts/com.ch.hades.HemuLock/script`
- This is a **file**, not a directory (common mistake)
- Script receives event name as first argument (e.g., `$1 = "SYSTEM_LOCK"`)

## Dependencies (SPM)
```
Alamofire 5.10.2, Moya 15.0.3 (networking)
DefaultsKit (UserDefaults wrapper)
SQLite.swift 0.14.1 (database)
LaunchAtLogin, Settings (sindresorhus utilities)
SkyLightWindow (overlay views - currently experimental)
```

## Development Workflow

### Building
- Open `HemuLock.xcodeproj` in Xcode
- Scheme: HemuLock (not HemuLockHelper)
- Entitlements enable sandboxing - script folder path is restricted

### Adding Events
1. Add case to `Event` enum with tag/notification mapping
2. Update localization files (`Localizable.strings` × 3)
3. No changes needed to EventObserver - auto-handled via `allCases`

### Adding Notify Services
1. Add case to `NotifyAPI` enum with TargetType implementation
2. Add config struct to `NotifyConfig` model
3. Update `NotifyManager.send()` switch statement
4. Add entry to `Notify` enum for menu item

### Testing Notifications
- Use "Send Test Notify" menu item (hidden when notify disabled)
- Fallback to system notifications on API errors
- Check console for Moya request logs

## Common Patterns

### Config Updates
```swift
// Always update via appState for auto-persistence
appState.appConfig.isExecScript = true  // ✅ Triggers didSet
DefaultsManager.shared.setConfig(...)   // ❌ Manual save bypasses observation
```

### Error Handling
- Throw custom `NotifyError` enums for user-facing issues
- Catch in EventObserver and send system notification as fallback
- Use `try?` for non-critical operations (script exec, DB writes)

### Menu Updates
- Never cache NSMenuItem references - lookup by tag each time
- Use `mainMenu.items.first { $0.tag == ... }` pattern
- Submenus updated in `updateSubMenu()` based on current config

## File Organization
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
└── Resources/config.json     # Unused legacy file (TODO: remove)
```

## Gotchas
- `Event.screenSeeep` typo preserved for compatibility (see Event.swift)
- System lock/unlock use DistributedNotificationCenter, others use NSWorkspace
- LaunchAtLogin updates require manual entitlement configuration in Xcode
- SkyLightWindow overlay (in EventObserver) is experimental - currently unused
- Historical records limited to 12 items in UI (no pagination)
