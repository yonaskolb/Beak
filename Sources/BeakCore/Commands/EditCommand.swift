import PathKit
import SwiftShell

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
        var packageContext = CustomContext(main)
        packageContext.currentdirectory = packagePath.string
        let buildOutput = packageContext.run(bash: "swift package generate-xcodeproj")
        if let error = buildOutput.error {
            print(buildOutput.stdout)
            print(buildOutput.stderror)
            throw error
        }
        print("Generating project...")

        // run package
        try packageContext.runAndPrint(bash: "open \(options.packageName).xcodeproj")
        print("Edit the file \"Sources/\(options.packageName)/main.swift\"")
        print("When you're finished type \"c\" to commit the changes and copy the file back to \(path.string), otherwise type anything else")
        let line = readLine()
        if line?.lowercased() == "c" {
            try path.delete()
            try packageManager.mainFilePath.copy(path)
            print("Copied edited file back to \(path.string)")
        } else {
            print("Changes not copied back to \(path.string)")
        }
    }
}
