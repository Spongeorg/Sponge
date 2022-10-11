//
//  SignUpDIContainer.swift
//  Sign
//
//  Created by sean on 2022/09/24.
//

import Foundation
import UIKit

import COCommon
import CODomain
import CONetwork
import COManager
import ReactorKit

public final class SignUpDIContainer: DIContainer {
  public typealias Reactor = SignUpReactor
  public typealias Repository = SignUpRepository
  public typealias UserCase = SignUpUseCase
  public typealias ViewController = SignUpController
  
  private let apiService: ApiService
  private let userService: UserService
  private let roleSkillsService: RoleSkillsService
  private let authType: AuthType
  private let accessToken: String
  
  public init(apiService: ApiService, userService: UserService, roleSkillsService: RoleSkillsService, authType: AuthType, accessToken: String) {
    self.apiService = apiService
    self.userService = userService
    self.roleSkillsService = roleSkillsService
    self.authType = authType
    self.accessToken = accessToken
  }
  
  public func makeRepository() -> Repository {
    return SignUpRepositoryImpl(apiService: apiService)
  }
  
  public func makeUseCase() -> UserCase {
    return SignUpUseCaseImpl(
      repository: makeRepository(),
      userService: userService
    )
  }
  
  public func makeReactor() -> Reactor {
    return Reactor(
      useCase: makeUseCase(),
      authType: authType,
      accessToken: accessToken
    )
  }
  
  public func makeController() -> ViewController {
    let controller = SignUpController(roleSkillsService: roleSkillsService)
    controller.reactor = makeReactor()
    return controller
  }
}
