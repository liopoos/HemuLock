//
//  GeneraView.swift
//  HemuLock
//
//  Created by hades on 2024/1/20.
//

import Settings
import SwiftUI
import UniformTypeIdentifiers

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
    
    @State private var isExportingConfig = false
    @State private var exportDocument: JSONDocument?
    @State private var isImportingConfig = false

    private let contentWidth: Double = 540

    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "") {
                Toggle("LAUNCH_AT_LOGIN".localized, isOn: $appState.appConfig.isLaunchAtLogin)
                Toggle("SET_SCRIPT".localized, isOn: $appState.appConfig.isExecScript)
                    .padding(.bottom, 10)
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
            
            Settings.Section(title: "CONFIGURATION_MANAGEMENT".localized) {
                HStack {
                    Button("EXPORT_CONFIG".localized) {
                        exportConfiguration()
                    }
                    
                    Button("IMPORT_CONFIG".localized) {
                        isImportingConfig = true
                    }
                }
                .padding(.top, 5)
            }

            Settings.Section(title: "") {
                HStack {
                    Button("SETTING_OPEN_DB_FILE".localized) {
                        NSWorkspace.shared.open(RecordRepository.shared.dbManager.getPath())
                    }

                    Button("SETTING_OPEN_SCRIPT_FILE".localized) {
                        NSWorkspace.shared.open(ScriptManager.shared.getPath())
                    }
                    
                    Button("SETTING_OPEN_LOG_FILE".localized) {
                        NSWorkspace.shared.open(LogManager.shared.getLogsDirectory())
                    }
                }
            }
        }
        .fileExporter(
            isPresented: $isExportingConfig,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "hemulock-config"
        ) { result in
            handleExportResult(result)
            exportDocument = nil
        }
        .fileImporter(
            isPresented: $isImportingConfig,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
    }
    
    private func exportConfiguration() {
        guard let data = ExportManager.shared.exportConfig(appState.appConfig) else {
            SystemNotificationManager.shared.send(title: "EXPORT_FAILED".localized, message: "EXPORT_FAILED_MESSAGE".localized)
            return
        }
        
        exportDocument = JSONDocument(data: data)
        isExportingConfig = true
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            SystemNotificationManager.shared.send(title: "EXPORT_SUCCESS".localized, message: String(format: "EXPORT_SUCCESS_MESSAGE".localized, url.path))
        case .failure(let error):
            SystemNotificationManager.shared.send(title: "EXPORT_FAILED".localized, message: error.localizedDescription)
        }
    }
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            switch ExportManager.shared.importConfig(from: url) {
            case .success(let config):
                appState.appConfig = config
                SystemNotificationManager.shared.send(title: "IMPORT_SUCCESS".localized, message: "IMPORT_SUCCESS_MESSAGE".localized)
            case .failure:
                SystemNotificationManager.shared.send(title: "IMPORT_FAILED".localized, message: "IMPORT_FAILED_MESSAGE".localized)
            }
        case .failure(let error):
            SystemNotificationManager.shared.send(title: "IMPORT_FAILED".localized, message: error.localizedDescription)
        }
    }
}

// MARK: - JSONDocument

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    GeneraPanelView()
}
