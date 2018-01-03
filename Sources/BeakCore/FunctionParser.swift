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
        let parser = ArgumentParser(commandName: function.name, usage: "", overview: function.description ?? "")

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
                _ = parser.add(option: "--" + param.name, kind: T.self, usage: description)
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
            var stringValue: String?
            switch param.type {
            case .int:
                if let value = try results.get("--" + param.name, type: Int.self) {
                    stringValue = value.description
                }
            case .bool:
                if let value = try results.get("--" + param.name, type: Bool.self) {
                    stringValue = value.description
                }
            case .string:
                if let value = try results.get("--" + param.name, type: String.self), value != "nil" {
                    stringValue = value.quoted
                }
            case .other:
                if let value = try results.get("--" + param.name, type: String.self), value != "nil" {
                    stringValue = value
                }
            }
            if let stringValue = stringValue {
                parsedParams.append("\(param.name): \(stringValue)")
            } else if param.required {
                throw BeakError.missingRequiredParam(param)
            }
        }
        return parsedParams
    }
}
