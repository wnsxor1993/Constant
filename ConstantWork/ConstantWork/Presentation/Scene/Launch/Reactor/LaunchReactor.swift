//
//  LaunchReactor.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/10.
//

import Foundation
import ReactorKit

final class LaunchReactor: Reactor {
    
    enum Action {
        case fetchDefaultList
    }
    
    enum Mutation {
        case refreshImage(PiscumDataSource)
    }
    
    struct State {
        var piscumDataSource: [PiscumDataSource] = []
    }
    
    let initialState: State
    
    private let listManager: ListManager
    private let disposeBag: DisposeBag = .init()
    
    init(with listManager: ListManager) {
        self.listManager = listManager
        self.initialState = State()
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return listManager.imageDataSourceRelay.map(Mutation.refreshImage)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchDefaultList:
            self.fetchAllImageData()
            
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .refreshImage(let piscumDataSource):
            newState.piscumDataSource.append(piscumDataSource)
            newState.piscumDataSource.sort { firstPiscum, secondPiscum in
                return firstPiscum.id < secondPiscum.id
            }
        }
        
        return newState
    }
}

private extension LaunchReactor {
    
    func fetchAllImageData() {
        self.listManager.fetchPageList()
            .observe(on: ConcurrentMainScheduler.instance)
            .subscribe(with: self) { (owner, list) in
                list.forEach {
                    owner.listManager.fetchPageImageData(from: $0)
                }
            }
            .disposed(by: disposeBag)
    }
}
