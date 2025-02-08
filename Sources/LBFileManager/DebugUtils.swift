//
//  DebugUtils.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

import Foundation
import LBFoundation

public extension Folder {
    public static let DEBUG_FOLDER_PREFIX = "debug-folder"
    
    public static func debugFolder(pathExtension: String = "jpeg", files: [File]) -> Folder {
        Folder(debugFolderPath: "\(Self.DEBUG_FOLDER_PREFIX)-\(UUID().uuidString)", with: files)
    }
}

public extension File {
    public static let DEBUG_FILE_PREFIX = "debug-file"
    
    public static func debugFile(pathExtension: String = "jpeg") -> File {
        File(debugFileName: "\(Self.DEBUG_FILE_PREFIX)-\(UUID().uuidString)", withExtenion: pathExtension)
    }
}

public extension Features {
    static var fileManager: LBFileInterceptor {
        shared.fetchFeature(featureKey: LBFileInterceptor.featureKey) as! LBFileInterceptor
    }
}

public class LBFileInterceptor : LBFeature {
    public static let featureKey: String = "FileInterceptor"
    
    public var interceptingFiles: [String: Files] = [:]
    
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
