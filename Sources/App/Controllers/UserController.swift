//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 25.10.2020.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("api", "users")
        userRoutes.post(use: createHandler(_:))
        userRoutes.get(use: getAllHabdler(_:))
        userRoutes.get(":userID", use: getHandler(_:))
    }
    
    func createHandler(_ request: Request) throws -> EventLoopFuture<User> {
        let user = try request.content.decode(User.self)
        return user.save(on: request.db).map({ user })
    }
    
    func getAllHabdler(_ request: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: request.db).all()
    }
    
    func getHandler(_ request: Request) throws -> EventLoopFuture<User> {
        return User.find(request.parameters.get("userID"), on: request.db).unwrap(or: Abort(.notFound))
    }
    
}
