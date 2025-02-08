//
//  LocationKind.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/6/25.
//


/**
 *  Files
 *
 *  Copyright (c) 2017-2019 John Sundell. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import Foundation

// MARK: - Storage

public extension Storage where LocationType == Folder {
    func makeChildSequence<T: Location>() -> Folder.ChildSequence<T> {
        return Folder.ChildSequence(
            folder: Folder(storage: self),
            fileManager: fileManager,
            isRecursive: false,
            includeHidden: false
        )
    }

    func subfolder(at folderPath: String) throws -> Folder {
        let folderPath = path + folderPath.removingPrefix("/")
        let storage = try Storage(path: folderPath, fileManager: fileManager)
        return Folder(storage: storage)
    }

    func file(at filePath: String) throws -> File {
        let filePath = path + filePath.removingPrefix("/")
        let storage = try Storage<File>(path: filePath, fileManager: fileManager)
        return File(storage: storage)
    }

    func createSubfolder(at folderPath: String) throws -> Folder {
        let folderPath = path + folderPath.removingPrefix("/")

        guard folderPath != path else {
            throw WriteError(path: folderPath, reason: .emptyPath)
        }

        do {
            try fileManager.createDirectory(
                atPath: folderPath,
                withIntermediateDirectories: true
            )

            let storage = try Storage(path: folderPath, fileManager: fileManager)
            return Folder(storage: storage)
        } catch {
            throw WriteError(path: folderPath, reason: .folderCreationFailed(error))
        }
    }

    func createFile(at filePath: String, contents: Data?) throws -> File {
        let filePath = path + filePath.removingPrefix("/")

        guard let parentPath = makeParentPath(for: filePath) else {
            throw WriteError(path: filePath, reason: .emptyPath)
        }

        if parentPath != path {
            do {
                try fileManager.createDirectory(
                    atPath: parentPath,
                    withIntermediateDirectories: true
                )
            } catch {
                throw WriteError(path: parentPath, reason: .folderCreationFailed(error))
            }
        }

        guard fileManager.createFile(atPath: filePath, contents: contents),
              let storage = try? Storage<File>(path: filePath, fileManager: fileManager) else {
            throw WriteError(path: filePath, reason: .fileCreationFailed)
        }

        return File(storage: storage)
    }
}

// MARK: - Files


// MARK: - Folders

/// Type that represents a folder on disk. You can either reference an existing
/// folder by initializing an instance with a `path`, or you can create new
/// subfolders using this type's various `createSubfolder...` APIs.

public extension Folder {
    /// A sequence of child locations contained within a given folder.
    /// You obtain an instance of this type by accessing either `files`
    /// or `subfolders` on a `Folder` instance.
    struct ChildSequence<Child: Location>: Sequence {
        let folder: Folder
        let fileManager: FileManager
        var isRecursive: Bool
        var includeHidden: Bool

        public func makeIterator() -> ChildIterator<Child> {
            return ChildIterator(
                folder: folder,
                fileManager: fileManager,
                isRecursive: isRecursive,
                includeHidden: includeHidden,
                reverseTopLevelTraversal: false
            )
        }
    }

    /// The type of iterator used by `ChildSequence`. You don't interact
    /// with this type directly. See `ChildSequence` for more information.
    struct ChildIterator<Child: Location>: IteratorProtocol {
        private let folder: Folder
        private let fileManager: FileManager
        private let isRecursive: Bool
        private let includeHidden: Bool
        private let reverseTopLevelTraversal: Bool
        private lazy var itemNames = loadItemNames()
        private var index = 0
        private var nestedIterators = [ChildIterator<Child>]()

        fileprivate init(folder: Folder,
                         fileManager: FileManager,
                         isRecursive: Bool,
                         includeHidden: Bool,
                         reverseTopLevelTraversal: Bool) {
            self.folder = folder
            self.fileManager = fileManager
            self.isRecursive = isRecursive
            self.includeHidden = includeHidden
            self.reverseTopLevelTraversal = reverseTopLevelTraversal
        }

        public mutating func next() -> Child? {
            guard index < itemNames.count else {
                guard var nested = nestedIterators.first else {
                    return nil
                }

                guard let child = nested.next() else {
                    nestedIterators.removeFirst()
                    return next()
                }

                nestedIterators[0] = nested
                return child
            }

            let name = itemNames[index]
            index += 1

            if !includeHidden {
                guard !name.hasPrefix(".") else { return next() }
            }

            let childPath = folder.path + name.removingPrefix("/")
            let childStorage = try? Storage<Child>(path: childPath, fileManager: fileManager)
            let child = childStorage.map(Child.init)

            if isRecursive {
                let childFolder = (child as? Folder) ?? (try? Folder(
                    storage: Storage(path: childPath, fileManager: fileManager)
                ))

                if let childFolder = childFolder {
                    let nested = ChildIterator(
                        folder: childFolder,
                        fileManager: fileManager,
                        isRecursive: true,
                        includeHidden: includeHidden,
                        reverseTopLevelTraversal: false
                    )

                    nestedIterators.append(nested)
                }
            }

            return child ?? next()
        }

        private mutating func loadItemNames() -> [String] {
            let contents = try? fileManager.contentsOfDirectory(atPath: folder.path)
            let names = contents?.sorted() ?? []
            return reverseTopLevelTraversal ? names.reversed() : names
        }
    }
}

extension Folder.ChildSequence: CustomStringConvertible {
    public var description: String {
        return lazy.map({ $0.description }).joined(separator: "\n")
    }
}

public extension Folder.ChildSequence {
    /// Return a new instance of this sequence that'll traverse the folder's
    /// contents recursively, in a breadth-first manner. Complexity: `O(1)`.
    var recursive: Folder.ChildSequence<Child> {
        var sequence = self
        sequence.isRecursive = true
        return sequence
    }

    /// Return a new instance of this sequence that'll include all hidden
    /// (dot) files when traversing the folder's contents. Complexity: `O(1)`.
    var includingHidden: Folder.ChildSequence<Child> {
        var sequence = self
        sequence.includeHidden = true
        return sequence
    }

    /// Count the number of locations contained within this sequence.
    /// Complexity: `O(N)`.
    func count() -> Int {
        return reduce(0) { count, _ in count + 1 }
    }

    /// Gather the names of all of the locations contained within this sequence.
    /// Complexity: `O(N)`.
    func names() -> [String] {
        return map { $0.name }
    }

    /// Return the last location contained within this sequence.
    /// Complexity: `O(N)`.
    func last() -> Child? {
        var iterator = Iterator(
            folder: folder,
            fileManager: fileManager,
            isRecursive: isRecursive,
            includeHidden: includeHidden,
            reverseTopLevelTraversal: !isRecursive
        )

        guard isRecursive else { return iterator.next() }

        var child: Child?

        while let nextChild = iterator.next() {
            child = nextChild
        }

        return child
    }

    /// Return the first location contained within this sequence.
    /// Complexity: `O(1)`.
    var first: Child? {
        var iterator = makeIterator()
        return iterator.next()
    }

    /// Move all locations within this sequence to a new parent folder.
    /// - parameter folder: The folder to move all locations to.
    /// - throws: `LocationError` if the move couldn't be completed.
    func move(to folder: Folder) throws {
        try forEach { try $0.move(to: folder) }
    }

    /// Delete all of the locations within this sequence. All items will
    /// be permanently deleted. Use with caution.
    /// - throws: `LocationError` if an item couldn't be deleted. Note that
    ///   all items deleted up to that point won't be recovered.
    func delete() throws {
        try forEach { try $0.delete() }
    }
}

