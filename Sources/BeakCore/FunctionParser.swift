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

        var stringArguments: [String: OptionArgument<String>] = [:]
        var intArguments: [String: OptionArgument<Int>] = [:]
        var boolArguments: [String: OptionArgument<Bool>] = [:]

        for param in function.params {
            func getOption<T: ArgumentKind>() -> OptionArgument<T> {
                return parser.add(option: "--" + param.name, kind: T.self, usage: param.description)
            }
            switch param.type {
            case .bool:
                boolArguments[param.name] = getOption()
            case .int:
                intArguments[param.name] = getOption()
            case .string, .other:
                stringArguments[param.name] = getOption()
            }
        }

        let results = try parser.parse(arguments)

        var parsedParams: [String] = []

        for param in function.params {
            var stringValue: String?
            switch param.type {
            case .int:
                if let argument = intArguments[param.name],
                    let value = results.get(argument) {
                    stringValue = value.description
                }
            case .bool:
                if let argument = boolArguments[param.name],
                    let value = results.get(argument) {
                    stringValue = value.description
                }
            case .string:
                if let argument = stringArguments[param.name],
                    let value = results.get(argument), value != "nil" {
                    stringValue = value.quoted
                }
            case .other:
                if let argument = stringArguments[param.name],
                    let value = results.get(argument), value != "nil" {
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
