//
//  DoNoDisturbPanelView.swift
//  HemuLock
//
//  Created by hades on 2024/1/22.
//

import Settings
import SwiftUI

let DoNotDisturbPanelViewController: () -> SettingsPane = {
    let paneView = Settings.Pane(
        identifier: .init("do_not_disturb_setting"),
        title: "DO_NOT_DISTURB_TITLE".localized,
        toolbarIcon: NSImage(named: "SettingDoNotDisturbIcon")!
    ) {
        DoNotDisturbPanelView()
            .environmentObject(appState)
    }

    return Settings.PaneHostingController(pane: paneView)
}

class DoNotDisturbPanelViewModel: ObservableObject {
    @Published var start: Date = Date() {
        didSet {
            appState.appConfig.doNotDisturbConfig.start = formatDateByDate(date: start)
        }
    }

    @Published var end: Date = Date() {
        didSet {
            appState.appConfig.doNotDisturbConfig.end = formatDateByDate(date: end)
        }
    }

    init() {
        start = formatDateByString(date: appState.appConfig.doNotDisturbConfig.start)
        end = formatDateByString(date: appState.appConfig.doNotDisturbConfig.end)
    }

    func formatDateByString(date: String) -> Date {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "HH:mm"
        return dateFormater.date(from: date) ?? Date()
    }

    func formatDateByDate(date: Date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "HH:mm"
        return dateFormater.string(from: date)
    }
}

struct DoNotDisturbPanelView: View {
    @EnvironmentObject var appState: AppStateContainer
    @ObservedObject var config = DoNotDisturbPanelViewModel()

    private let contentWidth: Double = 540

    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "") {
                Toggle("SET_DO_NOT_DISTURB".localized, isOn: $appState.appConfig.isDoNotDisturb)
                    .padding(.bottom, 10)
            }

            Settings.Section(title: "DO_NOT_DISTURB_CYCLE".localized) {
                HStack {
                    Toggle("DO_NOT_DISTURB_CYCLE_MONDAY".localized, isOn: $appState.appConfig.doNotDisturbConfig.cycle.monday)
                    Toggle("DO_NOT_DISTURB_CYCLE_TUESDAY".localized, isOn: $appState.appConfig.doNotDisturbConfig.cycle.tuesday)
                    Toggle("DO_NOT_DISTURB_CYCLE_WEDNESDAY".localized, isOn: $appState.appConfig.doNotDisturbConfig.cycle.wednesday)
                    Toggle("DO_NOT_DISTURB_CYCLE_THURSDAY".localized, isOn: $appState.appConfig.doNotDisturbConfig.cycle.thursday)
                    Toggle("DO_NOT_DISTURB_CYCLE_FRIDAY".localized, isOn: $appState.appConfig.doNotDisturbConfig.cycle.firday)
                    Toggle("DO_NOT_DISTURB_CYCLE_SATURDAY".localized, isOn: $appState.appConfig.doNotDisturbConfig.cycle.saturday)
                    Toggle("DO_NOT_DISTURB_CYCLE_SUNDAY".localized, isOn: $appState.appConfig.doNotDisturbConfig.cycle.sunday)
                }
            }
            Settings.Section(title: "DO_NOT_DISTURB_CYCLE".localized) {
                VStack {
                    DatePicker("DO_NOT_DISTURB_START", selection: $config.start, displayedComponents: [.hourAndMinute])
                    DatePicker("DO_NOT_DISTURB_END", selection: $config.end, displayedComponents: [.hourAndMinute])
                }
            }

            Settings.Section(title: "DO_NOT_DISTURB_TYPE".localized) {
                HStack {
                    Toggle("SET_NOTIFY".localized, isOn: $appState.appConfig.doNotDisturbConfig.type.notify)
                    Toggle("SET_SCRIPT".localized, isOn: $appState.appConfig.doNotDisturbConfig.type.script)
                }
            }
        }
    }
}
