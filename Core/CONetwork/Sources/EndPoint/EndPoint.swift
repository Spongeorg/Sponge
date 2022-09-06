//
//  EndPoint.swift
//  connect
//
//  Created by sean on 2022/07/23.
//  Copyright © 2022 sideproj. All rights reserved.
//

import Foundation

import COManager

public enum HTTPMethod {
  case get, post, put, delete
  
  var string: String {
    switch self {
    case .get:
      return "GET"
    case .post:
      return "POST"
    case .put:
      return "PUT"
    case .delete:
      return "DELETE"
    }
  }
}

public struct EndPoint {
  
  public let path: Path
  private let accessToken: String
  
  public init(path: Path, userService: UserService = UserManager.shared) {
    self.path = path
    self.accessToken = userService.accessToken
  }
}

public extension EndPoint {
  
  var baseURL: URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "contpass.site"
    return components.url!
  }
  
  var header: [String: String]? {
    return ["Authorization": accessToken]
  }
  
  var url: URL? {
    
    var components = URLComponents()
    components.scheme = baseURL.scheme
    components.host = baseURL.host
    
    let queryItems: [URLQueryItem] = []
    components.path = path.string
    components.queryItems = queryItems
    
    return components.url
  }
  
  var parameter: [String: Any]? {
    return path.parameter
  }
  
  var method: HTTPMethod {
    switch path {
    case .userProfile, .updateProfile:
      return .put
    case .signIn:
      return .post
    }
    return .get
  }
}