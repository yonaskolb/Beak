import Foundation
import Utility
import PathKit

class ListCommand: BeakCommand {

    init(options: BeakOptions, parentParser: ArgumentParser) {
        super.init(
            options: options,
            parentParser: parentParser,
            name: "list",
            description: "Lists all functions"
        )
    }

    override func execute(path: Path, beakFile: BeakFile, parsedArguments: ArgumentParser.Result) throws {
        let functions = beakFile.functions.map { function in
            "\(function.name): \(function.docsDescription ?? "")"
        }
        print("Functions:\n\n  \(functions.joined(separator: "\n  "))\n")
    }
}
