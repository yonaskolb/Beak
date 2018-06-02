import PathKit
import SwiftCLI
import BeakCore

class EditCommand: BeakCommand {

    let name = "edit"
    let shortDescription = "Edit the Swift file in an Xcode Project with imported dependencies"

    let options: BeakOptions

    init(options: BeakOptions) {
        self.options = options
    }

    func execute(path: Path, beakFile: BeakFile) throws {
        let directory = path.absolute().parent()

        // create package
        let packagePath = options.cachePath + directory.string.replacingOccurrences(of: "/", with: "_")
        let packageManager = PackageManager(path: packagePath, name: options.packageName, beakFile: beakFile)
        try packageManager.write(filePath: path)

        // generate project
        do {
            _ = try capture("swift", arguments: ["package", "generate-xcodeproj"], directory: packagePath.string)
        } catch let error as CaptureError {
            stderr <<< error.captured.rawStdout
            stderr <<< error.captured.rawStderr
            throw error
        }
        stdout <<< "Generating project..."

        // run package
        try run("open", arguments: ["\(options.packageName).xcodeproj"], directory: packagePath.string)

        stdout <<< "Edit the file \"Sources/\(options.packageName)/main.swift\""
        stdout <<< "When you're finished type \"c\" to commit the changes and copy the file back to \(path.string), otherwise type anything else"

        let line = readLine()
        if line?.lowercased() == "c" {
            try path.delete()
            try packageManager.mainFilePath.copy(path)
            stdout <<< "Copied edited file back to \(path.string)"
        } else {
            stdout <<< "Changes not copied back to \(path.string)"
        }
    }
}
