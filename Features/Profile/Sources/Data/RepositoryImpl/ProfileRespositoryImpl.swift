//
//  ProfileRespositoryImpl.swift
//  connect
//
//  Created by sean on 2022/07/23.
//  Copyright © 2022 sideproj. All rights reserved.
//

import Foundation

import RxSwift
import CODomain
import CONetwork

final class ProfileRepositoryImpl: ProfileRepository {
  
  let apiService: ApiService
  
  init(apiService: ApiService) {
    self.apiService = apiService
  }
}

extension ProfileRepositoryImpl {
  func userProfile() -> Observable<Profile> {
    return apiService.request(
      endPoint: .init(path: .userProfile)
    )
  }
  
  func updateProfile(parameter: ProfileEditParameter) -> Observable<Profile> {
    return apiService.request(
      endPoint: .init(path: .updateProfile(parameter))
    )
  }
}
