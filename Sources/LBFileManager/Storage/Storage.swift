//
//  Storage.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

import Foundation

/// Type used to store information about a given file system location. You don't
/// interact with this type as part of the public API, instead you use the APIs
/// exposed by `Location`, `File`, and `Folder`.
public final class Storage<LocationType: Location> {
    var path: String
    let fileManager: FileManager

    init(path: String, fileManager: FileManager) throws {
        self.path = path
        self.fileManager = fileManager
        #if DEBUG
            if !path.starts(with: Folder.DEBUG_FOLDER_PREFIX), !path.starts(with: File.DEBUG_FILE_PREFIX) {
                try validatePath()
            }
        #else
            try validatePath()
        #endif
    }

    private func validatePath() throws {
        switch LocationType.kind {
        case .file:
            guard !path.isEmpty else {
                throw LocationError(path: path, reason: .emptyFilePath)
            }
        case .folder:
            if path.isEmpty { path = fileManager.currentDirectoryPath }
            if !path.hasSuffix("/") { path += "/" }
        }

        if path.hasPrefix("~") {
            let homePath = ProcessInfo.processInfo.environment["HOME"]!
            path = homePath + path.dropFirst()
        }

        while let parentReferenceRange = path.range(of: "../") {
            let folderPath = String(path[..<parentReferenceRange.lowerBound])
            let parentPath = makeParentPath(for: folderPath) ?? "/"

            guard fileManager.locationExists(at: parentPath, kind: .folder) else {
                throw LocationError(path: parentPath, reason: .missing)
            }

            path.replaceSubrange(..<parentReferenceRange.upperBound, with: parentPath)
        }

        guard fileManager.locationExists(at: path, kind: LocationType.kind) else {
            throw LocationError(path: path, reason: .missing)
        }
    }
}
