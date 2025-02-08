//
//  FileManager+Extensions.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

import Foundation

extension FileManager {
    func locationExists(at path: String, kind: LocationKind) -> Bool {
        var isFolder: ObjCBool = false

        guard fileExists(atPath: path, isDirectory: &isFolder) else {
            return false
        }

        switch kind {
        case .file: return !isFolder.boolValue
        case .folder: return isFolder.boolValue
        }
    }
}
