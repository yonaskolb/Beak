import Foundation

public struct Dependency: Equatable {
    public let name: String
    public let package: String
    public let requirement: String
    public let libraries: [String]

    public init(string: String) {
        let versionSplit = string
            .split(separator: "@")
            .map { String($0)
                .trimmingCharacters(in: .whitespaces) }
        let packageAndLibraries = versionSplit[0]
        var package = packageAndLibraries
        var libraries: [String]?
        if packageAndLibraries.contains("[") && packageAndLibraries.contains("]") {
            package = String(
                packageAndLibraries
                    .split(separator: "[").first!
            ).trimmingCharacters(in: .whitespaces)

            libraries = packageAndLibraries
                .split(separator: "[").last!
                .split(separator: "]").first!
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespaces) }
        }
        let version = versionSplit[1]
        self.init(package: package, version: version, libraries: libraries)
    }

    public init(package: String, version: String, libraries: [String]? = nil) {
        self.package = Dependency.getPackage(name: package)
        let name = String(package.split(separator: "/").last!.split(separator: ".").first!)
        self.name = name
        requirement = Dependency.getRequirement(version: version)
        self.libraries = libraries ?? [name]
    }

    public init(name: String, package: String, requirement: String, libraries: [String]) {
        self.package = package
        self.name = name
        self.requirement = requirement
        self.libraries = libraries
    }

    public static func getPackage(name: String) -> String {
        if name.split(separator: "/").count == 2 {
            return "https://github.com/\(name).git"
        } else {
            return name
        }
    }

    public static func getRequirement(version: String) -> String {
        if version.hasPrefix(".") {
            return version
        }
        let parts = version.split(separator: ":").map(String.init)
        if parts.count == 1 {
            return ".exact(\(version.quoted))"
        }
        let type = parts[0]
        var version = parts[1]
        if !version.hasPrefix("\"") && !version.hasSuffix("\"") {
            version = version.quoted
        }
        return ".\(type)(\(version))"
    }

    public static func == (lhs: Dependency, rhs: Dependency) -> Bool {
        return lhs.name == rhs.name
            && lhs.package == rhs.package
            && lhs.requirement == rhs.requirement
            && lhs.libraries == rhs.libraries
    }
}
