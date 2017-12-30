import Foundation
import PathKit
import SourceKittenFramework

public struct BeakFile {

    public let contents: String
    public let dependencies: [Dependency]
    public let libraries: [String]
    public let functions: [Function]

    public init(path: Path) throws {
        guard path.exists else {
            throw BeakError.fileNotFound(path.string)
        }
        let contents: String = try path.read()
        try self.init(contents: contents)
    }

    public init(contents: String) throws {
        self.contents = contents
        functions = try SwiftParser.parseFunctions(file: contents)
        dependencies = contents
            .split(separator: "\n")
            .map(String.init)
            .prefix { $0.hasPrefix("// beak:") }
            .map { $0.replacingOccurrences(of: "// beak:", with: "")
                .trimmingCharacters(in: .whitespaces) }
            .map(Dependency.init)
        libraries = dependencies.reduce([]) { $0 + $1.libraries }
    }

    public init(contents: String, dependencies: [Dependency], libraries: [String], functions: [Function]) {
        self.contents = contents
        self.dependencies = dependencies
        self.libraries = libraries
        self.functions = functions
    }
}
