import SwiftCLI
import BeakCore
import Foundation

public class BeakCLI {

    public let version: String = "0.3.5"
    public let options: BeakOptions

    public init(options: BeakOptions) {
        self.options = options
    }

    public func execute(arguments: [String]? = nil) {
        let cli = CLI(name: "beak", version: version, description: "Beak can inspect and run functions in your swift scripts")
        cli.globalOptions.append(GlobalOptions.path)
        cli.commands = [
            ListCommand(),
            FunctionCommand(),
            RunCommand(options: options),
            EditCommand(options: options),
        ]

        let status: Int32
        if let arguments = arguments {
            status = cli.go(with: arguments)
        } else {
            status = cli.go()
        }
        exit(status)
    }
}
