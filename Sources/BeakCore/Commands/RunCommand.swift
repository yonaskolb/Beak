import PathKit
import SwiftShell
import SwiftCLI

class RunCommand: BeakCommand {

    let name = "run"
    let shortDescription = "Run a function"

    let function = OptionalParameter()
    let functionArgs = OptionalCollectedParameter()
    
    let options: BeakOptions

    init(options: BeakOptions) {
        self.options = options
    }

    func execute(path: Path, beakFile: BeakFile) throws {
        var functionCall: String?

        // parse function call
        if let functionName = function.value {
            guard let function = beakFile.functions.first(where: { $0.name == functionName }) else {
                throw BeakError.invalidFunction(functionName)
            }
            functionCall = try FunctionParser.getFunctionCall(function: function, arguments: functionArgs.value)
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
