//
//  Storage+Actions.swift
//  LBFileManager
//
//  Created by Luis Alvarez on 2/8/25.
//
import Foundation

extension Storage {
    var attributes: [FileAttributeKey: Any] {
        return (try? fileManager.attributesOfItem(atPath: path)) ?? [:]
    }

    func makeParentPath(for path: String) -> String? {
        guard path != "/" else { return nil }
        let url = URL(fileURLWithPath: path)
        let components = url.pathComponents.dropFirst().dropLast()
        guard !components.isEmpty else { return "/" }
        return "/" + components.joined(separator: "/") + "/"
    }

    func move(to newPath: String,
              errorReasonProvider: (Error) -> LocationErrorReason) throws
    {
        do {
            try fileManager.moveItem(atPath: path, toPath: newPath)

            switch LocationType.kind {
            case .file:
                path = newPath
            case .folder:
                path = newPath.appendingSuffixIfNeeded("/")
            }
        } catch {
            throw LocationError(path: path, reason: errorReasonProvider(error))
        }
    }

    func copy(to newPath: String) throws {
        do {
            try fileManager.copyItem(atPath: path, toPath: newPath)
        } catch {
            throw LocationError(path: path, reason: .copyFailed(error))
        }
    }

    func delete() throws {
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            throw LocationError(path: path, reason: .deleteFailed(error))
        }
    }
}
