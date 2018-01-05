import Foundation
import PathKit
import Utility

class BeakCommand {

    let parser: ArgumentParser
    let options: BeakOptions

    init(options: BeakOptions, parentParser: ArgumentParser, name: String, description: String) {
        self.options = options
        parser = parentParser.add(subparser: name, overview: description)
    }

    func execute(parsedArguments: ArgumentParser.Result, path: Path) throws {
        let beakFile = try BeakFile(path: path)
        try execute(path: path, beakFile: beakFile, parsedArguments: parsedArguments)
    }

    func execute(path: Path, beakFile: BeakFile, parsedArguments: ArgumentParser.Result) throws {
    }
}
