//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 01.11.2020.
//

import Vapor
import Fluent
import Crypto

struct UserSignup: Content {
  let email: String
  let password: String
}

struct NewSession: Content {
  let token: String
  let user: User.Public
}

extension UserSignup: Validatable {
  static func validations(_ validations: inout Validations) {
    validations.add("email", as: String.self, is: !.empty)
    validations.add("password", as: String.self, is: .count(6...))
  }
}

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authRoutes = routes.grouped("api", "auth")
        authRoutes.post("signup", use: create(req:))
        
        let tokenProtected = authRoutes.grouped(UserToken.authenticator())
        tokenProtected.get("me", use: getMyOwnUser(req:))
        
        let userProtected = authRoutes.grouped(User.authenticator())
        userProtected.post("login", use: login(req:))
    }
    
fileprivate func create(req: Request) throws -> EventLoopFuture<NewSession> {
  try UserSignup.validate(content: req)
  let userSignup = try req.content.decode(UserSignup.self)
  let user = try User.create(from: userSignup)
  var token: UserToken!

  return checkIfUserExists(userSignup.email, req: req).flatMap { exists in
    guard !exists else {
        return req.eventLoop.future(error: UserError.emailAlreadyExists)
    }

    return user.save(on: req.db)
  }.flatMap {
    guard let newToken = try? user.createToken(source: .signup) else {
      return req.eventLoop.future(error: Abort(.internalServerError))
    }
    token = newToken
    return token.save(on: req.db)
  }.flatMapThrowing {
    NewSession(token: token.value, user: try user.asPublic())
  }
}

fileprivate func login(req: Request) throws -> EventLoopFuture<NewSession> {
  let user = try req.auth.require(User.self)
  let token = try user.createToken(source: .login)
    
  return token.save(on: req.db).flatMapThrowing {
    NewSession(token: token.value, user: try user.asPublic())
  }
}

func getMyOwnUser(req: Request) throws -> User.Public {
  try req.auth.require(User.self).asPublic()
}

private func checkIfUserExists(_ email: String, req: Request) -> EventLoopFuture<Bool> {
  User.query(on: req.db)
    .filter(\.$email == email)
    .first()
    .map { $0 != nil }
}
}
