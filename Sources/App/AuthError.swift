//
//  File.swift
//  
//
//  Created by Vitalii Kizlov on 02.11.2020.
//

import Vapor

enum UserError {
  case emailAlreadyExists
}

extension UserError: AbortError {
  var description: String {
    reason
  }

  var status: HTTPResponseStatus {
    switch self {
    case .emailAlreadyExists: return .conflict
    }
  }

  var reason: String {
    switch self {
    case .emailAlreadyExists: return "Email already exists"
    }
  }
}
