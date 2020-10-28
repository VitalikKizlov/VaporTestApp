//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 21.10.2020.
//

import Vapor
import Fluent

//B2407C0D-3C49-4ED8-86BC-CCEA81AEEFC4
//4C4D2597-13EF-44F9-AC57-115EC2318090

struct AcronymController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoutes = routes.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandler(_:))
        acronymsRoutes.post(use: createHandler(_:))
        acronymsRoutes.get(":acronymID", use: getHandler(_:))
        acronymsRoutes.put(":acronymID", use: updateHandler)
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("sorted", use: sortedHandler)
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
        acronymsRoutes.post(":acronymID", "categories", ":categoryID", use: addCategoriesHandler)
        acronymsRoutes.get(":acronymID", "categories", use: getCategoriesHandler)
        acronymsRoutes.delete(":acronymID", "categories", ":categoryID", use: removeCategoriesHandler)
    }
    
    func getAllHandler(_ request: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: request.db).all()
    }
    
    func createHandler(_ request: Request) throws -> EventLoopFuture<Acronym> {
        let data = try request.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        return acronym.save(on: request.db).map({ acronym })
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db) .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updateData = try req.content.decode(CreateAcronymData.self)
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { acronym in
                acronym.short = updateData.short
                acronym.long = updateData.long
                acronym.$user.id = updateData.userID
                return acronym.save(on: req.db).map { acronym }
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db) .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db).transform(to: .noContent)
        }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm = req .query[String.self, at: "term"] else { throw Abort(.badRequest) }
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == searchTerm)
            or.filter(\.$long == searchTerm)}
            .all()
    }
    
    func getFirstHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        return Acronym.query(on: req.db) .first().unwrap(or: Abort(.notFound))
    }
    
    func sortedHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        return Acronym.query(on: req.db) .sort(\.$short, .ascending).all()
    }
    
    func getUserHandler(_ request: Request) throws -> EventLoopFuture<User> {
        Acronym.find(request.parameters.get("acronymID"), on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (acronym) in
                acronym.$user.get(on: request.db)
        }
    }
    
    func addCategoriesHandler(_ request: Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronym = Acronym.find(request.parameters.get("acronymID"), on: request.db).unwrap(or: Abort(.notFound))
        let category = Category.find(request.parameters.get("categoryID"), on: request.db).unwrap(or: Abort(.notFound))
        
        return acronym.and(category)
            .flatMap { (acronym, category) in
                acronym
                .$categories
                .attach(category, on: request.db)
                .transform(to: .created)
        }
    }
    
    func getCategoriesHandler(_ request: Request) throws -> EventLoopFuture<[Category]> {
        Acronym.find(request.parameters.get("acronymID"), on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (acronym) in
                acronym.$categories.query(on: request.db).all()
        }
    }
    
    func removeCategoriesHandler(_ request: Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronym = Acronym.find(request.parameters.get("acronymID"), on: request.db).unwrap(or: Abort(.notFound))
        let category = Category.find(request.parameters.get("categoryID"), on: request.db).unwrap(or: Abort(.notFound))
        
        return acronym.and(category)
            .flatMap { (acronym, category) in
                acronym
                .$categories
                    .detach(category, on: request.db)
                    .transform(to: .noContent)
        }
    }
    
}

struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}
