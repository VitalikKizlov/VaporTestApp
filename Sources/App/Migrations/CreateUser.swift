//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 25.10.2020.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
        .id()
        .field("name", .string, .required)
        .field("username", .string, .required)
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
