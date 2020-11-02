//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 01.11.2020.
//

import Vapor
import Fluent

enum SessionSource: Int, Content {
  case signup
  case login
}

//1
final class UserToken: Model {
  //2
  static let schema = "user_tokens"
  
  @ID
  var id: UUID?
  
  //3
  @Parent(key: "user_id")
  var user: User
  
  //4
  @Field(key: "value")
  var value: String
  
  //5
  @Field(key: "source")
  var source: SessionSource
  
  //6
  @Field(key: "expires_at")
  var expiresAt: Date?
  
  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?
  
  init() {}
    
    init(id: UUID? = nil, userId: User.IDValue, token: String,
      source: SessionSource, expiresAt: Date?) {
      self.id = id
      self.$user.id = userId
      self.value = token
      self.source = source
      self.expiresAt = expiresAt
    }
}

extension UserToken: ModelTokenAuthenticatable {
  static let valueKey = \UserToken.$value
  static let userKey = \UserToken.$user
  
  var isValid: Bool {
    guard let expiryDate = expiresAt else {
      return true
    }
    
    return expiryDate > Date()
  }
}
