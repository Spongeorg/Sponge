//
//  SplashController.swift
//  connect
//
//  Created by sean on 2022/08/24.
//

import UIKit

import CONetwork
import ReactorKit
import RxCocoa

protocol SplashDelegate: AnyObject {
  func didFinishSplashLoading()
}

/// 스플래쉬.
final class SplashController: UIViewController, ReactorKit.View {
  
  weak var delegate: SplashDelegate?
  
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
  }
  
  func bind(reactor: SplashReactor) {
    
    /// 스킬리스트 요청
    Observable.just(())
      .map { Reactor.Action.requestRolesAndSkills }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    /// 스킬리스트 네트워크 실패시 진행을 위한 처리.
    Observable.just(())
      .delay(.seconds(3), scheduler: MainScheduler.instance)
      .map { Reactor.Action.waitCompletedAfterDelay }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    reactor.state
      .map { $0.isFinishRequests }
      .filter { $0 }
      .observe(on: MainScheduler.instance)
      .bind { [weak self] _ in
        self?.delegate?.didFinishSplashLoading()
      }.disposed(by: disposeBag)
  }
}