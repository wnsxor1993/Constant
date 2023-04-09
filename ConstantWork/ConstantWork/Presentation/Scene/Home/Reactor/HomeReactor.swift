//
//  HomeReactor.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import Foundation
import ReactorKit

final class HomeReactor: Reactor {
    
    enum Action {
        case fetchPageList
        case resetAlertMessage
    }
    
    enum Mutation {
        case refreshPages([PiscumDTO])
        case alertEndPage(String?)
    }
    
    struct State {
        var pageLists: [PiscumDTO] = []
        var alertMessage: String?
    }
    
    let initialState: State
    
    private let listManager: ListManager
    
    init(with listManager: ListManager) {
        self.listManager = listManager
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchPageList:
            return self.listManager.fetchPageList()
                .flatMap {
                    guard !($0.isEmpty) else {
                        return .just(.alertEndPage("더 이상 불러올 이미지가 없습니다."))
                    }
                    
                    return .just(.refreshPages($0))
                }
                .asObservable()
            
        case .resetAlertMessage:
            return .just(.alertEndPage(nil))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .refreshPages(pages):
            newState.pageLists.append(contentsOf: pages)
            
        case let .alertEndPage(message):
            newState.alertMessage = message
        }
        
        return newState
    }
}
