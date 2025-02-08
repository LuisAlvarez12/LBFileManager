//
//  Folder.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

public struct Folder: Location, Identifiable {
    public var id: String
    
    public let storage: Storage<Folder>

    public init(storage: Storage<Folder>) {
        self.storage = storage
        self.id = storage.path
    }
    
#if DEBUG
    public init(debugFolderPath: String, with files: [File]) {
        try! self.init(storage: Storage(
            path: debugFolderPath,
            fileManager: .default
        ))
        
    }
#endif
}
