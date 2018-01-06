import Foundation
import PathKit
import Utility

class BeakCommand {

    let parser: ArgumentParser
    let options: BeakOptions
    let pathArgument: OptionArgument<String>

    init(options: BeakOptions, parentParser: ArgumentParser, name: String, description: String) {
        self.options = options
        parser = parentParser.add(subparser: name, overview: description)
        pathArgument = parser.add(option: "--path", shortName: "-p", kind: String.self, usage: "The path to a swift file. Defaults to beak.swift", completion: .filename)
    }

    func execute(parsedArguments: ArgumentParser.Result) throws {
        let path = Path(parsedArguments.get(pathArgument) ?? "beak.swift").normalize()
        let beakFile = try BeakFile(path: path)
        try execute(path: path, beakFile: beakFile, parsedArguments: parsedArguments)
    }

    func execute(path: Path, beakFile: BeakFile, parsedArguments: ArgumentParser.Result) throws {
    }
}
