//
//  UserManager.swift
//  connect
//
//  Created by sean on 2022/07/23.
//  Copyright © 2022 sideproj. All rights reserved.
//

import Foundation

import COManager

public class UserManager: UserService {
  
  public static let shared: UserManager = UserManager()
  
  public var accessToken: String {
    let token = UserDefaults.standard.string(forKey: .accessToken)
    print("token::::::::::::::: \(token) ::::::::::::::::::")
    return token
  }
  
  private init() {}
  
  public func update(accessToken: String) {
    UserDefaults.standard.set(accessToken, forKey: .accessToken)
  }
  
  public func remove() {
    UserDefaults.standard.remove(forKey: .accessToken)
  }
}