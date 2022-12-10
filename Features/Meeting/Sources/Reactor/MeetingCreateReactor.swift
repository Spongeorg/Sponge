//
//  MeetingCreateReactor.swift
//  Meeting
//
//  Created by sean on 2022/11/11.
//

import Foundation

import ReactorKit
import RxCocoa
import COCommonUI
import CODomain
import COExtensions
import COManager
import CONetwork

public final class MeetingCreateReactor: Reactor, ErrorHandlerable {
  
  public enum Route {
    case close
    case bottomSheet(BottomSheetType)
  }
  
  public enum Action {
    /// 분야선택 버튼 터치
    case didTapInterestButton
    
    /// 역할 및 인원 버튼
    case didTapRoleAndPeopleButton
    
    /// 기간 버튼 터치
    case didTapDateButton
    
    /// 모임위치 버튼 터치
    case didTapLocationButton
    
    /// BottomSheet에서 선택된 요소.
    case didSelectedInterest(String)
    case didSelectedAddress(String)
    case didSelectedDateRange(DateRange)
    case didSelectedRoleAndCountItems([RoleAndCountItem])
    
    /// 모임만들기 버튼 터치
    case didTapCreateMeeting(CreateMeetingParameter)
  }
  
  public enum Mutation {
    
    case setSelectedInterest(Interest)
    case setSelectedRegion(Region)
    case setSelectedDateRange(DateRange)
    case setSelectedRoleAndCountItems([RoleAndCountItem])
    
    case setRoute(Route?)
    case setError(COError?)
  }
  
  public struct State {
    var selectedInterest: Interest?
    @Pulse var selectedRoleAndCountItems: [RoleAndCountItem]?
    @Pulse var selectedDateRange: DateRange?
    @Pulse var selectedRegion: Region?
    @Pulse var route: Route?
    @Pulse var error: COError?
  }
  
  public var initialState: State = .init()
  
  public lazy var errorHandler: (_ error: Error) -> Observable<Mutation> = { error in
    return .just(.setError(error.asCOError))
  }
  
  private let repository: MeetingCreateRepository
  private let userService: UserService
  private let interestService: InterestService
  private let addressService: AddressService
  private let roleSkillsService: RoleSkillsService
  
  public init(
    repository: MeetingCreateRepository,
    userService: UserService,
    interestService: InterestService,
    addressService: AddressService,
    roleSkillsService: RoleSkillsService
  ) {
    self.repository = repository
    self.userService = userService
    self.interestService = interestService
    self.addressService = addressService
    self.roleSkillsService = roleSkillsService
  }
  
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didTapInterestButton:
      let interestList: [BottomSheetItem] = interestService.interestList.map {
        .init(value: $0.name)
      }
      return .just(.setRoute(.bottomSheet(.interest(interestList))))
      
    case .didTapRoleAndPeopleButton:
      let roleList = roleSkillsService.roleSkillsList.map { $0.roleName }
      let item: BottomSheetRoleItem = .init(
        roles: roleList,
        items: [.init()]
      )
      
      return .just(.setRoute(.bottomSheet(.roleAndPeople(item))))
      
    case .didTapDateButton:
      return .just(.setRoute(.bottomSheet(.date)))
      
    case .didTapLocationButton:
      let addressList: [BottomSheetItem] = addressService.addressList.map {
        .init(value: $0.법정동명)
      }
      return .just(.setRoute(.bottomSheet(.address(addressList))))
      
    case let .didSelectedInterest(string):
      guard let interest = interestService.interestList
        .filter({ $0.name == string })
        .first else {
        return .empty()
      }
      
      return .just(.setSelectedInterest(interest))
      
    case let .didSelectedAddress(string):
      guard let address = addressService.addressList
        .filter({ $0.법정동명 == string })
        .first else {
        return .empty()
      }
      let region = Region(code: address.법정코드, name: address.법정동명)
      return .just(.setSelectedRegion(region))
      
    case let .didSelectedDateRange(dateRange):
      return .just(.setSelectedDateRange(dateRange))
      
    case let .didSelectedRoleAndCountItems(items):
      return .just(.setSelectedRoleAndCountItems(items))
      
    case let .didTapCreateMeeting(parameter):
      
      guard let interesting = currentState.selectedInterest else {
        return .just(.setError(COError.message(nil, "관심분야를 최소 하나이상 선택 해주세요.")))
      }
      
      guard let roleAndCounts = currentState.selectedRoleAndCountItems else {
        return .just(.setError(COError.message(nil, "모집인원을 선택 해주세요.")))
      }
      
      guard let dateRange = currentState.selectedDateRange else {
        return .just(.setError(COError.message(nil, "프로젝트 기간을 설정 해주세요.")))
      }
      
      guard let region = currentState.selectedRegion else {
        return .just(.setError(COError.message(nil, "모임위치를 선택 해주세요.")))
      }
      var parameter = parameter
      parameter.updateInterestings([interesting])
      parameter.updateRoleAndCounts(roleAndCounts)
      parameter.updateDateRange(dateRange)
      parameter.updatePlace(region.description)
      
      print(parameter)
      return repository.requestCreateMeeting(parameter: parameter)
        .flatMap { _ -> Observable<Mutation> in
          return .just(.setRoute(.close))
        }
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .setSelectedInterest(interest):
      newState.selectedInterest = interest
    case let .setSelectedRegion(region):
      newState.selectedRegion = region
    case let .setSelectedDateRange(dateRange):
      newState.selectedDateRange = dateRange
    case let .setSelectedRoleAndCountItems(items):
      newState.selectedRoleAndCountItems = items
    case let .setRoute(route):
      newState.route = route
    case let .setError(error):
      newState.error = error
    }
    
    return newState
  }
}
