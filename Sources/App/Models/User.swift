//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 25.10.2020.
//

import Fluent
import Vapor

final class User: Model, Content {
    
    struct Public: Content {
        let email: String
        let id: UUID
        let createdAt: Date?
        let updatedAt: Date?
    }
    
    static let schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, email: String, passwordHash: String) {
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User {
    static func create(from userSignup: UserSignup) throws -> User {
        User(email: userSignup.email, passwordHash: try Bcrypt.hash(userSignup.password))
    }
    
    func createToken(source: SessionSource) throws -> UserToken {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        return try UserToken(userId: requireID(),
                             token: [UInt8].random(count: 16).base64, source: source, expiresAt: expiryDate)
    }
    
    func asPublic() throws -> Public {
        Public(email: email,
               id: try requireID(),
               createdAt: createdAt,
               updatedAt: updatedAt)
    }
}

// MARK: - ModelAuthenticatable

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
