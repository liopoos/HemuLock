//
//  ExportManager.swift
//  HemuLock
//
//  Created by hades on 2025/12/28.
//

import Foundation

/**
    ExportManager is responsible for exporting and importing application configurations in JSON format.
    It provides methods to export configurations to Data, import configurations from Data or URL,
    validate configuration data, and show user notifications.
 */
class ExportManager {
    static let shared = ExportManager()
    
    private init() {}
    
    // MARK: - Export
    func exportConfig(_ config: AppConfig) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(config)
            return data
        } catch {
            print("Export config failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Import
    func importConfig(from data: Data) -> AppConfig? {
        let decoder = JSONDecoder()
        
        do {
            let config = try decoder.decode(AppConfig.self, from: data)
            return config
        } catch {
            print("Import config failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    func importConfig(from url: URL) -> Result<AppConfig, ExportError> {
        // Start accessing the security-scoped resource for sandboxed apps
        guard url.startAccessingSecurityScopedResource() else {
            print("Import config failed: Unable to access security-scoped resource")
            return .failure(.fileReadFailed(NSError(domain: "ExportManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to access file"])))
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let config = try decoder.decode(AppConfig.self, from: data)
            return .success(config)
        } catch let error as DecodingError {
            print("Import config failed: \(error.localizedDescription)")
            return .failure(.decodingFailed(error))
        } catch {
            print("Import config failed: \(error.localizedDescription)")
            return .failure(.fileReadFailed(error))
        }
    }
    
    func validateConfig(_ data: Data) -> Bool {
        let decoder = JSONDecoder()
        
        do {
            _ = try decoder.decode(AppConfig.self, from: data)
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Export Error

enum ExportError: LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case fileReadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .fileReadFailed(let error):
            return "File read failed: \(error.localizedDescription)"
        }
    }
}
