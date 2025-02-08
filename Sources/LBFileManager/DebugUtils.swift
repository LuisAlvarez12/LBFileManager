//
//  DebugUtils.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

import Foundation
import LBFoundation

public extension Folder {
    static let DEBUG_FOLDER_PREFIX = "debug-folder"

    static var testFolder: Folder {
        let folder = Folder(debugFolderPath: "\(Self.DEBUG_FOLDER_PREFIX)-\(UUID().uuidString)", with: File.testFiles)
        Features.fileInterceptor.interceptFiles(folder: folder, files: File.testFiles)
        return folder
    }
}

public extension File {
    static var testFiles: Files {
        [
            File.debugFile(),
            File.debugFile(),
            File.debugFile(),
            File.debugFile(),
            File.debugFile(),
            File.debugFile(),
        ]
    }

    static let DEBUG_FILE_PREFIX = "debug-file"

    static func debugFile(pathExtension: String = "jpeg") -> File {
        File(debugFileName: "\(DEBUG_FILE_PREFIX)-\(UUID().uuidString)", withExtenion: pathExtension)
    }
}

public extension Features {
    static var fileInterceptor: LBFileInterceptor {
        shared.fetchFeature(featureKey: LBFileInterceptor.featureKey) as! LBFileInterceptor
    }
}

public class LBFileInterceptor: LBFeature {
    public static let featureKey: String = "FileInterceptor"

    public var interceptingFiles: [String: Files] = [:]

    public init() {}

    public func interceptFiles(folder: Folder, files: Files) {
        interceptingFiles[folder.path] = files
    }

    public func getFiles(folder: Folder) -> Files {
        if interceptingFiles.containsKey(folder.path) {
            return interceptingFiles[folder.path] ?? []
        } else {
            return []
        }
    }

    public func removeInterceptor(folder: Folder) {
        interceptingFiles.removeValue(forKey: folder.path)
    }

    public func clearInterceptors() {
        interceptingFiles.removeAll()
    }
}

public typealias Files = [File]
