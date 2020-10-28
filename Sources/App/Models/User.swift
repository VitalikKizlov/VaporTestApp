//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 25.10.2020.
//

import Fluent
import Vapor

final class User: Model, Content {
    
    static let schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var username: String
    
    @Children(for: \Acronym.$user)
    var acronyms: [Acronym]
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String) {
        self.id = id
        self.name = name
        self.username = username
    }
    
}
