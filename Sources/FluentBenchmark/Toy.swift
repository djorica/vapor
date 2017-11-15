import Async
import Fluent
import Foundation

public final class Toy<D: Database>: Model {
    /// See Model.Database
    public typealias Database = D

    /// See Model.ID
    public typealias ID = UUID

    /// See Model.name
    public static var name: String {
        return "toy"
    }

    /// See Model.idKey
    public static var idKey: IDKey { return \.id }

    /// See Model.keyFieldMap
    public static var keyFieldMap: KeyFieldMap {
        return [
            key(\.id): field("id"),
            key(\.name): field("name")
        ]
    }

    /// Foo's identifier
    var id: ID?

    /// Name string
    var name: String

    /// Create a new foo
    init(id: ID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: Relations

extension Toy where Database.Connection: JoinSupporting {
    /// A relation to this toy's pets.
    var pets: Siblings<Toy, Pet<Database>, PetToy<Database>> {
        return siblings()
    }
}

// MARK: Migration

internal struct ToyMigration<D: Database>: Migration where D.Connection: SchemaSupporting {
    /// See Migration.database
    typealias Database = D

    /// See Migration.prepare
    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return connection.create(Toy<Database>.self) { builder in
            try builder.field(
                type: Database.Connection.FieldType.makeSchemaFieldType(for: .uuid),
                for: \Toy<Database>.id
            )
            try builder.field(
                type: Database.Connection.FieldType.makeSchemaFieldType(for: .string),
                for: \Toy<Database>.name
            )
        }
    }

    /// See Migration.revert
    static func revert(on connection: Database.Connection) -> Future<Void> {
        return connection.delete(Toy<Database>.self)
    }
}



