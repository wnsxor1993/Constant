//
//  ListManager.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import Foundation
import RxSwift

final class ListManager {
    
    typealias PageLists = [PiscumDTO]
    
    private let networkService: NetworkService = .init()
    
    private(set) var pageLists: PageLists = []
    private var currentPage: Int = 1
    
    func fetchPageList() -> Single<PageLists> {
        
        return self.networkService.request(endPoint: .fetchList(currentPage))
            .flatMap { data -> Single<PageLists> in
                return .create { observer in
                    guard let lists: PageLists = JSONConvertService<PageLists>().decode(data: data) else {
                        observer(.failure(NetworkError.decodingError))
                        
                        return Disposables.create()
                    }
                    
                    self.currentPage += 1
                    observer(.success(lists))
                    
                    return Disposables.create()
                }
            }
    }
}
