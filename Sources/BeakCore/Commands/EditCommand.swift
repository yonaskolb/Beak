import Foundation
import Utility
import PathKit
import SwiftShell

class EditCommand: BeakCommand {

    init(options: BeakOptions, parentParser: ArgumentParser) {
        super.init(
            options: options,
            parentParser: parentParser,
            name: "edit",
            description: "Edit the Swift file in an Xcode Project with imported dependencies"
        )
    }

    override func execute(path: Path, beakFile: BeakFile, parsedArguments: ArgumentParser.Result) throws {

        let directory = path.absolute().parent()

        // create package
        let packagePath = options.cachePath + directory.string.replacingOccurrences(of: "/", with: "_")
        let packageManager = PackageManager(path: packagePath, name: options.packageName, beakFile: beakFile)
        try packageManager.write(filePath: path)

        // generate project
        var packageContext = CustomContext(main)
        packageContext.currentdirectory = packagePath.string
        print("Generating project")
        let buildOutput = packageContext.run(bash: "swift package generate-xcodeproj")
        if let error = buildOutput.error {
            print(buildOutput.stdout)
            print(buildOutput.stderror)
            throw error
        }

        // run package
        try packageContext.runAndPrint(bash: "open \(options.packageName).xcodeproj")
        print("Edit the file \"Sources/\(options.packageName)/main.swift\"")
        print("When you're finished you will have to manually copy and paste the file back to \(path.string)")
    }
}
