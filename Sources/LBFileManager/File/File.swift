//
//  File.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//
import Foundation

/// Type that represents a file on disk. You can either reference an existing
/// file by initializing an instance with a `path`, or you can create new files
/// using the various `createFile...` APIs available on `Folder`.
public struct File: Location {
    public let storage: Storage<File>

    public init(storage: Storage<File>) {
        self.storage = storage
    }
    
#if DEBUG
    public init(debugFileName: String, withExtenion: String) {
        let path = "\(Self.DEBUG_FILE_PREFIX)-\(UUID().uuidString).\(withExtenion)"
        self.storage = try! Storage<File>(path: path, fileManager: .default)
    }
#endif
    
}
