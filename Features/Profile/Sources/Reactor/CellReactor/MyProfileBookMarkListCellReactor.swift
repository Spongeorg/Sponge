//
//  MyProfileBookMarkListCellReactor.swift
//  Profile
//
//  Created by Kim dohyun on 2022/12/13.
//

import Foundation
import ReactorKit

import CODomain



final class MyProfileBookMarkListCellReactor: Reactor {
    
    
    typealias Action = NoAction
    
    
    struct State {
        var myBookMarkModel: ProfileBookMark
    }
    
    let initialState: State
    
    init(myBookMarkModel: ProfileBookMark) {
        self.initialState = State(myBookMarkModel: myBookMarkModel)
    }
    
}
