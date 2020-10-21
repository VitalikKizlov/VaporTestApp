//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 14.10.2020.
//

import Fluent

struct CreateAcronym: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms")
        .id()
        .field("short", .string, .required)
        .field("long", .string, .required)
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms").delete()
    }
    
    
}
