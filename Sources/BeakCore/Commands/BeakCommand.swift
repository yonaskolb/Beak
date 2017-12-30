//
//  Command.swift
//  BeakCore
//
//  Created by Yonas Kolb on 31/12/17.
//

import Foundation
import Utility
import PathKit

class BeakCommand {

    let parser: ArgumentParser
    let pathArgument: OptionArgument<String>
    let options: BeakOptions

    init(options: BeakOptions, parentParser: ArgumentParser, name: String, description: String) {
        self.options = options
        self.parser = parentParser.add(subparser: name, overview: description)
        pathArgument = parser.add(option: "--path", shortName: "-p", kind: String.self, usage: "The path to a swift file", completion: .filename)
    }

    func execute(parsedArguments: ArgumentParser.Result) throws {
        let path = Path(parsedArguments.get(pathArgument) ?? "beak.swift").normalize()
        let beakFile = try BeakFile(path: path)
        try execute(path: path, beakFile: beakFile, parsedArguments: parsedArguments)
    }

    func execute(path: Path, beakFile: BeakFile, parsedArguments: ArgumentParser.Result) throws {

    }
}
