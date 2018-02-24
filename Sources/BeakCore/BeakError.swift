import Foundation
import SourceKittenFramework

public enum BeakError: Error, CustomStringConvertible {
    case fileNotFound(String)
    case compileError(String)
    case invalidFunction(String)
    case missingRequiredParam(Function.Param)
    case parsingError(SwiftStructure)

    public var description: String {
        switch self {
        case let .fileNotFound(file): return "File not found: \(file)"
        case let .compileError(error): return "File could not be compiled: \(error)"
        case let .invalidFunction(function): return "Function \(function) was not found"
        case let .missingRequiredParam(param): return "Missing required param \(param.name)"
        case let .parsingError(structure): return "Could not parse Beak file structure:\n\(toJSON(structure))"
        }
    }
}
