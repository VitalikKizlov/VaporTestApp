//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 28.10.2020.
//

import Vapor
import Fluent

final class Category: Model, Content {
    
    static let schema = "categories"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Siblings(through: AcronymCategoryPivot.self, from: \AcronymCategoryPivot.$category, to: \AcronymCategoryPivot.$acronym)
    var acronyms: [Acronym]
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
}
