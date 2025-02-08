//
//  Location.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//

/// Protocol adopted by types that represent locations on a file system.
public protocol Location: Equatable, CustomStringConvertible {
    /// The kind of location that is being represented (see `LocationKind`).
    static var kind: LocationKind { get }
    /// The underlying storage for the item at the represented location.
    /// You don't interact with this object as part of the public API.
    var storage: Storage<Self> { get }
    /// Initialize an instance of this location with its underlying storage.
    /// You don't call this initializer as part of the public API, instead
    /// use `init(path:)` on either `File` or `Folder`.
    init(storage: Storage<Self>)
}
