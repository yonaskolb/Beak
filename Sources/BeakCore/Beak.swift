import PathKit
import SwiftCLI

public struct BeakOptions {

    public let cachePath: Path
    public let packageName: String

    public init(cachePath: Path = "~/Documents/beak/builds", packageName: String = "BeakFile") {
        self.cachePath = cachePath.normalize()
        self.packageName = packageName
    }
}

public class Beak {

    public let version: String = "0.3.5"
    public let options: BeakOptions

    public init(options: BeakOptions) {
        self.options = options
    }

    public func execute() -> Never {
        let cli = CLI(name: "beak", version: version, description: "Beak can inspect and run functions in your swift scripts")
        cli.globalOptions.append(_pathKey)
        cli.commands = [
            ListCommand(),
            FunctionCommand(),
            RunCommand(options: options),
            EditCommand(options: options)
        ]
        cli.goAndExit()
    }
}
