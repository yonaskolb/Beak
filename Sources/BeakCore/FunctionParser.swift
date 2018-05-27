import Foundation
import SwiftCLI

public struct FunctionParser {

    public static func getFunctionCall(function: Function, arguments: [String]) throws -> String {
        let params = try FunctionParser.getParams(function: function, arguments: arguments)
        var functionCall = "\(function.name)(\(params.joined(separator: ", ")))"
        if function.throwing {
            functionCall = """
            do {
                try \(functionCall)
            } catch {
                print(error)
                exit(1)
            }
            """
        }
        return functionCall
    }

    static func getParams(function: Function, arguments: [String]) throws -> [String] {
        var parsedParams: [String] = []
        var args = arguments
        for param in function.params {
            let possibleValue: String?
            if param.unnamed {
                possibleValue = args.isEmpty ? nil : args.removeFirst()
            } else {
                if let index = args.index(where: { $0 == "--\(param.name)" }), index + 1 < args.count {
                    args.remove(at: index)
                    possibleValue = args.remove(at: index)
                } else {
                    possibleValue = nil
                }
            }
            
            guard var value = possibleValue else {
                if param.required {
                    throw BeakError.missingRequiredParam(param)
                } else {
                    continue
                }
            }
            
            if value == "nil" {
                if !param.optional {
                    throw BeakError.conversionError(param, value)
                }
            } else {
                switch param.type {
                case .bool:
                    guard let converted = Bool.convert(from: value) else {
                        throw BeakError.conversionError(param, value)
                    }
                    value = converted.description
                case .int:
                    guard let converted = Int.convert(from: value) else {
                        throw BeakError.conversionError(param, value)
                    }
                    value = converted.description
                case .string:
                    value = value.quoted
                case .other: break
                }
            }
            
            if param.unnamed {
                parsedParams.append(value)
            } else {
                parsedParams.append("\(param.name): \(value)")
            }
        }
        return parsedParams
    }
}
