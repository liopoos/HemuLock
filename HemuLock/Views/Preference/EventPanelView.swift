//
//  EventPanelView.swift
//  HemuLock
//
//  Created by GitHub Copilot on 2026/1/2.
//

import Settings
import SwiftUI

let EventPanelViewController: () -> SettingsPane = {
    let paneView = Settings.Pane(
        identifier: .init("event_setting"),
        title: "EVENT_PANEL_TITLE".localized,
        toolbarIcon: NSImage(systemSymbolName: "calendar.badge.clock", accessibilityDescription: "Events")!
    ) {
        EventPanelView()
            .environmentObject(appState)
    }

    return Settings.PaneHostingController(pane: paneView)
}

struct EventPanelView: View {
    @EnvironmentObject var appState: AppStateContainer
    @State private var todayCount: Int = 0
    @State private var last3DaysCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var showClearAlert: Bool = false
    
    private let contentWidth: Double = 540
    
    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            // Global recording toggle
            Settings.Section(title: "EVENT_RECORDING".localized) {
                Toggle("EVENT_ENABLE_RECORDING".localized, isOn: $appState.appConfig.isRecordEvent)
            }
            
            // Statistics
            Settings.Section(title: "EVENT_STATISTICS".localized) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("EVENT_STATISTICS_TODAY".localized)
                        Spacer()
                        Text("\(todayCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("EVENT_STATISTICS_LAST3DAYS".localized)
                        Spacer()
                        Text("\(last3DaysCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("EVENT_STATISTICS_TOTAL".localized)
                        Spacer()
                        Text("\(totalCount)")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.trailing, 10)
            }
            
            // Event type selection
            Settings.Section(title: "EVENT_SELECT_TYPES".localized) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Event.allCases, id: \.tag) { event in
                        Toggle(event.name.localized, isOn: eventBinding(for: event))
                    }
                }
            }
            
            // Batch operation buttons
            Settings.Section {
                EmptyView()
            } content: {
                HStack(spacing: 12) {
                    Button("EVENT_SELECT_ALL".localized) {
                        selectAll()
                    }
                    
                    Button("EVENT_DESELECT_ALL".localized) {
                        deselectAll()
                    }
                    
                    Spacer()
                    
                    Button("EVENT_CLEAR_ALL".localized) {
                        showClearAlert = true
                    }
                    .padding(.trailing, 30)
                    .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            loadStatistics()
        }
        .alert(isPresented: $showClearAlert) {
            Alert(
                title: Text("EVENT_CLEAR_CONFIRM_TITLE".localized),
                message: Text("EVENT_CLEAR_CONFIRM_MESSAGE".localized),
                primaryButton: .destructive(Text("EVENT_CLEAR_CONFIRM_YES".localized)) {
                    clearAllRecords()
                },
                secondaryButton: .cancel(Text("EVENT_CLEAR_CONFIRM_NO".localized))
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func eventBinding(for event: Event) -> Binding<Bool> {
        Binding(
            get: {
                appState.appConfig.activeEvents.contains(event.tag)
            },
            set: { isEnabled in
                if isEnabled {
                    if !appState.appConfig.activeEvents.contains(event.tag) {
                        appState.appConfig.activeEvents.append(event.tag)
                    }
                } else {
                    appState.appConfig.activeEvents.removeAll { $0 == event.tag }
                }
            }
        )
    }
    
    private func loadStatistics() {
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            
            // Today's record count
            let todayStart = calendar.startOfDay(for: Date())
            let todayRecords = RecordRepository.shared.getRecords(from: todayStart)
            
            // Last 3 days record count
            let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: todayStart)!
            let last3DaysRecords = RecordRepository.shared.getRecords(from: threeDaysAgo)
            
            // Total record count
            let total = RecordRepository.shared.getRecordCount()
            
            DispatchQueue.main.async {
                self.todayCount = todayRecords.count
                self.last3DaysCount = last3DaysRecords.count
                self.totalCount = total
            }
        }
    }
    
    private func selectAll() {
        appState.appConfig.activeEvents = Event.allCases.map { $0.tag }
    }
    
    private func deselectAll() {
        appState.appConfig.activeEvents = []
    }
    
    private func clearAllRecords() {
        DispatchQueue.global(qos: .userInitiated).async {
            _ = RecordRepository.shared.dropRecord()
            
            DispatchQueue.main.async {
                loadStatistics()
            }
        }
    }
}
