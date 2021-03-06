import Foundation
import PathKit
import PeripheryKit
import Shared

#if canImport(XcodeSupport)
import XcodeSupport
#endif

public final class Project {
    static func identify() throws -> Self {
        let configuration: Configuration = inject()

        if configuration.workspace != nil || configuration.project != nil {
            return try self.init(kind: .xcode)
        } else if (Path.current + "Package.swift").exists {
            return try self.init(kind: .spm)
        }

        return try self.init(kind: .xcode)
    }

    let kind: ProjectKind

    init(kind: ProjectKind) throws {
        self.kind = kind
    }

    func validateEnvironment() throws {
        let logger: Logger = inject()
        let shell = Shell()

        logger.debug(try shell.exec(["swift", "--version"]).trimmed)

        switch kind {
        case .xcode:
            #if os(Linux)
            fatalError("Xcode projects are not supported on Linux.")
            #else
            do {
                let xcodebuild: Xcodebuild = inject()
                logger.debug(try xcodebuild.version())
            } catch {
                throw PeripheryError.xcodebuildNotConfigured
            }
            #endif
        default:
            break
        }
    }

    func driver() throws -> ProjectDriver {
        switch kind {
        case .xcode:
            #if os(Linux)
            fatalError("Xcode projects are not supported on Linux.")
            #else
            return try XcodeProjectDriver.make()
            #endif
        case .spm:
            return try SPMProjectDriver.make()
        }
    }
}
