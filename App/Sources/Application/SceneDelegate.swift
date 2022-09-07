//
//  SceneDelegate.swift
//  connect-iOSTests
//
//  Created by sean on 2022/06/02.
//  Copyright © 2022 butterfree. All rights reserved.
//

import UIKit

import CONetwork
import Sign

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  
  var controller: UINavigationController!

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

    guard let scene = (scene as? UIWindowScene) else { return }
    window = .init(windowScene: scene)
    
    let controller = SplashController()
    controller.delegate = self
    
    window?.rootViewController = controller
    window?.makeKeyAndVisible()
  }
}

extension SceneDelegate: SplashDelegate {
  func didFinishSplashLoading() {
    
    /// 로그인 상태 체크.
    if UserManager.shared.accessToken.isEmpty {
      let container = SignInDIContainer(
        apiService: ApiManaerStub(state: .response(204)),
        userService: UserManager.shared,
        delegate: self
      )
      
      controller = UINavigationController(
        rootViewController: container.makeController()
      )
    } else {
      controller = UINavigationController(
        rootViewController: MainController()
      )
    }
    
    window?.rootViewController = controller
    window?.makeKeyAndVisible()
  }
}

extension SceneDelegate: SignInDelegate {
  func routeToSignUp() {
    let signUpController = SignUpController()
    controller.pushViewController(signUpController, animated: true)
  }
}
