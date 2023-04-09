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
    
    private var currentLists: PageLists = []
    private var currentPage: Int = 1
    
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
            .flatMap { lists -> Single<[Data]> in
                return self.encodeImageWithCache(from: lists)
            }
            .flatMap {
                return self.convertDTOToDataSource(with: $0)
            }
    }
}

private extension ListManager {
    
    func encodeImageWithCache(from lists: PageLists) -> Single<[Data]> {
        
        return .create { observer in
            var dataArray: [Data?] = []
            
            lists.forEach {
                guard let url: URL = URL(string: $0.downloadURL) else {
                    dataArray.append(nil)
                    return
                }
                
                if let image: UIImage = ImageCacheService.loadImageFromCache(with: url.pathComponents[2]) {
                    let data: Data? = image.jpegData(compressionQuality: 1)
                    dataArray.append(data)
                    
                } else {
                    let width: CGFloat = CGFloat($0.width)
                    let height: CGFloat = CGFloat($0.height)
                    
                    let image: UIImage? = ImageCacheService.samplingImage(at: url, to: .init(width: width, height: height), with: 0.1)
                    ImageCacheService.saveImageToCache(with: url.pathComponents[2], image: image)
                    
                    let data: Data? = image?.jpegData(compressionQuality: 1)
                    dataArray.append(data)
                }
            }
            
            let compactedDatas: [Data] = dataArray.compactMap { $0 }
            observer(.success(compactedDatas))
            
            return Disposables.create()
        }
    }
    
    func convertDTOToDataSource(with datas: [Data]) -> Single<[PiscumDataSource]> {
        
        return .create { observer in
            guard datas.count == self.currentLists.count else {
                observer(.failure(RxError.argumentOutOfRange))
                
                return Disposables.create()
            }
            
            var dataSource: [PiscumDataSource] = []
            for (index, value) in self.currentLists.enumerated() {
                let data: PiscumDataSource = .init(id: value.id, imageData: datas[index])
                dataSource.append(data)
            }
            
            observer(.success(dataSource))
            
            return Disposables.create()
        }
    }
}
