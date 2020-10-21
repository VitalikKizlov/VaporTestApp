//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 21.10.2020.
//

import Vapor
import Fluent

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
    }
    
    func getAllHandler(_ request: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: request.db).all()
    }
    
    func createHandler(_ request: Request) throws -> EventLoopFuture<Acronym> {
        let acronym = try request.content.decode(Acronym.self)
        return acronym.save(on: request.db).map({ acronym })
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db) .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updatedAcronym = try req.content.decode(Acronym.self)
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { acronym in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
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
}
