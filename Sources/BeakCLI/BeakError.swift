import BeakCore
import SwiftCLI

extension BeakError: ProcessError {

    public var message: String? {
        return "⚠️  \(description)"
    }

    public var exitStatus: Int32 {
        return 1
    }

}
