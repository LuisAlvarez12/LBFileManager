//
//  Folder+Matchers.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

import Foundation

#if os(iOS) || os(tvOS) || os(macOS)
    public extension Folder {
        /// Resolve a folder that matches a search path within a given domain.
        /// - parameter searchPath: The directory path to search for.
        /// - parameter domain: The domain to search in.
        /// - parameter fileManager: Which file manager to search using.
        /// - throws: `LocationError` if no folder could be resolved.
        static func matching(
            _ searchPath: FileManager.SearchPathDirectory,
            in domain: FileManager.SearchPathDomainMask = .userDomainMask,
            resolvedBy fileManager: FileManager = .default
        ) throws -> Folder {
            let urls = fileManager.urls(for: searchPath, in: domain)

            guard let match = urls.first else {
                throw LocationError(
                    path: "",
                    reason: .unresolvedSearchPath(searchPath, domain: domain)
                )
            }

            return try Folder(storage: Storage(
                path: match.relativePath,
                fileManager: fileManager
            ))
        }

        /// The current user's Documents folder
        static var documents: Folder? {
            return try? .matching(.documentDirectory)
        }

        /// The current user's Library folder
        static var library: Folder? {
            return try? .matching(.libraryDirectory)
        }
    }
#endif
