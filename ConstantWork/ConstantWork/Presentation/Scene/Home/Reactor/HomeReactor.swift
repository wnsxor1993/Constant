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
        case viewDidLoad
        case fetchPageList
        case fetchPageImage(PiscumDataSource)
        case resetAlertMessage
    }
    
    enum Mutation {
        case setPages([PiscumDataSource])
        case refreshPages([PiscumDataSource])
        case refreshImage(PiscumDataSource)
        case alertEndPage(String?)
    }
    
    struct State {
        var pageLists: [PiscumDataSource]
        var alertMessage: String?
    }
    
    let initialState: State
    
    private let listManager: ListManager
    
    init(with listManager: ListManager, from defaultData: [PiscumDataSource]) {
        self.listManager = listManager
        self.initialState = State(pageLists: defaultData)
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return Observable.merge(mutation, listManager.imageDataSourceRelay.map(Mutation.refreshImage))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .just(.setPages(initialState.pageLists))
            
        case .fetchPageList:
            return self.listManager.fetchPageList()
                .flatMap {
                    guard !($0.isEmpty) else {
                        return .just(.alertEndPage("더 이상 불러올 이미지가 없습니다."))
                    }
                    
                    return .just(.refreshPages($0))
                }
                .asObservable()
            
        case .fetchPageImage(let dataSource):
            self.listManager.fetchPageImageData(from: dataSource)
            
            return .empty()
            
        case .resetAlertMessage:
            return .just(.alertEndPage(nil))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setPages(pages):
            newState.pageLists = pages
            
        case let .refreshPages(pages):
            newState.pageLists = self.appendWithoutOverlap(from: newState.pageLists, with: pages)
            
        case let .refreshImage(page):
            let index: Int? = newState.pageLists.firstIndex { dataSource in
                return dataSource.id == page.id
            }
            
            guard let index else { break }
            
            newState.pageLists[index] = page
            
        case let .alertEndPage(message):
            newState.alertMessage = message
        }
        
        return newState
    }
}

private extension HomeReactor {
    
    func appendWithoutOverlap(from origin: [PiscumDataSource], with new: [PiscumDataSource]) -> [PiscumDataSource] {
        let originSet: Set<PiscumDataSource> = .init(origin)
        let newSet: Set<PiscumDataSource> = .init(new)
        
        let mergedSet = originSet.union(newSet)
        let mergedArray: [PiscumDataSource] = .init(mergedSet)
            .sorted { firstData, secondData in
                guard let first = Int(firstData.id), let second = Int(secondData.id) else { return false }
                
                return first < second
            }
        
        return mergedArray
    }
}
