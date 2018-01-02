import Foundation
import Utility
import PathKit
import SwiftShell

class RunCommand: BeakCommand {

    var functionArgument: PositionalArgument<[String]>!

    init(options: BeakOptions, parentParser: ArgumentParser) {
        super.init(
            options: options,
            parentParser: parentParser,
            name: "run",
            description: "Run a function"
        )
        functionArgument = self.parser.add(positional: "function", kind: [String].self, optional: false, strategy: .remaining, usage: "The function to run", completion: ShellCompletion.none)
    }

    override func execute(path: Path, beakFile: BeakFile, parsedArguments: ArgumentParser.Result) throws {
        var functionArguments = parsedArguments.get(functionArgument) ?? []
        let functionName = functionArguments[0]
        functionArguments = Array(functionArguments.dropFirst())
        
        let directory = path.absolute().parent()
        guard let function = beakFile.functions.first(where: { $0.name == functionName }) else {
            throw BeakError.invalidFunction(functionName)
        }

        // parse function
        let functionCall = try FunctionParser.getFunctionCall(function: function, arguments: functionArguments)

        // create package
        let packageName = "BeakFile"
        let packageManager = PackageManager(name: packageName, beakFile: beakFile, functionCall: functionCall)
        let packagePath = options.cachePath + directory.string.replacingOccurrences(of: "/", with: "_")
        try packageManager.write(path: packagePath)

        // build package
        var buildContext = CustomContext(main)
        buildContext.currentdirectory = packagePath.string
        let buildOutput = buildContext.run(bash: "swift build --disable-sandbox")
        if let error = buildOutput.error {
            print(buildOutput.stdout)
            print(buildOutput.stderror)
            throw error
        }

        // run package
        try runAndPrint(bash: "\(packagePath.string)/.build/debug/\(packageName)")
    }
}
