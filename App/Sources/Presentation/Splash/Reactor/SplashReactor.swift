//
//  SplashReactor.swift
//  AppTests
//
//  Created by sean on 2022/09/25.
//

import Foundation

import CODomain
import COExtensions
import COManager
import CONetwork
import ReactorKit

public final class SplashReactor: Reactor, ErrorHandlerable {
  public enum Action {
    case requestRolesAndSkills
    case waitCompletedAfterDelay
  }
  
  public enum Mutation {
    case setIsFinishRequests(Bool)
    case setError(URLError?)
  }
  
  public struct State {
    var isFinishRequests: Bool = false
    var error: URLError?
  }
  
  public var initialState: State = .init()
  
  public let errorHandler: (_ error: Error) -> Observable<Mutation> = { error in
    return .just(.setError(error.asURLError))
  }
  
  private let apiService: ApiService
  private let roleAndSkillsService: RoleSkillsService
  
  public init(
    apiService: ApiService = ApiManager.shared,
    roleAndSkillsService: RoleSkillsService = RoleSkillsManager.shared
  ) {
    self.apiService = apiService
    self.roleAndSkillsService = roleAndSkillsService
  }
  
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .requestRolesAndSkills:
      return apiService.request(endPoint: .init(path: .allSkills))
        .debug()
        .flatMap { [weak self] (roleAndSkills: [RoleAndSkills]) -> Observable<Mutation> in
          guard let self = self else { return .empty() }
          
          if self.roleAndSkillsService.isExists {
            return .just(.setIsFinishRequests(false))
          } else {
            self.roleAndSkillsService.update(roleAndSkills)
            return .just(.setIsFinishRequests(true))
          }
        }.catch(errorHandler)
    case .waitCompletedAfterDelay:
      return .just(.setIsFinishRequests(true))
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case let .setIsFinishRequests(isFinishRequests):
      newState.isFinishRequests = isFinishRequests
    case let .setError(error):
      newState.error = error
    }
    
    return newState
  }
}