//
//  Folder+Functons.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

import Foundation
import LBFoundation

public extension Folder {
    static var kind: LocationKind {
        return .folder
    }

    /// The folder that the program is currently operating in.
    static var current: Folder {
        return try! Folder(path: "")
    }

    /// The root folder of the file system.
    static var root: Folder {
        return try! Folder(path: "/")
    }

    /// The current user's Home folder.
    static var home: Folder {
        return try! Folder(path: "~")
    }

    /// The system's temporary folder.
    static var temporary: Folder {
        return try! Folder(path: NSTemporaryDirectory())
    }

    /// A sequence containing all of this folder's subfolders. Initially
    /// non-recursive, use `recursive` on the returned sequence to change that.
    var subfolders: ChildSequence<Folder> {
        return storage.makeChildSequence()
    }

    /// A sequence containing all of this folder's files. Initially
    /// non-recursive, use `recursive` on the returned sequence to change that.
    var filesSequence: ChildSequence<File> {
        return storage.makeChildSequence()
    }

    var files: Files {
        #if DEBUG
            let interceptedFiles = Features.fileInterceptor.getFiles(folder: self)
            if !interceptedFiles.isEmpty {
                return interceptedFiles
            }
        #endif
        return Array(storage.makeChildSequence())
    }

    /// Return a subfolder at a given path within this folder.
    /// - parameter path: A relative path within this folder.
    /// - throws: `LocationError` if the subfolder couldn't be found.
    func subfolder(at path: String) throws -> Folder {
        return try storage.subfolder(at: path)
    }

    /// Return a subfolder with a given name.
    /// - parameter name: The name of the subfolder to return.
    /// - throws: `LocationError` if the subfolder couldn't be found.
    func subfolder(named name: String) throws -> Folder {
        return try storage.subfolder(at: name)
    }

    /// Return whether this folder contains a subfolder at a given path.
    /// - parameter path: The relative path of the subfolder to look for.
    func containsSubfolder(at path: String) -> Bool {
        return (try? subfolder(at: path)) != nil
    }

    /// Return whether this folder contains a subfolder with a given name.
    /// - parameter name: The name of the subfolder to look for.
    func containsSubfolder(named name: String) -> Bool {
        return (try? subfolder(named: name)) != nil
    }

    /// Create a new subfolder at a given path within this folder. In case
    /// the intermediate folders between this folder and the new one don't
    /// exist, those will be created as well. This method throws an error
    /// if a folder already exists at the given path.
    /// - parameter path: The relative path of the subfolder to create.
    /// - throws: `WriteError` if the operation couldn't be completed.
    @discardableResult
    func createSubfolder(at path: String) throws -> Folder {
        return try storage.createSubfolder(at: path)
    }

    /// Create a new subfolder with a given name. This method throws an error
    /// if a subfolder with the given name already exists.
    /// - parameter name: The name of the subfolder to create.
    /// - throws: `WriteError` if the operation couldn't be completed.
    @discardableResult
    func createSubfolder(named name: String) throws -> Folder {
        return try storage.createSubfolder(at: name)
    }

    /// Create a new subfolder at a given path within this folder. In case
    /// the intermediate folders between this folder and the new one don't
    /// exist, those will be created as well. If a folder already exists at
    /// the given path, then it will be returned without modification.
    /// - parameter path: The relative path of the subfolder.
    /// - throws: `WriteError` if a new folder couldn't be created.
    @discardableResult
    func createSubfolderIfNeeded(at path: String) throws -> Folder {
        return try (try? subfolder(at: path)) ?? createSubfolder(at: path)
    }

    /// Create a new subfolder with a given name. If a subfolder with the given
    /// name already exists, then it will be returned without modification.
    /// - parameter name: The name of the subfolder.
    /// - throws: `WriteError` if a new folder couldn't be created.
    @discardableResult
    func createSubfolderIfNeeded(withName name: String) throws -> Folder {
        return try (try? subfolder(named: name)) ?? createSubfolder(named: name)
    }

    /// Return a file at a given path within this folder.
    /// - parameter path: A relative path within this folder.
    /// - throws: `LocationError` if the file couldn't be found.
    func file(at path: String) throws -> File {
        return try storage.file(at: path)
    }

    /// Return a file within this folder with a given name.
    /// - parameter name: The name of the file to return.
    /// - throws: `LocationError` if the file couldn't be found.
    func file(named name: String) throws -> File {
        return try storage.file(at: name)
    }

    /// Return whether this folder contains a file at a given path.
    /// - parameter path: The relative path of the file to look for.
    func containsFile(at path: String) -> Bool {
        return (try? file(at: path)) != nil
    }

    /// Return whether this folder contains a file with a given name.
    /// - parameter name: The name of the file to look for.
    func containsFile(named name: String) -> Bool {
        return (try? file(named: name)) != nil
    }

    /// Create a new file at a given path within this folder. In case
    /// the intermediate folders between this folder and the new file don't
    /// exist, those will be created as well. This method throws an error
    /// if a file already exists at the given path.
    /// - parameter path: The relative path of the file to create.
    /// - parameter contents: The initial `Data` that the file should contain.
    /// - throws: `WriteError` if the operation couldn't be completed.
    @discardableResult
    func createFile(at path: String, contents: Data? = nil) throws -> File {
        return try storage.createFile(at: path, contents: contents)
    }

    /// Create a new file with a given name. This method throws an error
    /// if a file with the given name already exists.
    /// - parameter name: The name of the file to create.
    /// - parameter contents: The initial `Data` that the file should contain.
    /// - throws: `WriteError` if the operation couldn't be completed.
    @discardableResult
    func createFile(named fileName: String, contents: Data? = nil) throws -> File {
        return try storage.createFile(at: fileName, contents: contents)
    }

    /// Create a new file at a given path within this folder. In case
    /// the intermediate folders between this folder and the new file don't
    /// exist, those will be created as well. If a file already exists at
    /// the given path, then it will be returned without modification.
    /// - parameter path: The relative path of the file.
    /// - parameter contents: The initial `Data` that any newly created file
    ///   should contain. Will only be evaluated if needed.
    /// - throws: `WriteError` if a new file couldn't be created.
    @discardableResult
    func createFileIfNeeded(at path: String,
                            contents: @autoclosure () -> Data? = nil) throws -> File
    {
        return try (try? file(at: path)) ?? createFile(at: path, contents: contents())
    }

    /// Create a new file with a given name. If a file with the given
    /// name already exists, then it will be returned without modification.
    /// - parameter name: The name of the file.
    /// - parameter contents: The initial `Data` that any newly created file
    ///   should contain. Will only be evaluated if needed.
    /// - throws: `WriteError` if a new file couldn't be created.
    @discardableResult
    func createFileIfNeeded(withName name: String,
                            contents: @autoclosure () -> Data? = nil) throws -> File
    {
        return try (try? file(named: name)) ?? createFile(named: name, contents: contents())
    }

    /// Return whether this folder contains a given location as a direct child.
    /// - parameter location: The location to find.
    func contains<T: Location>(_ location: T) -> Bool {
        switch T.kind {
        case .file: return containsFile(named: location.name)
        case .folder: return containsSubfolder(named: location.name)
        }
    }

    /// Move the contents of this folder to a new parent
    /// - parameter folder: The new parent folder to move this folder's contents to.
    /// - parameter includeHidden: Whether hidden files should be included (default: `false`).
    /// - throws: `LocationError` if the operation couldn't be completed.
    func moveContents(to folder: Folder, includeHidden: Bool = false) throws {
        var files = filesSequence
        files.includeHidden = includeHidden
        try files.move(to: folder)

        var folders = subfolders
        folders.includeHidden = includeHidden
        try folders.move(to: folder)
    }

    /// Empty this folder, permanently deleting all of its contents. Use with caution.
    /// - parameter includeHidden: Whether hidden files should also be deleted (default: `false`).
    /// - throws: `LocationError` if the operation couldn't be completed.
    func empty(includingHidden includeHidden: Bool = false) throws {
        var files = filesSequence
        files.includeHidden = includeHidden
        try files.delete()

        var folders = subfolders
        folders.includeHidden = includeHidden
        try folders.delete()
    }

    func isEmpty(includingHidden includeHidden: Bool = false) -> Bool {
        var files = filesSequence
        files.includeHidden = includeHidden

        if files.first != nil {
            return false
        }

        var folders = subfolders
        folders.includeHidden = includeHidden
        return folders.first == nil
    }
}
