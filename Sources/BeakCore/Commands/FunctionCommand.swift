import Foundation
import Utility
import PathKit

class FunctionCommand: BeakCommand {

    var functionArgument: PositionalArgument<String>!
    
    init(options: BeakOptions, parentParser: ArgumentParser) {
        super.init(
            options: options,
            parentParser: parentParser,
            name: "function",
            description: "Info about a specific function"
        )
        functionArgument = self.parser.add(positional: "function", kind: String.self, optional: false, usage: "The function to get info about", completion: ShellCompletion.none)
    }

    override func execute(path: Path, beakFile: BeakFile, parsedArguments: ArgumentParser.Result) throws {
        let functionName = parsedArguments.get(functionArgument)!
        guard let function = beakFile.functions.first(where: { $0.name == functionName }) else {
            throw BeakError.invalidFunction(functionName)
        }
        let params = function.params.map { param in
            "\(param.name): \(param.optionalType)\(param.defaultValue != nil ? " = \(param.defaultValue!)" : "")\(param.description != nil ? "  - \(param.description!)" : "")"
        }
        print("\(function.name):\(function.docsDescription != nil ? " \(function.docsDescription!)" : "")\n  \(params.joined(separator: "\n  "))")
    }
}

