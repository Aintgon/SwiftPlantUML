import Foundation

class PlantUMLContext {
    private(set) var configuration: Configuration

    var uniqElementNames: [String] = []
    var uniqElementAndTypes: [String: String] = [:]
    // var style: [String: String] = [:]
    private(set) var connections: [String] = []
    private(set) var extnConnections: [String] = []

    private let linkTypeInheritance = "<|--"
    private let linkTypeRealize = "<|.."
    private let linkTypeDependency = "<.."
//    private let linkTypeAssociation = "-->"
//    private let linkTypeAggregation = "--o"
//    private let linkTypeComposition = "--*"
    private let linkTypeGeneric = "--"

    init(configuration: Configuration = .default) {
        self.configuration = configuration
    }

    var index = 0

    func addLinking(item: SyntaxStructure, parent: SyntaxStructure) {
        let linkTo = parent.name?.removeAngleBracketsWithContent() ?? "___"
        guard skipLinking(element: parent, basedOn: configuration.relationships.inheritance?.exclude) == false else { return }
        let namedConnection = (uniqElementAndTypes[linkTo] != nil) ? "\(uniqElementAndTypes[linkTo] ?? "--ERROR--")" : "inherits"
        var linkTypeKey = item.name! + "LinkType"

        if uniqElementAndTypes[linkTo] == "confirms to" {
            linkTypeKey = linkTo + "LinkType"
        }

        var connect = "\(linkTo) \(uniqElementAndTypes[linkTypeKey] ?? "--ERROR--") \(item.name!)"
        if let relStyle = relationshipStyle(for: namedConnection)?.plantuml {
            connect += " \(relStyle)"
        }
        if let relationshipLabel = relationshipLabel(for: namedConnection) {
            connect += " : \(relationshipLabel)"
        }
        connections.append(connect)
    }

    private func skipLinking(element: SyntaxStructure, basedOn excludeElements: [String]?) -> Bool {
        guard let elementName = element.name else { return false }
        guard let excludedElements = excludeElements else { return false }
        return !excludedElements.filter { elementName.isMatching(searchPattern: $0) }.isEmpty
    }

    func relationshipLabel(for name: String) -> String? {
        if name == "inherits" {
            return configuration.relationships.inheritance?.label
        } else if name == "confirms to" {
            return configuration.relationships.realize?.label
        } else if name == "ext" {
            return configuration.relationships.dependency?.label
        } else {
            return nil
        }
    }

    func relationshipStyle(for name: String) -> RelationshipStyle? {
        if name == "inherits" {
            return configuration.relationships.inheritance?.style
        } else if name == "confirms to" {
            return configuration.relationships.realize?.style
        } else if name == "ext" {
            return configuration.relationships.dependency?.style
        } else {
            return nil
        }
    }

    func uniqName(item: SyntaxStructure, relationship: String) -> String {
        guard let name = item.name else { return "" }
        var newName = name
        let linkTypeKey = name + "LinkType"
        if uniqElementNames.contains(name) {
            newName += "\(index)"
            index += 1
            if item.kind == ElementKind.extension {
                var connect = "\(name) \(linkTypeDependency) \(newName)"
                if let relStyle = configuration.relationships.dependency?.style?.plantuml {
                    connect += " \(relStyle)"
                }
                connect += " : \(configuration.relationships.dependency?.label ?? relationship)"
                extnConnections.append(connect) // "aPublicStruct <.. aPublicStruct0 : ext"
            }
        } else {
            uniqElementNames.append(name)
            uniqElementAndTypes[name] = relationship

            if relationship == "inherits" {
                uniqElementAndTypes[linkTypeKey] = linkTypeInheritance
            } else if relationship == "confirms to" {
                uniqElementAndTypes[linkTypeKey] = linkTypeRealize
            } else if relationship == "ext" {
                uniqElementAndTypes[linkTypeKey] = linkTypeDependency
            } else {
                uniqElementAndTypes[linkTypeKey] = linkTypeGeneric
            }
        }
        return newName
    }
}
