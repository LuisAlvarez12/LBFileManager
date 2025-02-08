//
//  File+Mac.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

    import AppKit

    public extension File {
        /// Open the file.
        func open() {
            NSWorkspace.shared.openFile(path)
        }
    }

#endif
