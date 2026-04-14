//
//  WebhookPanelView.swift
//  HemuLock
//
//  Created by GitHub Copilot on 2026/1/1.
//

import Settings
import SwiftUI

let WebhookPanelViewController: () -> SettingsPane = {
    let paneView = Settings.Pane(
        identifier: .init("webhook_setting"),
        title: "WEBHOOK_TITLE".localized,
        toolbarIcon: NSImage(systemSymbolName: "link.circle", accessibilityDescription: "Webhook")!
    ) {
        WebhookPanelView()
            .environmentObject(appState)
    }

    return Settings.PaneHostingController(pane: paneView)
}

struct WebhookPanelView: View {
    @EnvironmentObject var appState: AppStateContainer

    private let contentWidth: Double = 540
    
    private var timeoutString: Binding<String> {
        Binding(
            get: { String(format: "%.0f", appState.appConfig.webhookConfig.timeout) },
            set: { newValue in
                if let value = Double(newValue), value > 0 {
                    appState.appConfig.webhookConfig.timeout = value
                }
            }
        )
    }

    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "WEBHOOK_TITLE".localized) {
                Toggle("WEBHOOK_ENABLE".localized, isOn: $appState.appConfig.webhookConfig.enabled)
            }

            Settings.Section {
                Text("WEBHOOK_URL".localized).frame(width: 80)
            } content: {
                TextField("WEBHOOK_URL_PLACEHOLDER".localized, text: $appState.appConfig.webhookConfig.url)
            }
            
            Settings.Section {
                Text("WEBHOOK_TIMEOUT".localized).frame(width: 80)
            } content: {
                HStack {
                    TextField("", text: timeoutString)
                        .frame(width: 60)
                    Text("WEBHOOK_TIMEOUT_UNIT".localized)
                }
            }
            
            Settings.Section {
                Text("WEBHOOK_SYSTEM_INFO".localized).frame(width: 80)
            } content: {
                Toggle("WEBHOOK_INCLUDE_SYSTEM_INFO".localized, isOn: $appState.appConfig.webhookConfig.includeSystemInfo)
            }
            
            Settings.Section(title: "WEBHOOK_EVENTS".localized) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Event.allCases, id: \.tag) { event in
                        Toggle(event.name.localized, isOn: Binding(
                            get: {
                                appState.appConfig.webhookConfig.enabledEvents.contains(event.tag)
                            },
                            set: { isEnabled in
                                if isEnabled {
                                    if !appState.appConfig.webhookConfig.enabledEvents.contains(event.tag) {
                                        appState.appConfig.webhookConfig.enabledEvents.append(event.tag)
                                    }
                                } else {
                                    appState.appConfig.webhookConfig.enabledEvents.removeAll { $0 == event.tag }
                                }
                            }
                        ))
                    }
                }
                .padding(.vertical, 4)
            }

            Settings.Section {
                EmptyView()
            } content: {
                Button("WEBHOOK_TEST".localized) {
                    sendTestWebhook()
                }
                .padding(.top, 10)
            }
        }
    }

    func sendTestWebhook() {
        do {
            try WebhookManager.shared.sendTest()
        } catch {
            SystemNotificationManager.shared.send(
                title: "WEBHOOK_TEST_FAILED_TITLE".localized,
                message: NotifyError.invalidConfig.message.localized
            )
        }
    }
}
