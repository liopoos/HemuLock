//
//  GeneraView.swift
//  HemuLock
//
//  Created by hades on 2024/1/20.
//

import Settings
import SwiftUI

let GeneraPanelViewController: () -> SettingsPane = {
    let paneView = Settings.Pane(
        identifier: .init("genera_setting"),
        title: "GENERA_TITLE".localized,
        toolbarIcon: NSImage(named: "SettingGearIcon")!
    ) {
        GeneraPanelView()
            .environmentObject(appState)
    }

    return Settings.PaneHostingController(pane: paneView)
}

struct GeneraPanelView: View {
    @EnvironmentObject var appState: AppStateContainer

    private let contentWidth: Double = 450

    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "") {
                Toggle("LAUNCH_AT_LOGIN".localized, isOn: $appState.appConfig.isLaunchAtLogin)
                Toggle("SET_SCRIPT".localized, isOn: $appState.appConfig.isExecScript)
                    .padding(.bottom, 10)
            }

            Settings.Section(title: "EVENT_RECORDS".localized) {
                HStack {
                    Toggle("RECORD_EVENT".localized, isOn: $appState.appConfig.isRecordEvent)
                    Text(String(format: "SETTING_RECORD_NUMBER".localized, RecordRepository.shared.getRecordCount()))
                }
                HStack {
                    Button("SETTING_DROP_RECORD".localized) {
                        _ = RecordRepository.shared.dropRecord()
                    }
                }
                .padding(.top, 5)
            }

            Settings.Section(title: "PROJECT_PAGE".localized) {
                Button(action: {}) {
                    Text("https://github.com/liopoos/HemuLock").underline().foregroundColor(Color.blue)
                }.buttonStyle(PlainButtonStyle())
                    .padding(.top, 10)
                    .onHover { inside in
                        if inside {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
            }
            
            Settings.Section(title: "") {
                HStack {
                    Button("SETTING_OPEN_DB_FILE".localized) {
                        NSWorkspace.shared.open(RecordRepository.shared.dbManager.getPath())
                    }
                    
                    Button("SETTING_OPEN_SCRIPT_FILE".localized) {
                        NSWorkspace.shared.open(ScriptManager.shared.getPath())
                    }
                }
            }
        }
    }
}

#Preview {
    GeneraPanelView()
}
