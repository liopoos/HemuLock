//
//  HistoryPanelView.swift
//  HemuLock
//
//  Created by hades on 2025/12/20.
//

import Settings
import SwiftUI

let HistoryPanelViewController: () -> SettingsPane = {
    let paneView = Settings.Pane(
        identifier: .init("history_setting"),
        title: "HISTORY_TITLE".localized,
        toolbarIcon: NSImage(named: "SettingHistoryIcon")!
    ) {
        HistoryPanelView()
            .environmentObject(appState)
    }

    return Settings.PaneHostingController(pane: paneView)
}

struct HistoryPanelView: View {
    @EnvironmentObject var appState: AppStateContainer
    @State private var selectedTab: HistoryTab = .today
    @State private var records: [Record] = []
    @State private var isLoading: Bool = false

    private let contentWidth: Double = 540

    enum HistoryTab: String, CaseIterable {
        case today = "HISTORY_TODAY"
        case yesterday = "HISTORY_YESTERDAY"
        case dayBeforeYesterday = "HISTORY_DAY_BEFORE_YESTERDAY"

        var localizedName: String {
            return rawValue.localized
        }
    }

    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "") {
                VStack(alignment: .leading, spacing: 0) {
                    // Tab selector
                    Picker("", selection: $selectedTab) {
                        ForEach(HistoryTab.allCases, id: \.self) { tab in
                            Text(tab.localizedName).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 10)
                    .disabled(isLoading)

                    // Table content
                    VStack(alignment: .leading, spacing: 0) {
                        // Table header
                        HStack(spacing: 0) {
                            Text("HISTORY_DATE".localized)
                                .font(.headline)
                                .frame(width: 140, alignment: .leading)
                                .padding(.leading, 20)

                            Text("HISTORY_TIME".localized)
                                .font(.headline)
                                .frame(width: 120, alignment: .leading)

                            Text("HISTORY_EVENT".localized)
                                .font(.headline)
                                .frame(width: 180, alignment: .leading)

                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .background(Color(NSColor.controlBackgroundColor))

                        Divider()

                        // Table content area with loading indicator
                        ZStack {
                            ScrollView {
                                if filteredRecords.isEmpty && !isLoading {
                                    Text("NO_EVENT_RECORD".localized)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 40)
                                } else if !isLoading {
                                    VStack(spacing: 0) {
                                        ForEach(filteredRecords.indices, id: \.self) { index in
                                            RecordRowView(record: filteredRecords[index])
                                                .background(index % 2 == 0 ? Color.clear : Color(NSColor.controlBackgroundColor).opacity(0.3))

                                            if index < filteredRecords.count - 1 {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }

                            // Loading indicator overlay
                            if isLoading {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("HISTORY_LOADING".localized)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(NSColor.textBackgroundColor).opacity(0.8))
                            }
                        }
                        .frame(height: 400)
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
                }
            }
        }
        .onAppear {
            loadRecords()
        }
        .onChange(of: selectedTab) { _ in
            // No need to reload, just filter existing records
        }
    }

    var filteredRecords: [Record] {
        let calendar = Calendar.current
        let now = Date()

        return records.filter { record in
            switch selectedTab {
            case .today:
                return calendar.isDateInToday(record.time)
            case .yesterday:
                return calendar.isDateInYesterday(record.time)
            case .dayBeforeYesterday:
                if let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: now)) {
                    return calendar.isDate(record.time, inSameDayAs: twoDaysAgo)
                }
                return false
            }
        }
    }

    func loadRecords() {
        isLoading = true

        // Load records asynchronously to prevent UI blocking
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            let now = Date()

            // Calculate the start date for filtering (3 days ago)
            let startDate = calendar.date(byAdding: .day, value: -3, to: calendar.startOfDay(for: now)) ?? now

            // Use SQL-based filtering to fetch only records from the last 3 days
            let fetchedRecords = RecordRepository.shared.getRecords(from: startDate)

            DispatchQueue.main.async {
                self.records = fetchedRecords
                self.isLoading = false
            }
        }
    }
}

struct RecordRowView: View {
    let record: Record

    var body: some View {
        HStack(spacing: 0) {
            Text(formatDate(record.time))
                .frame(width: 140, alignment: .leading)
                .padding(.leading, 20)

            Text(formatTime(record.time))
                .frame(width: 120, alignment: .leading)

            Text(record.event.localized)
                .frame(width: 180, alignment: .leading)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct HistoryPanelView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryPanelView()
            .environmentObject(AppStateContainer())
    }
}
