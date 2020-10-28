//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 28.10.2020.
//

import Vapor
import Fluent

struct CategoryController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let categoriesRoute = routes.grouped("api", "categories")
        categoriesRoute.post(use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(":categoryID", use: getHandler)
        categoriesRoute.get(":categoryID", "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ request: Request) throws -> EventLoopFuture<Category> {
        let category = try request.content.decode(Category.self)
        return category.save(on: request.db).map({ category })
    }
    
    func getAllHandler(_ request: Request) throws -> EventLoopFuture<[Category]> {
        Category.query(on: request.db).all()
    }
    
    func getHandler(_ request: Request) throws -> EventLoopFuture<Category> {
        Category.find(request.parameters.get("categoryID"), on: request.db).unwrap(or: Abort(.notFound))
    }
    
    func getAcronymsHandler(_ request: Request) throws -> EventLoopFuture<[Acronym]> {
        Category.find(request.parameters.get("categoryID"), on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (category) in
                category.$acronyms.get(on: request.db)
        }
    }
    
}