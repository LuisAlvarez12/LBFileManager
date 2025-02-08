//
//  FilesError.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//


// MARK: - Errors

/// Error type thrown by all of Files' throwing APIs.
public struct FilesError<Reason: Sendable>: Error {
    /// The absolute path that the error occured at.
    public var path: String
    /// The reason that the error occured.
    public var reason: Reason

    /// Initialize an instance with a path and a reason.
    /// - parameter path: The absolute path that the error occured at.
    /// - parameter reason: The reason that the error occured.
    public init(path: String, reason: Reason) {
        self.path = path
        self.reason = reason
    }
}

extension FilesError: CustomStringConvertible {
    public var description: String {
        return """
        Files encountered an error at '\(path)'.
        Reason: \(reason)
        """
    }
}