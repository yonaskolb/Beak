import Foundation
import PathKit
import SourceKittenFramework

public struct BeakFile: Equatable {
    public let contents: String
    public let includedFiles: [BeakFile]

    private let ownDependencies: [Dependency]
    private let ownFunctions: [Function]

    public var dependencies: [Dependency] {
        let includedFilesDependencies: [Dependency] = includedFiles.reduce([]) { $0 + $1.dependencies }
        return includedFilesDependencies + ownDependencies
    }

    public var functions: [Function] {
        let includedFilesFunctions: [Function] = includedFiles.reduce([]) { $0 + $1.functions }
        return includedFilesFunctions + ownFunctions
    }

    public init(path: Path) throws {
        guard path.exists else {
            throw BeakError.fileNotFound(path.string)
        }
        let contents: String = try path.read()
        try self.init(contents: contents)
    }

    public var libraries: [String] {
        return dependencies.reduce([]) { $0 + $1.libraries }
    }

    public init(contents: String) throws {
        self.contents = contents
        ownFunctions = try SwiftParser.parseFunctions(file: contents)
        ownDependencies = contents
            .split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("// beak:") }
            .map { $0.replacingOccurrences(of: "// beak:", with: "") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map(Dependency.init)
        includedFiles = contents
            .split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("// include:") }
            .map { $0.replacingOccurrences(of: "// include:", with: "") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.hasSuffix(".swift") }
            .compactMap { try? BeakFile(path: Path($0)) }
    }

    public init(contents: String, dependencies: [Dependency], functions: [Function], includedFiles: [BeakFile]) {
        self.contents = contents
        self.ownDependencies = dependencies
        self.ownFunctions = functions
        self.includedFiles = includedFiles
    }
}
