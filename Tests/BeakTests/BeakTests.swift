@testable import BeakCore
import PathKit
import Spectre
import XCTest

class BeakTests: XCTestCase {

    func testBeak() {

        describe("Beak File") {

            $0.it("parses functions") {
                func expectFunction(_ function: String, parsedTo expectedFunction: Function) throws {
                    let functions = try SwiftParser.parseFunctions(file: "// = : ? \n\(function)")
                    guard let parsedFunction = functions.first else {
                        throw failure("Could not find function")
                    }
                    try expect(parsedFunction) == expectedFunction
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
                ], docsDescription: "My description on multiple lines"))

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
                // swift-tools-version:4.0

                import PackageDescription

                let package = Package(
                    name: "Test",
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
