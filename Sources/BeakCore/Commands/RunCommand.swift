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
        functionArgument = self.parser.add(positional: "function", kind: [String].self, optional: true, strategy: .remaining, usage: "The function to run", completion: ShellCompletion.none)
    }

    override func execute(path: Path, beakFile: BeakFile, parsedArguments: ArgumentParser.Result) throws {
        var functionArguments = parsedArguments.get(functionArgument) ?? []


        var functionCall: String?

        // parse function call
        if !functionArguments.isEmpty {
            let functionName = functionArguments[0]
            functionArguments = Array(functionArguments.dropFirst())

            guard let function = beakFile.functions.first(where: { $0.name == functionName }) else {
                throw BeakError.invalidFunction(functionName)
            }
            functionCall = try FunctionParser.getFunctionCall(function: function, arguments: functionArguments)
        }

        // create package
        let directory = path.absolute().parent()
        let packagePath = options.cachePath + directory.string.replacingOccurrences(of: "/", with: "_")
        let packageManager = PackageManager(path: packagePath, name: options.packageName, beakFile: beakFile)
        try packageManager.write(functionCall: functionCall)

        // build package
        var packageContext = CustomContext(main)
        packageContext.currentdirectory = packagePath.string
        let buildOutput = packageContext.run(bash: "swift build --disable-sandbox")
        if let error = buildOutput.error {
            print(buildOutput.stdout)
            print(buildOutput.stderror)
            throw error
        }

        // run package
        try runAndPrint(bash: "\(packagePath.string)/.build/debug/\(options.packageName)")
    }
}
