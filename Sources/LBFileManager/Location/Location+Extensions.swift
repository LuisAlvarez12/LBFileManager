//
//  Location+Extensions.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

import Foundation

public extension Location {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.storage.path == rhs.storage.path
    }

    var description: String {
        let typeName = String(describing: type(of: self))
        return "\(typeName)(name: \(name), path: \(path))"
    }

    /// The path of this location, relative to the root of the file system.
    var path: String {
        return storage.path
    }

    /// A URL representation of the location's `path`.
    var url: URL {
        return URL(fileURLWithPath: path)
    }

    /// The name of the location, including any `extension`.
    var name: String {
        return url.pathComponents.last!
    }

    /// The name of the location, excluding its `extension`.
    var nameExcludingExtension: String {
        let components = name.split(separator: ".")
        guard components.count > 1 else { return name }
        return components.dropLast().joined()
    }

    /// The file extension of the item at the location.
    var `extension`: String? {
        let components = name.split(separator: ".")
        guard components.count > 1 else { return nil }
        return String(components.last!)
    }

    /// The parent folder that this location is contained within.
    var parent: Folder? {
        return storage.makeParentPath(for: path).flatMap {
            try? Folder(path: $0)
        }
    }

    /// The date when the item at this location was created.
    /// Only returns `nil` in case the item has now been deleted.
    var creationDate: Date? {
        return storage.attributes[.creationDate] as? Date
    }

    /// The date when the item at this location was last modified.
    /// Only returns `nil` in case the item has now been deleted.
    var modificationDate: Date? {
        return storage.attributes[.modificationDate] as? Date
    }

    /// Initialize an instance of an existing location at a given path.
    /// - parameter path: The absolute path of the location.
    /// - throws: `LocationError` if the item couldn't be found.
    init(path: String) throws {
        try self.init(storage: Storage(
            path: path,
            fileManager: .default
        ))
    }

    /// Return the path of this location relative to a parent folder.
    /// For example, if this item is located at `/users/john/documents`
    /// and `/users/john` is passed, then `documents` is returned. If the
    /// passed folder isn't an ancestor of this item, then the item's
    /// absolute `path` is returned instead.
    /// - parameter folder: The folder to compare this item's path against.
    func path(relativeTo folder: Folder) -> String {
        guard path.hasPrefix(folder.path) else {
            return path
        }

        let index = path.index(path.startIndex, offsetBy: folder.path.count)
        return String(path[index...]).removingSuffix("/")
    }

    /// Rename this location, keeping its existing `extension` by default.
    /// - parameter newName: The new name to give the location.
    /// - parameter keepExtension: Whether the location's `extension` should
    ///   remain unmodified (default: `true`).
    /// - throws: `LocationError` if the item couldn't be renamed.
    func rename(to newName: String, keepExtension: Bool = true) throws {
        guard let parent = parent else {
            throw LocationError(path: path, reason: .cannotRenameRoot)
        }

        var newName = newName

        if keepExtension {
            `extension`.map {
                newName = newName.appendingSuffixIfNeeded(".\($0)")
            }
        }

        try storage.move(
            to: parent.path + newName,
            errorReasonProvider: LocationErrorReason.renameFailed
        )
    }

    /// Move this location to a new parent folder
    /// - parameter newParent: The folder to move this item to.
    /// - throws: `LocationError` if the location couldn't be moved.
    func move(to newParent: Folder) throws {
        try storage.move(
            to: newParent.path + name,
            errorReasonProvider: LocationErrorReason.moveFailed
        )
    }

    /// Copy the contents of this location to a given folder
    /// - parameter newParent: The folder to copy this item to.
    /// - throws: `LocationError` if the location couldn't be copied.
    /// - returns: The new, copied location.
    @discardableResult
    func copy(to folder: Folder) throws -> Self {
        let path = folder.path + name
        try storage.copy(to: path)
        return try Self(path: path)
    }

    /// Delete this location. It will be permanently deleted. Use with caution.
    /// - throws: `LocationError` if the item couldn't be deleted.
    func delete() throws {
        try storage.delete()
    }

    /// Assign a new `FileManager` to manage this location. Typically only used
    /// for testing, or when building custom file systems. Returns a new instance,
    /// doensn't modify the instance this is called on.
    /// - parameter manager: The new file manager that should manage this location.
    /// - throws: `LocationError` if the change couldn't be completed.
    func managedBy(_ manager: FileManager) throws -> Self {
        return try Self(storage: Storage(
            path: path,
            fileManager: manager
        ))
    }
}
