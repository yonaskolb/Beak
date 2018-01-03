import Foundation
import Utility

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
        let parser = ArgumentParser(commandName: function.name, usage: "", overview: function.docsDescription ?? "")

        for param in function.params {
            func getOption<T: ArgumentKind>(type: T.Type) {

                var description = param.description
                if let defaultValue = param.defaultValue {
                    if let desc = description {
                        description = "\(desc) (default: \(defaultValue))"
                    } else {
                        description = "default: \(defaultValue)"
                    }
                }
                if param.unnamed {
                    _ = parser.add(positional: param.name, kind: type, optional: !param.required, usage: description)
                } else {
                    _ = parser.add(option: "--" + param.name, kind: T.self, usage: description)
                }
            }
            switch param.type {
            case .bool:
                getOption(type: Bool.self)
            case .int:
                getOption(type: Int.self)
            case .string, .other:
                getOption(type: String.self)
            }
        }

        let results = try parser.parse(arguments)

        var parsedParams: [String] = []

        for param in function.params {
            var argumentName = param.name
            if !param.unnamed {
                argumentName = "--" + argumentName
            }
            var stringValue: String?
            switch param.type {
            case .int:
                if let value = try results.get(argumentName, type: Int.self) {
                    stringValue = value.description
                }
            case .bool:
                if let value = try results.get(argumentName, type: Bool.self) {
                    stringValue = value.description
                }
            case .string:
                if let value = try results.get(argumentName, type: String.self), value != "nil" {
                    stringValue = value.quoted
                }
            case .other:
                if let value = try results.get(argumentName, type: String.self), value != "nil" {
                    stringValue = value
                }
            }
            if let stringValue = stringValue {
                if param.unnamed {
                    parsedParams.append(stringValue)
                } else {
                    parsedParams.append("\(param.name): \(stringValue)")
                }
            } else if param.required {
                throw BeakError.missingRequiredParam(param)
            }
        }
        return parsedParams
    }
}
