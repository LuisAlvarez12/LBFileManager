//
//  File+Extensions.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

import Foundation

public extension File {
    static var kind: LocationKind {
        return .file
    }

    /// Write a new set of binary data into the file, replacing its current contents.
    /// - parameter data: The binary data to write.
    /// - throws: `WriteError` in case the operation couldn't be completed.
    func write(_ data: Data) throws {
        do {
            try data.write(to: url)
        } catch {
            throw WriteError(path: path, reason: .writeFailed(error))
        }
    }

    /// Write a new string into the file, replacing its current contents.
    /// - parameter string: The string to write.
    /// - parameter encoding: The encoding of the string (default: `UTF8`).
    /// - throws: `WriteError` in case the operation couldn't be completed.
    func write(_ string: String, encoding: String.Encoding = .utf8) throws {
        guard let data = string.data(using: encoding) else {
            throw WriteError(path: path, reason: .stringEncodingFailed(string))
        }

        return try write(data)
    }

    /// Append a set of binary data to the file's existing contents.
    /// - parameter data: The binary data to append.
    /// - throws: `WriteError` in case the operation couldn't be completed.
    func append(_ data: Data) throws {
        do {
            let handle = try FileHandle(forWritingTo: url)
            handle.seekToEndOfFile()
            handle.write(data)
            handle.closeFile()
        } catch {
            throw WriteError(path: path, reason: .writeFailed(error))
        }
    }

    /// Append a string to the file's existing contents.
    /// - parameter string: The string to append.
    /// - parameter encoding: The encoding of the string (default: `UTF8`).
    /// - throws: `WriteError` in case the operation couldn't be completed.
    func append(_ string: String, encoding: String.Encoding = .utf8) throws {
        guard let data = string.data(using: encoding) else {
            throw WriteError(path: path, reason: .stringEncodingFailed(string))
        }

        return try append(data)
    }

    /// Read the contents of the file as binary data.
    /// - throws: `ReadError` if the file couldn't be read.
    func read() throws -> Data {
        do { return try Data(contentsOf: url) }
        catch { throw ReadError(path: path, reason: .readFailed(error)) }
    }

    /// Read the contents of the file as a string.
    /// - parameter encoding: The encoding to decode the file's data using (default: `UTF8`).
    /// - throws: `ReadError` if the file couldn't be read, or if a string couldn't
    ///   be decoded from the file's contents.
    func readAsString(encodedAs encoding: String.Encoding = .utf8) throws -> String {
        guard let string = try String(data: read(), encoding: encoding) else {
            throw ReadError(path: path, reason: .stringDecodingFailed)
        }

        return string
    }

    /// Read the contents of the file as an integer.
    /// - throws: `ReadError` if the file couldn't be read, or if the file's
    ///   contents couldn't be converted into an integer.
    func readAsInt() throws -> Int {
        let string = try readAsString()

        guard let int = Int(string) else {
            throw ReadError(path: path, reason: .notAnInt(string))
        }

        return int
    }
}
