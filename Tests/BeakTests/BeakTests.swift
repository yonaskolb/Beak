@testable import BeakCore
import PathKit
import Spectre
import XCTest
import SourceKittenFramework

class BeakTests: XCTestCase {

    func testBeak() {

        describe("Beak File") {

            $0.it("parses emoji") {
                let contents = """
                // emoji comment 🐦
                func adam() throws -> String {}
                """
                let file = File(contents: contents)
                let structure = try Structure(file: file)

                let function = structure.dictionary.substructure.first!

                try expect(function.string(.name)) == "adam()"
                try expect(Substring.name.extract(from: function, contents: contents)) == "adam()"
                try expect(Substring.nameSuffix.extract(from: function, contents: contents)) == "throws -> String {}"
            }

            $0.it("parses functions") {
                func expectFunction(_ function: String, parsedTo expectedFunction: Function, file: String = #file, line: Int = #line) throws {
                    let functions = try SwiftParser.parseFunctions(file: "// = : ? \n\(function)")
                    guard let parsedFunction = functions.first else {
                        throw failure("Could not find function")
                    }
                    try expect(parsedFunction, file: file, line: line) == expectedFunction
                }

                try expectFunction("""
                public func normal(
                    myInt: Int,
                    myString: String,
                    myBool: Bool,
                    custom: MyType
                ){ }
                """, parsedTo: Function(name: "normal", params: [
                    .init(name: "myInt", type: .int, optional: false),
                    .init(name: "myString", type: .string, optional: false),
                    .init(name: "myBool", type: .bool, optional: false),
                    .init(name: "custom", type: .other("MyType"), optional: false),
                ]))

                try expectFunction("""
                public func defaults(
                    myInt: Int = 5,
                    myString: String? = "default",
                    myBool: Bool = true,
                    custom: MyType = .default
                ){ }
                """, parsedTo: Function(name: "defaults", params: [
                    .init(name: "myInt", type: .int, optional: false, defaultValue: "5"),
                    .init(name: "myString", type: .string, optional: true, defaultValue: "\"default\""),
                    .init(name: "myBool", type: .bool, optional: false, defaultValue: "true"),
                    .init(name: "custom", type: .other("MyType"), optional: false, defaultValue: ".default"),
                ]))

                try expectFunction("""
                /// My description on
                /// multiple lines
                /// - Parameters:
                ///   - myInt: the int value
                ///   - myString: the string value
                public func described(
                    myInt: Int,
                    myString internal: String?
                ){ }
                """, parsedTo: Function(name: "described", params: [
                    .init(name: "myInt", type: .int, optional: false, description: "the int value"),
                    .init(name: "myString", type: .string, optional: true, description: "the string value"),
                ], docsDescription: "My description on\nmultiple lines"))

                try expectFunction("""
                public func topFunction(path: String) {
                    let x = { param in }
                }
                """, parsedTo: Function(name: "topFunction", params: [
                    .init(name: "path", type: .string, optional: false),
                ]))

                try expectFunction("public func unnamed(_ noName: String) {}", parsedTo: Function(name: "unnamed", params: [
                    .init(name: "noName", type: .string, optional: false, unnamed: true),
                ]))

                try expectFunction("public func named(label name: String?) {}", parsedTo: Function(name: "named", params: [
                    .init(name: "label", type: .string, optional: true),
                ]))

                try expectFunction("public func unnamed(_ name: String) {}", parsedTo: Function(name: "unnamed", params: [
                    .init(name: "name", type: .string, optional: false, unnamed: true),
                ]))

                try expectFunction("public func noParams() {}", parsedTo: Function(name: "noParams"))
                try expectFunction("public func throwing() throws {}", parsedTo: Function(name: "throwing", throwing: true))
                try expectFunction("public func throwing(_ version: String) throws {}", parsedTo: Function(name: "throwing", params: [
                    .init(name: "version", type: .string, optional: false, unnamed: true),
                ], throwing: true))

            }

            $0.it("parses dependencies") {

                let file = """
                #!/usr/bin/env beak --path

                // beak: name/repo@4.2.0
                // beak: https://github.com/name/repo2.git lib1 lib2 @ branch:v4
                // beak: name2/repo3 @ exact:4.3.0
                // other comment in beak file

                """

                let file2 = """
                // beak: name/repo@4.2.0
                // beak: https://github.com/name/repo2.git lib1 lib2 @ branch:v4
                // beak: name2/repo3 @ exact:4.3.0
                """

                let dependencies: [Dependency] = [
                    .init(name: "repo", package: "https://github.com/name/repo.git", requirement: ".exact(\"4.2.0\")", libraries: ["repo"]),
                    .init(name: "repo2", package: "https://github.com/name/repo2.git", requirement: ".branch(\"v4\")", libraries: ["lib1", "lib2"]),
                    .init(name: "repo3", package: "https://github.com/name2/repo3.git", requirement: ".exact(\"4.3.0\")", libraries: ["repo3"]),
                ]

                let beakFile = try BeakFile(contents: file)
                let beakFile2 = try BeakFile(contents: file2)
                try expect(beakFile.dependencies) == dependencies
                try expect(beakFile2.dependencies) == dependencies
            }

            $0.it("parses beak file") {
                let path = Path(#file) + "../../../beak.swift"
                let contents: String = try path.read()
                let beakFile = try BeakFile(path: path)

                let expectedBeakFile = BeakFile(
                    contents: contents,
                    dependencies: [
                        Dependency(
                            name: "SwiftShell",
                            package: "https://github.com/kareman/SwiftShell.git",
                            requirement: ".exact(\"5.0.0\")",
                            libraries: ["SwiftShell"]
                        ),
                        Dependency(
                            name: "Regex",
                            package: "https://github.com/sharplet/Regex.git",
                            requirement: ".exact(\"2.0.0\")",
                            libraries: ["Regex"]
                        ),
                        Dependency(
                            name: "PathKit",
                            package: "https://github.com/kylef/PathKit.git",
                            requirement: ".exact(\"1.0.0\")",
                            libraries: ["PathKit"]
                        ),
                    ],
                    functions: [
                        Function(
                            name: "formatCode",
                            params: [],
                            throwing: true,
                            docsDescription: "Formats all the code in the project"
                        ),
                        Function(
                            name: "install",
                            params: [
                                Function.Param(
                                    name: "directory",
                                    type: .string,
                                    optional: false,
                                    defaultValue: "\"/usr/local/bin\"",
                                    unnamed: false,
                                    description: "The directory to install beak"
                                ),
                            ],
                            throwing: true,
                            docsDescription: "Installs beak"
                        ),
                        Function(
                            name: "updateBrew",
                            params: [
                                Function.Param(
                                    name: "version",
                                    type: .string,
                                    optional: false,
                                    defaultValue: nil,
                                    unnamed: true,
                                    description: "The version to release"
                                ),
                            ],
                            throwing: true,
                            docsDescription: "Updates homebrew formula to a certain version"
                        ),
                        Function(
                            name: "release",
                            params: [
                                Function.Param(
                                    name: "version",
                                    type: .string,
                                    optional: false,
                                    defaultValue: nil,
                                    unnamed: true,
                                    description: "The version to release"
                                ),
                            ],
                            throwing: true,
                            docsDescription: "Releases a new version of Beak"
                        ),
                    ]
                )

                try expect(beakFile) == expectedBeakFile
            }
        }

        describe("Package writer") {

            $0.it("writes functions") {

                func expectFunction(_ function: Function, arguments: [String], toWrite expectedString: String) throws {
                    try expect(FunctionParser.getFunctionCall(function: function, arguments: arguments)) == expectedString
                }

                try expectFunction(
                    Function(name: "build", params: [], throwing: false),
                    arguments: [],
                    toWrite: "build()"
                )

                try expectFunction(
                    Function(name: "build", params: [
                        .init(name: "version", type: .string, unnamed: true),
                        .init(name: "enum", type: .other("MyEnum")),
                        .init(name: "count", type: .int),
                    ], throwing: false),
                    arguments: [
                        "1.2.0",
                        "--enum",
                        ".case",
                        "--count",
                        "3",
                    ],
                    toWrite: "build(\"1.2.0\", enum: .case, count: 3)"
                )
            }

            $0.it("writes package files") {
                let path = Path.temporary + "beak-package"
                try? path.delete()

                let beakFile = try BeakFile(contents: "public func doThing(){}\n")
                let packageManager = PackageManager(path: path, name: "Test", beakFile: beakFile)
                try packageManager.write(functionCall: "doThing()")

                try expect(packageManager.mainFilePath.exists).to.beTrue()
                try expect(packageManager.packagePath.exists).to.beTrue()

                let mainFile: String = try packageManager.mainFilePath.read()
                try expect(mainFile) == beakFile.contents + "\n\ndoThing()"

                try? path.delete()
            }

            $0.it("writes package") {

                let dependencies: [Dependency] = [
                    .init(name: "repo", package: "https://github.com/name/repo.git", requirement: ".exact(\"4.2.0\")", libraries: ["repo"]),
                    .init(name: "repo2", package: "https://github.com/name/repo2.git", requirement: ".branch(\"v4\")", libraries: ["lib1", "lib2"]),
                    .init(name: "repo3", package: "https://github.com/name2/repo3.git", requirement: ".exact(\"4.3.0\")", libraries: ["repo3"]),
                ]

                let beakFile = BeakFile(contents: "", dependencies: dependencies, functions: [])
                let package = PackageManager.createPackage(name: "Test", beakFile: beakFile)

                let expectedPackage = """
                // swift-tools-version:5.0

                import PackageDescription

                let package = Package(
                    name: "Test",
                    platforms: [
                        .macOS(.v10_13),
                    ],
                    dependencies: [
                        .package(url: "https://github.com/name/repo.git", .exact("4.2.0")),
                        .package(url: "https://github.com/name/repo2.git", .branch("v4")),
                        .package(url: "https://github.com/name2/repo3.git", .exact("4.3.0")),
                    ],
                    targets: [
                        .target(
                            name: "Test",
                            dependencies: [
                                "repo",
                                "lib1",
                                "lib2",
                                "repo3",
                            ]
                        )
                    ]
                )
                """

                try expect(package) == expectedPackage
            }
        }
    }
}
