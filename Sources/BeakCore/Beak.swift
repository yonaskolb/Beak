import Basic
import Foundation
import PathKit
import SourceKittenFramework
import SwiftShell
import Utility

public struct BeakOptions {

    public let cachePath: Path
    public let packageName: String

    public init(cachePath: Path = "~/Documents/beak/builds", packageName: String = "BeakFile") {
        self.cachePath = cachePath.normalize()
        self.packageName = packageName
    }
}

public class Beak {

    public let version: String = "0.3.0"
    public let options: BeakOptions

    public init(options: BeakOptions) {
        self.options = options
    }

    public func execute(arguments: [String]) throws {

        let parser = ArgumentParser(commandName: "beak", usage: "[--path] [subcommand]", overview: "Beak can inspect and run functions in your swift scripts")
        let versionArgument = parser.add(option: "--version", shortName: "-v", kind: Bool.self, usage: "Prints the current version of Beak")
        _ = parser.add(option: "--path", shortName: "-p", kind: String.self, usage: "The path to a swift file. Defaults to beak.swift", completion: .filename)

        let commands = [
            "list": ListCommand(options: options, parentParser: parser),
            "function": FunctionCommand(options: options, parentParser: parser),
            "run": RunCommand(options: options, parentParser: parser),
            "edit": EditCommand(options: options, parentParser: parser),
        ]

        let parsedArguments = try parser.parse(arguments)

        if let printVersion = parsedArguments.get(versionArgument), printVersion == true {
            print(version)
            return
        }

        if let subParser = parsedArguments.subparser(parser),
            let command = commands[subParser] {
            try command.execute(parsedArguments: parsedArguments)
        } else {
            parser.printUsage(on: stdoutStream)
        }
    }
}
