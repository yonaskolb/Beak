import Foundation
import SourceKittenFramework
import Utility

public struct SwiftParser {

    public static func parseFunctions(file: String) throws -> [Function] {
        let file = File(contents: file)
        let structure = Structure(file: file)
        if let diagnostics = structure.dictionary["key.diagnostics"] as? [SwiftStructure],
            let diagnostic = diagnostics.first(where: { ($0["key.severity"] as? String)?.hasSuffix("error") ?? false }),
            let description = diagnostic["key.description"] as? String {
            throw BeakError.compileError(description)
        }

        // merge docs into structure
        var subStructure = structure.dictionary.substructure
        let swiftDocs = SwiftDocs(file: file, arguments: [])!
        for (index, docStructure) in swiftDocs.docsDictionary.substructure.enumerated() {
            subStructure[index][SwiftDocKey.documentationComment.rawValue] = docStructure[SwiftDocKey.documentationComment.rawValue]
        }
        return subStructure
            .filter { $0.kind == .functionFree && $0.accessibility == .public }
            .map { SwiftParser.parseFunction(structure: $0, contents: file.contents) }
    }

    private static func parseFunction(structure: SwiftStructure, contents: String) -> Function {
        let functionSignature = structure.string(.name)!
        let docs = structure.string(.documentationComment)
        var paramDescriptions: [String: String] = [:]
        var description: String?

        if let docs = docs {
            let docsSplit = docs.split(around: "- Parameters:")
            description = docsSplit.0.trimmingCharacters(in: .whitespacesAndNewlines)
            if let paramDocs = docsSplit.1 {
                let regEx = try! NSRegularExpression(pattern: "  - (.*?): (.*?)$", options: [.anchorsMatchLines])
                let matches = regEx.matches(in: paramDocs, options: [], range: NSRange(location: 0, length: paramDocs.count))

                for match in matches {

                    let nameRange = match.range(at: 1)
                    let name = paramDocs
                        .substring(start: nameRange.location, length: nameRange.length)
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    let descriptionRange = match.range(at: 2)
                    let description = paramDocs
                        .substring(start: descriptionRange.location, length: descriptionRange.length)
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    paramDescriptions[name] = description
                }
            }
        } else {
            description = nil
        }
        let name = String(functionSignature.split(separator: "(").first!)
        let publicNames = functionSignature.split(separator: "(").last!.split(separator: ":")
        var index = 0
        let params: [Function.Param] = structure.substructure.filter { $0.kind == .varParameter }.map { structure in
            let paramName = structure.string(.name) ?? ""
            var name = String(publicNames[index])
            var unnamed = false
            if name == "_" {
                name = paramName
                unnamed = true
            }
            index += 1

            // get default value
            let paramDeclaration = Substring.key.extract(from: structure, contents: contents)!
            let expressionSplit = paramDeclaration.split(separator: "=")
                .map(String.init)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            let defaultValue = expressionSplit.count > 1 ? expressionSplit[1] : nil

            let typeName = structure.string(.typeName)!
            let optional: Bool
            let type: String
            if typeName.hasSuffix("?") {
                optional = true
                type = String(typeName.dropLast())
            } else {
                optional = false
                type = typeName
            }
            return Function.Param(
                name: name,
                type: Function.Param.ParamType(string: type),
                optional: optional,
                defaultValue: defaultValue,
                unnamed: unnamed,
                description: paramDescriptions[name]
            )
        }
        let throwing: Bool
        if let nameSuffix = Substring.nameSuffix.extract(from: structure, contents: contents),
            nameSuffix.hasPrefix("throws") {
            throwing = true
        } else {
            throwing = false
        }
        return Function(name: name, params: params, throwing: throwing, docsDescription: description)
    }
}
