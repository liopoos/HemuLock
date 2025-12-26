//
//  NotifyPaneView.swift
//  HemuLock
//
//  Created by hades on 2024/1/20.
//

import Settings
import SwiftUI

let NotifyPanelViewController: () -> SettingsPane = {
    let paneView = Settings.Pane(
        identifier: .init("notify_setting"),
        title: "NOTIFY_TITLE".localized,
        toolbarIcon: NSImage(named: "SettingNotifyIcon")!
    ) {
        NotifyPanelView()
            .environmentObject(appState)
    }

    return Settings.PaneHostingController(pane: paneView)
}

struct NotifyPanelView: View {
    @EnvironmentObject var appState: AppStateContainer

    private let contentWidth: Double = 540

    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "NOTIFY_TITLE".localized) {
                Picker("", selection: $appState.appConfig.notifyType) {
                    ForEach(Notify.allCases, id: \.rawValue) { notify in
                        Text(notify.name).tag(notify.tag)
                    }
                }
                .labelsHidden()
                .frame(width: 120.0)
            }

            Settings.Section {
                EmptyView()
            } content: {
                VStack {
                    switch appState.appConfig.notifyType {
                    case Notify.pushover.rawValue:
                        Settings.Section {
                            Text("Token").frame(width: 50)
                        } content: {
                            TextField("Pushover token ", text: $appState.appConfig.notifyConfig.pushover.token)
                        }
                        Settings.Section {
                            Text("User").frame(width: 50)
                        } content: {
                            TextField("Pushover user ", text: $appState.appConfig.notifyConfig.pushover.user)
                        }
                        Settings.Section {
                            Text("Device:").frame(width: 50)
                        } content: {
                            TextField("Pushover device ", text: $appState.appConfig.notifyConfig.pushover.device)
                        }
                    case Notify.serverCat.rawValue:
                        Settings.Section {
                            Text("SK Key").frame(width: 50)
                        } content: {
                            TextField("ServerCat SK key ", text: $appState.appConfig.notifyConfig.servercat.sk)
                        }
                    case Notify.bark.rawValue:
                        Settings.Section {
                            Text("Server").frame(width: 50)
                        } content: {
                            TextField("Bark custom server, blank to use default", text: $appState.appConfig.notifyConfig.bark.server)
                        }
                        Settings.Section {
                            Text("Device").frame(width: 50)
                        } content: {
                            TextField("Bark key secret ", text: $appState.appConfig.notifyConfig.bark.device)
                        }
                        Settings.Section {
                            Text("Critical").frame(width: 50)
                        } content: {
                            Toggle("NOTIFY_BARK_CRITICAL".localized, isOn: $appState.appConfig.notifyConfig.bark.critical)
                        }
                    default:
                        EmptyView()
                    }
                }
                .frame(height: 100, alignment: .top)
            }

            Settings.Section {
                EmptyView()
            } content: {
                Button("NOTIFY_TEST".localized) {
                    sendTestNotify()
                }
                .padding(.top, 10)
            }
        }
    }

    func sendTestNotify() {
        let observer = EventObserver()
        observer.sendNotify()
    }
}
