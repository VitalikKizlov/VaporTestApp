//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 25.10.2020.
//

import Vapor
import Fluent
import Crypto

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("api", "users")
    }
    
    func createHandler(_ request: Request) throws -> EventLoopFuture<User> {
        let user = try request.content.decode(User.self)
        user.passwordHash = try Bcrypt.hash(user.passwordHash)
        return user.save(on: request.db).map({ user })
    }
    
    func getAllHandler(_ request: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: request.db).all()
    }
    
    func getHandler(_ request: Request) throws -> EventLoopFuture<User> {
        return User.find(request.parameters.get("userID"), on: request.db).unwrap(or: Abort(.notFound))
    }
    
}
