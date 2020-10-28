//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 28.10.2020.
//

import Foundation
import Fluent

final class AcronymCategoryPivot: Model {
    static let schema = "acronym-category-pivot"
    
    @ID
    var id: UUID?
    
    @Parent(key: "acronymID")
    var acronym: Acronym
    
    @Parent(key: "categoryID")
    var category: Category
    
    init() {}
    
    init(id: UUID? = nil, acronym: Acronym, category: Category) throws {
        self.id = id
        self.$acronym.id = try acronym.requireID()
        self.$category.id = try category.requireID()
    }
}
