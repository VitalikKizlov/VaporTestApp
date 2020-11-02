//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 25.10.2020.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
        .id()
        .field("email", .string, .required)
        .unique(on: "email")
        .field("password_hash", .string, .required)
        .field("created_at", .datetime, .required)
        .field("updated_at", .datetime, .required)
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
