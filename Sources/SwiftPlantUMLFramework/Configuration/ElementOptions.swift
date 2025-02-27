import Foundation

/// Options which and how elements shall be considered for class diagram generation
public struct ElementOptions: Codable {
    /// only elements (classes, structs, ...) with the specified access level will be processed and rendered in the class diagram
    public private(set) var havingAccessLevel: [AccessLevel] = [.open, .public, .internal, .private]
    /// only members (properties and functions) with the specified access level will be processed and renderd in the class diagram
    public private(set) var showMembersWithAccessLevel: [AccessLevel] = [.open, .public, .internal, .private]

    /// show nested types
    public private(set) var showNestedTypes: Bool = true

    /// show generic type and type constraint information for a struct/class (default: true)
    public private(set) var showGenerics: Bool = true

    /// options which and how extensions shall be considered for class diagram generation  (default: all)
    public var showExtensions: ExtensionVisualization?

    /// a suffix added to an extension member which will be displayed as part of the main type . You can use [Emoji](https://plantuml.com/creole#68305e25f5788db0), [OpenIconic](https://plantuml.com/creole#041a1eb0031c373d), or any string
    public private(set) var mergedExtensionMemberIndicator: String? = "<&bolt>"

    /// show [access level](https://plantuml.com/class-diagram#3644720244dd6c6a) for members
    public private(set) var showMemberAccessLevelAttribute: Bool = true

    /// exclude elements for given names (wildcard support with `*`), e.g. use `*Test*`to hide classes/structs/... who contain `Test` in their name
    public private(set) var exclude: [String]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let havingAccessLevel = try container.decodeIfPresent([AccessLevel].self, forKey: .havingAccessLevel) {
            self.havingAccessLevel = havingAccessLevel
        }
        if let showMembersWithAccessLevel = try container.decodeIfPresent([AccessLevel].self, forKey: .showMembersWithAccessLevel) {
            self.showMembersWithAccessLevel = showMembersWithAccessLevel
        }
        if let showNestedTypes = try container.decodeIfPresent(Bool.self, forKey: .showNestedTypes) {
            self.showNestedTypes = showNestedTypes
        }
        if let showGenerics = try container.decodeIfPresent(Bool.self, forKey: .showGenerics) {
            self.showGenerics = showGenerics
        }
        if let visualization = try? container.decodeIfPresent(String.self, forKey: .showExtensions) {
            showExtensions = ExtensionVisualization(rawValue: visualization)
        } else if let showExtensionsBoolean = try? container.decodeIfPresent(Bool.self, forKey: .showExtensions) {
            showExtensions = ExtensionVisualization.from(showExtensionsBoolean)
        }
        if let mergedExtensionMemberIndicator = try container.decodeIfPresent(String.self, forKey: .mergedExtensionMemberIndicator) {
            self.mergedExtensionMemberIndicator = mergedExtensionMemberIndicator
        }
        if let showMemberAccessLevelAttribute = try container.decodeIfPresent(Bool.self, forKey: .showMemberAccessLevelAttribute) {
            self.showMemberAccessLevelAttribute = showMemberAccessLevelAttribute
        }
        if let exclude = try container.decodeIfPresent([String].self, forKey: .exclude) {
            self.exclude = exclude
        }
    }

    /// memberwise initializer
    public init(
        havingAccessLevel: [AccessLevel] = [.open, .public, .internal, .private],
        showMembersWithAccessLevel: [AccessLevel] = [.open, .public, .internal, .private],
        showNestedTypes: Bool = true,
        showGenerics: Bool = true,
        showExtensions: ExtensionVisualization? = nil,
        mergedExtensionMemberIndicator: String? = "<&bolt>",
        showMemberAccessLevelAttribute: Bool = true,
        exclude: [String]? = nil
    ) {
        self.havingAccessLevel = havingAccessLevel
        self.showMembersWithAccessLevel = showMembersWithAccessLevel
        self.showNestedTypes = showNestedTypes
        self.showGenerics = showGenerics
        self.showExtensions = showExtensions
        self.mergedExtensionMemberIndicator = mergedExtensionMemberIndicator
        self.showMemberAccessLevelAttribute = showMemberAccessLevelAttribute
        self.exclude = exclude
    }
}
