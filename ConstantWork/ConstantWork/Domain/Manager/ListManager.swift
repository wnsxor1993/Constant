//
//  ListManager.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import Foundation
import RxSwift
import RxRelay

final class ListManager {
    
    typealias PageLists = [PiscumDTO]
    
    private let networkService: NetworkService = .init()
    
    private var currentLists: PageLists = []
    private var currentPage: Int = 1
    
    let imageDataSourceRelay: PublishRelay<PiscumDataSource> = .init()
    
    func fetchPageList() -> Single<[PiscumDataSource]> {
        
        return self.networkService.request(endPoint: .fetchList(currentPage))
            .flatMap { data -> Single<PageLists> in
                return .create { observer in
                    guard let lists: PageLists = JSONConvertService<PageLists>().decode(data: data) else {
                        observer(.failure(NetworkError.decodingError))
                        
                        return Disposables.create()
                    }
                    
                    self.currentLists = lists
                    self.currentPage += 1
                    observer(.success(self.currentLists))
                    
                    return Disposables.create()
                }
            }
            .flatMap {
                return self.convertToPiscumDataSource(from: $0)
            }
    }
    
    func fetchPageImageData(from dataSource: PiscumDataSource) {
        self.fetchImage(with: dataSource)
    }
}

private extension ListManager {
    
    func convertToPiscumDataSource(from lists: PageLists) -> Single<[PiscumDataSource]> {
        return .create { observer in
            let dataSourceLists: [PiscumDataSource] = lists.compactMap {
                guard let url: URL = .init(string: $0.downloadURL) else { return nil }
                
                return .init(id: $0.id, width: $0.width, height: $0.height, imageURL: url)
            }
            
            guard self.currentLists.count == dataSourceLists.count else {
                observer(.failure(RxError.noElements))
                
                return Disposables.create()
            }
            
            observer(.success(dataSourceLists))
            
            return Disposables.create()
        }
    }
    
    func fetchImage(with dataSource: PiscumDataSource) {
        DispatchQueue.global(qos: .background).async {
            var newDataSource: PiscumDataSource = dataSource
            
            if let image: UIImage = ImageCacheService.loadImageFromCache(with: "PiscumID_\(dataSource.id)") {
                
                newDataSource.imageData = image.jpegData(compressionQuality: 1)
                
                self.imageDataSourceRelay.accept(newDataSource)
            }
            
            let width: CGFloat = .init(newDataSource.width)
            let height: CGFloat = .init(newDataSource.height)
            
            guard let image: UIImage = ImageCacheService.samplingImage(at: newDataSource.imageURL, to: .init(width: width, height: height), with: 0.1) else { return }
            
            ImageCacheService.saveImageToCache(with: "PiscumID_\(newDataSource.id)", image: image)
            newDataSource.imageData = image.jpegData(compressionQuality: 1)
            self.imageDataSourceRelay.accept(newDataSource)
        }
    }
}
