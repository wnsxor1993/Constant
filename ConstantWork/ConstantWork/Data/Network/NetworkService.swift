//
//  NetworkService.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import Foundation
import RxSwift

struct NetworkService {
    
    func request(endPoint: EndPoint) -> Single<Data> {
        
        return self.makeURLRequest(with: endPoint)
            .flatMap {
                self.resumeURLSession(with: $0)
            }
    }
}


private extension NetworkService {

    func makeURLRequest(with target: EndPoint) -> Single<URLRequest> {
        guard let url = target.url else { return .error(NetworkError.noData) }
        
        var request = URLRequest(url: url)

        if let header = target.contentType {
            header.forEach { (key, value) in
                request.addValue(value, forHTTPHeaderField: key)
            }
            request.httpMethod = target.httpMethod.value
        }

        return .just(request)
    }
    
    func resumeURLSession(with urlRequest: URLRequest) -> Single<Data> {
        
        return .create { observer in
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else { return }

                if let error = error {
                    observer(.failure(NetworkError.transportError(error)))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    observer(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                    return
                }

                guard let data = data else {
                    observer(.failure(NetworkError.noData))
                    return
                }

                observer(.success(data))
            }.resume()

            return Disposables.create()
        }
    }
}
