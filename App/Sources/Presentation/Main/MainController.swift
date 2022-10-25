//
//  MainController.swift
//  connect
//
//  Created by sean on 2022/06/02.
//  Copyright © 2022 sideproj. All rights reserved.
//

import UIKit

import Profile
import COCommonUI
import COManager
import CONetwork

/// 코디네이터 인터페이스
protocol BaseCoordinator: AnyObject {
  var presenter: UINavigationController {get set}
  var childrenCoordinator: [BaseCoordinator] {get set}
}

/// ViewController Flow 인터페이스
protocol ViewControllerFlow {
  func makeMainController() -> MainController
  func makeHomeCoordinator() -> HomeCoordinator
  func makeHomeController() -> HomeController
}

/// MainFlow DI
class MainFlow: ViewControllerFlow {
  
  func makeMainController() -> MainController {
    return MainController(viewFlow: self)
  }
  
  func makeHomeCoordinator() -> HomeCoordinator {
    return HomeCoordinator(presenter: UINavigationController(rootViewController: makeHomeController()))
  }
  
  func makeHomeController() -> HomeController {
    return HomeController(reactor: HomeViewReactor(homeApiService: ApiManager.shared))
  }
}

/// 하단 탭바가 포함된 화면 컨트롤러.
final class MainController: UITabBarController {
  
  private var profileNavigationController: UINavigationController!
  
  var viewFlow: ViewControllerFlow?
  
  init(viewFlow: ViewControllerFlow) {
    self.viewFlow = viewFlow
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setViewContaollers()
    setupTabBar()
  }
}

extension MainController {
  /// 탭바 메뉴당 화면 설정(추후 아이콘 등 설정).
  private func setViewContaollers() {
    
    /// 지도 화면.
    let mapController = MapController()
    mapController.tabBarItem = .init(
      title: "main.tabItem.map".localized(),
      image: nil,
      selectedImage: nil
    )
    
    /// 채팅 화면.
    let messageController = MessaeController()
    messageController.tabBarItem = .init(
      title: "main.tabItem.message".localized(),
      image: nil,
      selectedImage: nil
    )
    
    /// MY 화면.
    let profileDIContainer = ProfileDIContainer(
      apiService: ApiManager.shared,
      userService: UserManager.shared
    )
    
    let profileController = profileDIContainer.makeController()
    profileController.delegate = self
    profileNavigationController = UINavigationController(
      rootViewController: profileController
    )
    profileNavigationController.tabBarItem = .init(
      title: "main.tabItem.profile".localized(),
      image: nil,
      selectedImage: nil
    )
    
    guard let coordinator = viewFlow?.makeHomeCoordinator() else { return }
    
    self.viewControllers = [
      coordinator.presenter,
      mapController,
      messageController,
      profileNavigationController
    ]
    
    /// 홈 화면.
    coordinator.presenter
      .tabBarItem = .init(
        title: "main.tabItem.home".localized(),
        image: nil,
        selectedImage: nil
      )
  }
  
  /// 탭바 커스텀 설정.
  private func setupTabBar() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .white
    
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
      .font: UIFont.systemFont(ofSize: 12, weight: .medium),
      .foregroundColor: UIColor.gray
    ]
    
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
      .font: UIFont.systemFont(ofSize: 12, weight: .medium),
      .foregroundColor: UIColor.blue
    ]
    
    self.tabBar.standardAppearance = appearance
    self.tabBar.scrollEdgeAppearance = appearance
    
    self.tabBar.backgroundColor = .white
    self.tabBar.layer.borderWidth = 1
    self.tabBar.layer.borderColor = UIColor.white.cgColor
  }
}

extension MainController: ProfileDelegate {
  func routeToEditProfile() {
    let container = ProfileEditDIContainer(
      apiService: ApiManager.shared,
      userService: UserManager.shared,
      interestService: InterestManager.shared,
      roleSkillsService: RoleSkillsManager.shared
    )
    
    let controller = container.makeController()
    controller.delegate = self
    profileNavigationController.pushViewController(controller, animated: true)
  }
}

extension MainController: ProfileEditDelegate {
  func routeToBack() {
    profileNavigationController.popViewController(animated: true)
  }
}
