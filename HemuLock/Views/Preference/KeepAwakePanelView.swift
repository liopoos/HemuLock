//
//  KeepAwakePanelView.swift
//  HemuLock
//
//  Created by Codex on 2026/10/1.
//

import Combine
import Settings
import SwiftUI

let KeepAwakePanelViewController: () -> SettingsPane = {
    let paneView = Settings.Pane(
        identifier: .init("keep_awake_setting"),
        title: "KEEP_AWAKE_TAB".localized,
        toolbarIcon: NSImage(systemSymbolName: "sun.max", accessibilityDescription: "KEEP_AWAKE_TAB".localized)!
    ) {
        KeepAwakePanelView()
            .environmentObject(appState)
    }

    return Settings.PaneHostingController(pane: paneView)
}

struct KeepAwakePanelView: View {
    @EnvironmentObject var appState: AppStateContainer

    var body: some View {
        Settings.Container(contentWidth: 540) {
            Settings.Section(title: "KEEP_AWAKE_TAB".localized) {
                Toggle("KEEP_AWAKE_ENABLE".localized, isOn: $appState.appConfig.isKeepAwakeEnabled)
            }

            Settings.Section(title: "KEEP_AWAKE_PRESETS".localized) {
                if #available(macOS 12.0, *) {
                    Table(KeepAwakeOption.allCases) {
                        TableColumn("KEEP_AWAKE_PRESET_NAME".localized) { option in
                            Text(option.localizationKey.localized)
                        }
                        TableColumn("KEEP_AWAKE_PRESET_ENABLED".localized) { option in
                            Toggle("", isOn: binding(for: option))
                                .labelsHidden()
                        }
                    }
                    .frame(minHeight: 190)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("KEEP_AWAKE_PRESET_NAME".localized)
                            Spacer()
                            Text("KEEP_AWAKE_PRESET_ENABLED".localized)
                        }
                        ForEach(KeepAwakeOption.allCases) { option in
                            HStack {
                                Text(option.localizationKey.localized)
                                Spacer()
                                Toggle("", isOn: binding(for: option))
                                    .labelsHidden()
                            }
                        }
                    }
                }
            }

            Settings.Section(title: "KEEP_AWAKE_PROCESS".localized) {
                KeepAwakeStatusView(manager: KeepAwakeManager.shared)
            }
        }
    }

    private func binding(for option: KeepAwakeOption) -> Binding<Bool> {
        Binding(
            get: { appState.appConfig.enabledKeepAwakeOptions[option.rawValue] ?? true },
            set: { isEnabled in
                appState.appConfig.enabledKeepAwakeOptions[option.rawValue] = isEnabled
            }
        )
    }
}

private struct KeepAwakeStatusView: View {
    @ObservedObject var manager: KeepAwakeManager
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let pid = manager.currentPID {
                Text(String(format: "KEEP_AWAKE_PROCESS_ID".localized, pid))
                if let endDate = manager.endDate {
                    let seconds = max(0, Int(ceil(endDate.timeIntervalSince(now))))
                    let countdown = String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60)
                    Text(String(format: "KEEP_AWAKE_REMAINING".localized, countdown))
                        .font(.system(.body, design: .monospaced))
                    Text(manager.untilTitle(for: endDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(String(format: "KEEP_AWAKE_REMAINING".localized, "KEEP_AWAKE_PERMANENT".localized))
                }
                Button("KEEP_AWAKE_CANCEL".localized) {
                    manager.stop()
                }
            } else {
                Text("KEEP_AWAKE_INACTIVE".localized)
                    .foregroundColor(.secondary)
            }
        }
        .onReceive(timer) { now = $0 }
    }
}
